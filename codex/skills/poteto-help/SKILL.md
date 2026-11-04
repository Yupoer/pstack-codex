---
name: poteto-help
description: Guide users through the Codex pstack installation, skill choices, and model roles. Use for pstack help and setup questions.
disable-model-invocation: true
---

# Poteto help

For a help question, answer from the relevant installed files. For a request to perform work, read [poteto-mode](../poteto-mode/SKILL.md) and execute the task.

Read [Codex runtime](../../docs/harness/codex.md) and `~/.codex/pstack/install.json` for the active installation. Skills live under `~/.agents/skills/`, and role choices live in `~/.codex/pstack/pstack-models.md`.

- For source updates, original upstream checks, fork PRs, merges, and local synchronization, use [maintain-pstack](../maintain-pstack/SKILL.md).
- For an install-only request, use `~/.codex/pstack/sync-pstack.ps1 -SourceRoot <checkout>`. Read the checkout's `codex/README.md` for recovery.
- For model or effort changes, use [setup-pstack](../setup-pstack/SKILL.md).
- For initial project setup, [setup-pstack](../setup-pstack/SKILL.md) reuses existing verification and identifies missing real-app or formal checks. Model-only changes keep their scope.
- For a new task, use [poteto-mode](../poteto-mode/SKILL.md) with the goal and an observable completion check.
- For architecture, explanations, reviews, and coverage, inspect the matching installed skill's description before recommending it.

Invoke skills by the names Codex actually exposes. Do not suggest another application's plugin commands, settings, or installation. Give file paths or verified fork links that the user can open.
