#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { readdirSync } from "node:fs";
import { dirname, join, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const mode = process.argv[2] ?? "quick";

if (!["quick", "full"].includes(mode) || process.argv.length > 3) {
  console.error("Usage: node scripts/verify-pstack.mjs [quick|full]");
  process.exit(1);
}

const checks = [
  { name: "Plugin definitions", scope: "quick", args: ["scripts/validate-plugins.mjs"] },
  { name: "pstack documentation", scope: "quick", args: ["scripts/check-pstack-docs.mjs"] },
  { name: "Generated pstack harness trees", scope: "quick", args: ["scripts/generate-pstack-harness-trees.mjs", "--check"] },
  {
    name: "pstack skill scripts",
    scope: "full",
    args: () => {
      const files = readdirSync(join(root, "pstack", "skills"), { recursive: true })
        .filter((file) => /^[^./][^/]*\/scripts\/test\/[^./][^/]*\.test\.ts$/.test(file.split(sep).join("/")))
        .sort()
        .map((file) => join("pstack", "skills", file));
      if (files.length === 0) throw new Error("No pstack skill-script tests found.");
      return ["--disable-warning=ExperimentalWarning", "--test", ...files];
    },
  },
  { name: "Verification runner", scope: "full", args: ["--test", "scripts/test/verify-pstack.test.mjs"] },
];

for (const { name, scope, args } of checks) {
  if (mode === "quick" && scope === "full") continue;
  console.log(`\n${name}`);
  const result = spawnSync(process.execPath, typeof args === "function" ? args() : args, {
    cwd: root,
    stdio: "inherit",
  });
  if (result.error) {
    console.error(`${name} could not start: ${result.error.message}`);
    process.exit(1);
  }
  if (result.status !== 0) process.exit(result.status ?? 1);
}
