---
name: maintain-pstack
description: Maintain a Codex pstack checkout, check original upstream updates, sync an authorized fork through a verified PR and merge, and install the merged version locally.
---

# Maintain pstack

Use this for pstack source changes and updates that must reach both the fork and the installed Codex runtime. A local install, a pushed branch, a merged PR, and an upstream check are separate outcomes. Report each one.

## Find the maintained source

Read the active Codex runtime and `~/.codex/pstack/install.json`. Its `sourceRoot` identifies the checkout. Read that checkout's instructions and `codex/README.md`. Change maintained source files there, never the versioned runtime or a skill junction.

Inspect the working tree, worktrees, remotes, default branch, and existing PRs. Preserve unrelated changes in place. Use an isolated branch or worktree for this task. Record the fork URL, original upstream URL, starting SHAs, installed version, and requested end state in the task's handoff.

Read `codex/snapshot.json` when present. Compare its upstream URL with the actual remote and repository metadata. Resolve a mismatch before integrating. Do not infer the original repository from the checkout's name.

## Check original upstream

Fetch the fork's default branch and the verified upstream branch. Inspect commits and changed paths since the recorded upstream revision. Also compare the fork base with the fetched upstream tip.

- If the fork already contains that upstream tip, record the checked SHA and continue without an empty merge.
- If upstream has new commits, integrate them on the task branch with the fork's established merge strategy. Inspect the result for changed skill paths, generated files, installer assumptions, and deleted callers.
- Preserve the Codex runtime, overrides, local model choices, and unrelated custom work. A newer upstream platform example does not authorize restoring another host's adapter or changing model roles.
- If a conflict needs a consequential choice that the request and existing instructions cannot settle, keep a recoverable branch and ask only for that choice.

Never reset the fork to upstream or use a forced repository sync. A shared-branch force push needs its own authorization. Update provenance only to an upstream revision actually integrated. Refresh existing custom-file hashes from saved content when those files change.

## Change and verify the source

Put shared skills in `pstack/skills/<name>/SKILL.md`. The installer discovers names there. `codex/skills` overlays those names and does not register a new skill on its own. Add the skill to the README's existing registry.

Use the repository's applicable checks and CI workflow as the source of truth. For the current Codex layout, run these from the checkout after changing shared skills.

```powershell
node scripts/generate-pstack-harness-trees.mjs
node scripts/generate-pstack-harness-trees.mjs --check
node scripts/check-pstack-docs.mjs
& .\codex\test-sync-pstack.ps1 -SourceRoot $PWD.Path -TestRoot '<new isolated directory>'
```

Inspect generated changes rather than editing them. Run changed executable resources and the existing checks relevant to them. Validate new skill frontmatter and links in both the checkout and a test installation. Installed skills cannot assume the checkout's guides or `codex/` directory were copied into the runtime.

For substantial skill changes, use an independent realistic exercise with isolated local repositories or read-only decisions. A frontmatter pass alone does not show that the skill handles upstream changes, user work, or a partially completed sync correctly. Keep live pushes, merges, and installation within the user's actual requested scope.

## Publish and merge when authorized

Read [Opening a PR](../poteto-mode/playbooks/opening-a-pr.md). A request to update the local installation and push or merge the fork supplies that scope. A request for an audit or local-only edit does not. Do not ask again for actions already authorized.

Push the task branch and open or reuse the matching fork PR. Inspect the final diff and independent review. Check the current PR head, applicable required checks, unresolved review blockers, base, and mergeability. Read [CI recovery](../poteto-mode/references/ci-recovery.md) if a check fails. A skipped job or a green run for another revision cannot prove the needed behavior passed.

Merge only the reviewed, verified head through the repository's supported method. Use an expected-head SHA when available. Read the PR back and record its merge commit. A queued or auto-merge request is not a completed merge.

If an external write times out or a chat resumes, inspect remote branch and PR state before repeating it. Reuse an existing PR or merge result. Do not publish the same change twice.

## Install the merged result

Fetch the fork after merge. Fast-forward the designated maintained checkout only if its local state permits it. Otherwise preserve that checkout and use a clean checkout of the merged default branch. Confirm the installer source contains the merge commit and no unreviewed changes.

Record the active model-file hash and personal instructions outside the managed pstack block before installing. Use the installer from that verified checkout.

```powershell
& .\codex\sync-pstack.ps1 -SourceRoot $PWD.Path
```

Read back `install.json`, the runtime junction, and the affected installed files. Compare references and scripts byte-for-byte with their maintained source. For entrypoints, account for the installer's injected Codex runtime notice and any explicit Codex override. Check that the new skill is reachable through the installed discovery path. Verify local model choices, personal instructions, and unrelated skills remain intact. Record the existing installer's recovery directory.

An installation does not prove an already-open chat refreshed its skill catalog. Give the installed path for immediate use. Start a new chat if discovery still shows the older list.

## Report the saved state

Report the checked upstream SHA and whether integration was needed, the fork PR and actual merge SHA, the local installed source and runtime, applicable validation, recovery location, and any unresolved action. Distinguish checked, pushed, merged, and installed. Do not claim all four from one successful command.
