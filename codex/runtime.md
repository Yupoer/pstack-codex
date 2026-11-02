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

Read `~/.codex/pstack/pstack-models.md` before the first delegation. It owns the role choices. The supplied configuration retains `gpt-6.1-sol high` for every role and two seats for panels. Use native model and reasoning-effort fields when supported. An `auto` or `inherit-parent` role uses the parent model.

Use only models exposed by the current tools. Upstream provider-specific defaults do not authorize another provider, a shell-based delegate, or a hidden CLI process. If a configured model cannot run, use the current model and state the limitation. A same-model panel is independent review, not provider diversity. Keep its requested seat count.

Missing role lines use the current Codex model. `setup-pstack` edits this Codex-owned model file. It does not write another application's settings.

## Platform limits

Use the actual native browser, skill-creator, review, and automation tools where available. A reference to a tool or API does not make it available. For an unavailable platform step, state `Skipped in Codex: <step>. <reason>.` and continue work that does not depend on it. Do not invent verification evidence.

Cursor Custom Modes, Bugbot, cloud agents, `/loop`, and provider panels are not supplied by this installation. Scheduling requires a user request and the native automation capability. Do not start it from a playbook's suggestion alone.

For a UI, visual prototype, diagram, chart, or interactive explanation, read `runtime/skills/poteto-mode/references/visual-design.md` relative to `~/.codex/pstack/`. Apply the relevant guidance within the brief and the actual host's capabilities.
