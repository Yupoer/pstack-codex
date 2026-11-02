---
name: setup-pstack
description: Configure pstack model roles and reasoning effort for native Codex subagents. Use when the user asks to change pstack models or budgets.
disable-model-invocation: true
---

# Set up pstack in Codex

Read [Codex runtime](../../docs/harness/codex.md) and `~/.codex/pstack/pstack-models.md`. Preserve existing choices except the roles or budget the user wants to change.

Use the current native subagent tool's supported models and effort values. Do not derive provider-specific slugs or run another provider's CLI. An `auto` or `inherit-parent` role omits the model override. Keep a panel's seat count unless the user changes it.

When the requested configuration is clear and supported, update `~/.codex/pstack/pstack-models.md` directly. Ask only for a consequential choice that the request and current configuration do not resolve. Keep plain role lines without frontmatter, using the existing role labels and comma-separated panel entries.

Read back the saved file and report the changed roles and any unsupported choice. Do not spawn agents merely to prove a configuration write. The next actual delegation verifies execution. Changes take effect when the runtime reads the model file in a new chat.
