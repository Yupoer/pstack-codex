---
name: setup-pstack
description: Configure pstack model roles and reasoning effort for native Codex subagents, or connect project verification during initial pstack setup.
disable-model-invocation: true
---

# Set up pstack in Codex

Read [Codex runtime](../../docs/harness/codex.md) and `~/.codex/pstack/pstack-models.md`. Preserve existing choices except the roles or budget the user wants to change.

Use the current native subagent tool's supported models and effort values. Do not derive provider-specific slugs or run another provider's CLI. An `auto` or `inherit-parent` role omits the model override. Keep a panel's seat count unless the user changes it.

When the requested configuration is clear and supported, update `~/.codex/pstack/pstack-models.md` directly. Ask only for a consequential choice that the request and current configuration do not resolve. Keep plain role lines without frontmatter, using the existing role labels and comma-separated panel entries.

Read back the saved file and report the changed roles and any unsupported choice. Do not spawn agents merely to prove a configuration write. The next actual delegation verifies execution. Changes take effect when the runtime reads the model file in a new chat.

## Connect project verification

For initial project setup, inspect the project's instructions, existing checks, and verification skills. Reuse them. If no harness can drive the real application, offer [create-verification-skill](../create-verification-skill/SKILL.md) once for a concrete behavior worth proving. A request to change only models or effort does not start verification setup.

For consequential state transitions, event interleavings, retries, cancellation, or consistency, inspect existing formal checks and their code coverage. When one needs synchronization, use [maintain-formal-verification-skill](../maintain-formal-verification-skill/SKILL.md). When none covers a meaningful risk, explain one useful property and offer [create-formal-verification-skill](../create-formal-verification-skill/SKILL.md). TLA+ suits event ordering; select another checker when it fits the property better. Do not require a model for every module.

Keep generated models, scoped lint rules, assumptions, coverage mappings, and rerun commands in the project. Connect relevant checks to its existing local and CI entrypoints within the authorized scope. Report what was actually run and what remains uncovered.
