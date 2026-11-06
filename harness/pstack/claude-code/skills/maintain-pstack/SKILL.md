---
name: maintain-pstack
description: Maintain a Codex pstack checkout, check original upstream updates, directly push locally verified changes to the authorized fork, and install the published version locally.
---

# Maintain pstack

Use this for source changes and updates that must reach both the fork and the installed Codex runtime. Checking upstream, publishing the fork, and installing locally are separate outcomes. Report each one. For this fork, verify locally and push directly to its default branch. Do not create a PR or add, enable, dispatch, or wait for CI/CD.

## Find the maintained source

Read the active Codex runtime and `~/.codex/pstack/install.json`. Its `sourceRoot` identifies the checkout. Read that checkout's instructions and `codex/README.md`. Change maintained source files there, never the versioned runtime or a skill junction.

Inspect the working tree, worktrees, remotes, and default branch. Preserve unrelated changes in place. Use an isolated branch or worktree when the maintained checkout has existing work. Record the fork URL, original upstream URL, starting SHAs, installed version, and requested end state in one local handoff. Personal instructions, credentials, logs, backups, and machine-specific configuration are not source changes to upload.

Read `codex/snapshot.json` when present. Compare its upstream URL with the actual remote and repository metadata. Resolve a mismatch before integrating. Do not infer the original repository from the checkout's name.

## Check original upstream

Fetch the fork's default branch and the verified upstream branch. Inspect commits and changed paths since the recorded upstream revision. Also compare the fork base with the fetched upstream tip.

- If the fork already contains that upstream tip, record the checked SHA and continue without an empty merge.
- If upstream has new commits, integrate them with the fork's established merge strategy. Inspect changed skill paths, generated files, installer assumptions, deleted callers, and reintroduced workflows. Preserve this fork's local-only verification and direct-push workflow.
- Preserve the Codex runtime, overrides, local model choices, latest-version-only policy, and unrelated custom work. A newer upstream platform example does not authorize restoring another host's adapter or changing model roles.
- If a conflict needs a consequential choice that the request and existing instructions cannot settle, keep a recoverable branch and ask only for that choice.

Never reset the fork to upstream or force-push a shared branch. Update provenance only to an upstream revision actually integrated. Refresh existing custom-file hashes from saved content when those files change.

## Change and verify the source

Put shared skills in `pstack/skills/<name>/SKILL.md`. The installer discovers names there. `codex/skills` overlays those names and does not register a new skill on its own. Add the skill to the README's existing registry.

Use the repository's existing local checks. For the current Codex layout, run these from the checkout after changing shared skills.

```powershell
node scripts/generate-pstack-harness-trees.mjs
node scripts/verify-pstack.mjs quick
& .\codex\test-sync-pstack.ps1 -SourceRoot $PWD.Path -TestRoot '<new isolated directory>'
```

Inspect generated changes rather than editing them. The shared verifier's `full` mode adds the Node skill-script and verifier tests; use it when those scripts or their integration changed, not as an extra gate for every prose edit. Run affected executable resources and relevant tests locally, and reuse valid unchanged evidence. No remote CI gate is required. Validate skill frontmatter and links in both the checkout and a test installation. Installed skills cannot assume the checkout's guides or `codex/` directory were copied into the runtime.

For substantial skill changes, exercise changed decisions with isolated local repositories or read-only scenarios, including upstream changes, unrelated user work, and a partially completed push. A frontmatter pass alone does not prove the workflow. Keep live pushes and installation within the user's actual requested scope.

## Publish directly when authorized

A request to maintain and synchronize the fork and local installation supplies publication scope. An audit or local-only edit does not. Do not ask again for actions already authorized.

Review the final diff and local verification results. Confirm the intended commit contains only reviewed source changes and no CI/CD workflows. Commit, fetch the fork again, and verify its default branch is an ancestor of the intended commit. If it advanced, integrate it without discarding work, inspect the result, and rerun affected checks. If repository protection rejects the direct push, report the blocker; do not bypass protection or open a PR without a new instruction.

Use a normal fast-forward push such as `git push origin HEAD:main`, substituting the verified default branch. Read the remote branch back and require its SHA to match the intended commit. A local commit or queued operation does not prove publication.

If a push times out or a chat resumes, inspect the remote SHA before retrying. If it already contains the intended commit, continue from that result. Otherwise reconcile remote state before another normal push. Do not publish the same change twice.

## Install the published result

Fetch the fork after publication. Fast-forward the designated maintained checkout only if its local state permits it. Otherwise preserve that checkout and use a clean checkout of the published default branch. Confirm the installer source contains the published commit and no unreviewed changes.

Record the active model-file hash and personal instructions outside the managed pstack block before installing. Use the installer from that verified checkout.

```powershell
& .\codex\sync-pstack.ps1 -SourceRoot $PWD.Path
```

Read back `install.json`, the runtime junction, and the affected installed files. Compare references and scripts byte-for-byte with their maintained source. For entrypoints, account for the installer's injected Codex runtime notice and any explicit Codex override. Check that the new skill is reachable through the installed discovery path. Verify local model choices, latest-version-only policy, personal instructions, and unrelated skills remain intact. Record the existing installer's recovery directory.

An installation does not prove an already-open chat refreshed its skill catalog. Give the installed path for immediate use. Start a new chat if discovery still shows the older list.

## Report the saved state

Report the checked upstream SHA and whether integration was needed, the actual published default-branch SHA, local installed source and runtime, applicable validation, recovery location, and unresolved action. Distinguish checked, pushed, and installed. Do not claim all three from one successful command.
