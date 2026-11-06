# pstack in Codex

This installation is owned by Codex. Read this file once before following a pstack skill. User and project instructions take precedence over skill defaults. Preserve poteto-mode's goals, scope, autonomous execution, and observable verification while following those instructions.

## Files and updates

`~/.agents/skills/<name>` points to `~/.codex/pstack/runtime/skills/<name>`. The runtime holds a versioned copy of this fork's skills, agents, and license, with Codex-specific skill overrides from `codex/skills/`. Resolve relative links from the runtime skill's actual location. Upstream setup guides remain in the checkout for reference and are not installed. No other coding application, plugin installation, or external CLI delegation is required.

Run `~/.codex/pstack/sync-pstack.ps1 -SourceRoot <checkout>` to install the checkout's current content. Git synchronization is a separate operation. The installer preserves previous runtime versions, link targets, and changed integration files under `~/.codex/pstack/backups/`. Change maintained files in the checkout, then reinstall.

## Native tools

| Upstream wording | Codex behavior |
| --- | --- |
| `/name` | Invoke the installed skill by its discovered name, or read its `SKILL.md`. |
| Run another pstack skill | Read `../<name>/SKILL.md` from the current runtime skill. |
| `Read`, `Glob`, `Grep`, `Bash` | Use native file and shell tools. Prefer `rg` and PowerShell-safe commands on Windows. |
| `AskQuestion`, `AskUserQuestion` | Use the available user-input tool for necessary questions. |
| `TodoWrite`, todolist | Use the available planning tool or one concise local handoff. |
| `Task`, `Agent`, `generalPurpose` | Use native subagents when the current instructions authorize delegation. Use only supported tool fields. |
| `poteto-agent` | Brief a native subagent with this runtime, `skills/poteto-mode/SKILL.md`, the goal, scope, and acceptance criteria. |
| `comment-sicko` | Brief a read-only native subagent with `agents/comment-sicko.md`. |
| `readonly: true` | Require inspection only and check the working tree afterward. |
| `environment: "cloud"` | Use a git worktree when isolation is needed. |
| `.cursor/skills/` | Use the project's `.agents/skills/` or the user's `~/.agents/skills/`. |
| `.cursor/rules/`, always-applied rules | Use the relevant `AGENTS.md`. Model roles have their own file below. |

## Model roles

Read `~/.codex/pstack/pstack-models.md` before the first delegation. It owns the role choices. The supplied configuration retains `gpt-6.1-sol max` for every role and two seats for panels. Use native model and reasoning-effort fields when supported.

Use only the latest released version within the selected provider's model family or tier, and only identifiers exposed by the current tools. As of 2026-11-06, the approved OpenAI versions are Luna `gpt-6-luna`, Terra `gpt-6.1-terra`, Sol `gpt-6.1-sol`, and Astra `gpt-6-astra`. Newer confirmed releases replace these dated versions. Older versions remain forbidden even if listed as available. Apply the same rule to other providers; verify new or uncertain releases against official sources. Preserve the configured provider, family, tier, effort, and panel seats.

If the latest configured model cannot run or cannot be verified, stop that call and report the limitation. Never fall back to an older version, a different provider, a shell delegate, or an opaque routing alias. An `auto`, `inherit-parent`, or omitted override is allowed only when the resolved parent/default is verified compliant. These rules override older model and fallback examples in skills and playbooks. A same-model panel is independent review, not provider diversity.

Missing role lines use the current Codex model only when it satisfies this policy. `setup-pstack` edits this Codex-owned model file. It does not write another application's settings. Background memory extraction and consolidation have separate `memories.extract_model` and `memories.consolidation_model` settings; the chat model does not configure them. Instruction rules and defaults do not provide an API-level denylist or control an internal service's unexposed model choice.

## Platform limits

Use the actual native browser, skill-creator, review, and automation tools where available. A reference to a tool or API does not make it available. For an unavailable platform step, state `Skipped in Codex: <step>. <reason>.` and continue work that does not depend on it. Do not invent verification evidence.

Cursor Custom Modes, Bugbot, cloud agents, `/loop`, and provider panels are not supplied by this installation. Scheduling requires a user request and the native automation capability. Do not start it from a playbook's suggestion alone.

For a UI, visual prototype, diagram, chart, or interactive explanation, read `runtime/skills/poteto-mode/references/visual-design.md` relative to `~/.codex/pstack/`. Apply the relevant guidance within the brief and the actual host's capabilities.
