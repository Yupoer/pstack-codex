# pstack in Codex (CLI and ChatGPT desktop)

pstack skills are written for Cursor and carry a Claude Code adapter. Codex reads the same files that Claude Code loads, so read this file once per session before you follow any pstack skill. Where a skill says "In Claude Code, read the Claude Code adapter", read this file instead.

## One copy

Each `~/.codex/skills/<name>` for a pstack skill is a junction into the Claude Code install. `<pstack>` is the `installPath` of `pstack@cursor-plugins` in `~/.claude/plugins/installed_plugins.json`. Resolve a skill's relative links (`../<skill>/SKILL.md`, `../../docs/...`, `../../agents/...`) against `<pstack>/skills/<name>/`, not against `~/.codex`. Never edit files under `<pstack>`. They belong to Claude Code. After Claude Code updates pstack, run `~/.codex/pstack/sync-pstack.ps1`.

## Names

| pstack text | Codex |
| --- | --- |
| `/name` (Cursor) or `/pstack:name` (Claude Code) | `$pstack:name`. Codex lists these skills with the `pstack:` prefix, in the CLI and the desktop app |
| Run another pstack skill | Read `<pstack>/skills/<name>/SKILL.md` and follow it |
| `Read`, `Glob`, `Grep`, `Bash` | Native file and exec tools. Use `rg` and PowerShell-safe commands on Windows |
| `AskQuestion`, `AskUserQuestion` | The native request-user-input tool, or one concise question |
| Open a todolist, `TodoWrite` | The native plan tool |
| `Task`, `Agent` | Native subagent tool when available. Otherwise run the slices yourself in order and say review independence is reduced |
| `poteto-agent` | Native subagent whose brief starts with "read `~/.codex/pstack/codex-adapter.md`, then `<pstack>/skills/poteto-mode/SKILL.md` in full" |
| `comment-sicko` | Native read-only subagent briefed with `<pstack>/agents/comment-sicko.md` |
| `readonly: true` | Tell the subagent to inspect only, then check `git status` afterward |
| `environment: "cloud"`, worktree isolation | A git worktree on the named branch |
| `run_in_background`, `resume` | Only fields the native tool schema has. Otherwise spawn fresh with the earlier result in the brief |

## Models

Claude Code's `~/.claude/rules/pstack-models.md` is the single model config. Each role line names a model and an effort.

First check whether you run inside herdr: the environment variable `HERDR_ENV` equals `1`. The ChatGPT desktop app never has it.

- A `gpt-6.1-sol high` role always runs as a native Codex subagent with `reasoning_effort` high when the tool schema accepts it, otherwise on the current Codex model.
- Inside herdr, an `opus medium` role runs as a visible Claude Code in a new herdr tab. Write the brief to a file, then run `powershell -NoProfile -ExecutionPolicy Bypass -File ~/.codex/pstack/pstack-delegate.ps1 -Kind claude -Name <name> -Repo <dir> -Brief <file>`, adding `-Mode write` only when the role edits files. The script prints the report. Review it and any diff yourself. A panel list with both models is then a real diverse-model panel, with one delegate per entry.
- Outside herdr (the desktop app, or Codex CLI started elsewhere), never call Claude. An `opus medium` role runs as a native subagent on the model in the `# codex-only design model:` line, currently `gpt-6-astra` with `reasoning_effort` high. A panel list then pairs that model with `gpt-6.1-sol`. If the subagent tool can't set a model, run the role on the current model and say so.

## Skip in Codex

Write one line, `Skipped in Codex: <step>. <reason>.`, then continue.

- Cursor Automations, Bugbot setup, Cursor cloud agents.
- `/loop` and scheduled wakes, unless the user starts a loop with a native Codex feature.
- `deslop`, `control-ui`, `control-cli`, `create-skill` from `cursor-team-kit`. Use `skill-creator`, the native browser, or a focused self-review instead.
- Hooks and model panels across providers.
