import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { test } from "node:test";
import { pathToFileURL } from "node:url";

const record = (name) => `
import { appendFileSync } from "node:fs";
appendFileSync("checks.jsonl", JSON.stringify({ name: ${JSON.stringify(name)}, args: process.argv.slice(2) }) + "\\n");
`;

function fixture(t) {
  const root = mkdtempSync(join(tmpdir(), "pstack verification "));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const write = (file, source) => {
    const target = join(root, file);
    mkdirSync(dirname(target), { recursive: true });
    writeFileSync(target, source);
  };
  write("scripts/verify-pstack.mjs", readFileSync(new URL("../verify-pstack.mjs", import.meta.url), "utf8"));
  for (const [file, name] of [
    ["validate-plugins.mjs", "plugins"],
    ["check-pstack-docs.mjs", "docs"],
    ["generate-pstack-harness-trees.mjs", "harness"],
  ]) write(`scripts/${file}`, record(name));
  mkdirSync(join(root, "elsewhere"));
  const env = { ...process.env };
  delete env.NODE_TEST_CONTEXT;
  return {
    root,
    write,
    run: (...args) => spawnSync(process.execPath, [join(root, "scripts/verify-pstack.mjs"), ...args], {
      cwd: join(root, "elsewhere"),
      encoding: "utf8",
      env,
    }),
    events: () => existsSync(join(root, "checks.jsonl"))
      ? readFileSync(join(root, "checks.jsonl"), "utf8").trim().split("\n").map((line) => JSON.parse(line))
      : [],
  };
}

test("default quick checks run from the script's repository despite a different cwd", (t) => {
  const repo = fixture(t);
  const result = repo.run();
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.deepEqual(repo.events().map(({ name }) => name), ["plugins", "docs", "harness"]);
  assert.deepEqual(repo.events().at(-1).args, ["--check"]);
});

test("full runs the existing skill-script suite and runner tests with literal file arguments", (t) => {
  const repo = fixture(t);
  repo.write("pstack/skills/alpha/scripts/test/one.test.ts", record("skill-alpha"));
  repo.write("pstack/skills/space skill/scripts/test/two.test.ts", record("skill-space"));
  for (const file of [
    "pstack/skills/alpha/scripts/direct.test.ts",
    "pstack/skills/alpha/scripts/test/nested/ignored.test.ts",
    "pstack/skills/alpha/scripts/test/ignored.test.mjs",
  ]) repo.write(file, "throw new Error('Outside the existing CI suite');\n");
  repo.write("scripts/test/verify-pstack.test.mjs", record("runner"));
  const result = repo.run("full");
  assert.equal(result.status, 0, result.stdout + result.stderr);
  const names = repo.events().map(({ name }) => name);
  assert.deepEqual(names.slice(0, 3), ["plugins", "docs", "harness"]);
  assert.deepEqual(names.slice(3, -1).sort(), ["skill-alpha", "skill-space"], result.stdout + result.stderr);
  assert.equal(names.at(-1), "runner");
});

test("a stale generated-tree check propagates its failure and stops full verification", (t) => {
  const repo = fixture(t);
  repo.write("scripts/generate-pstack-harness-trees.mjs", record("harness") + "process.exit(7);\n");
  const result = repo.run("full");
  assert.equal(result.status, 7, result.stdout + result.stderr);
  assert.deepEqual(repo.events().map(({ name }) => name), ["plugins", "docs", "harness"]);
});

test("an invalid mode fails before running checks", (t) => {
  const repo = fixture(t);
  const result = repo.run("unknown");
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.deepEqual(repo.events(), []);
});

test("full fails when the skill-script suite matches no tests", (t) => {
  const repo = fixture(t);
  repo.write("pstack/skills/alpha/scripts/unselected.test.ts", record("outside-suite"));
  repo.write("scripts/test/verify-pstack.test.mjs", record("runner"));
  const result = repo.run("full");
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.deepEqual(repo.events().map(({ name }) => name), ["plugins", "docs", "harness"]);
});

test("a Node spawn failure fails verification before any checker runs", (t) => {
  const repo = fixture(t);
  repo.write("missing-node.mjs", `process.execPath = ${JSON.stringify(join(repo.root, "missing-node"))};\n`);
  const result = spawnSync(process.execPath, [
    "--import", pathToFileURL(join(repo.root, "missing-node.mjs")).href,
    join(repo.root, "scripts/verify-pstack.mjs"), "quick",
  ], { cwd: repo.root, encoding: "utf8" });
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.deepEqual(repo.events(), []);
});
