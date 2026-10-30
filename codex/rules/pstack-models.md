# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Task `model`). Alias entries in a panel list still count toward its fan-out.
# All roles use GPT-6.1 Sol with high reasoning effort.
# In Claude Code, run a `gpt-6.1-sol high` role as a visible Codex CLI in herdr, never through the Agent tool or a headless `codex exec`.
# Write the brief to a file, then run (the script prints the delegate's report):
#   powershell -NoProfile -ExecutionPolicy Bypass -File ~/.codex/pstack/pstack-delegate.ps1 -Kind codex -Name <name> -Repo <dir> -Brief <file> [-Mode write]
# The default mode is read-only, for explorers, investigators, and verifiers. Use -Mode write for code delegates. Review the report and the diff yourself.
# Codex reads this same file through ~/.codex/pstack/codex-adapter.md and uses native subagents with model gpt-6.1-sol and reasoning_effort high.
# Panel lists retain two entries and therefore two agents, both using the same model and reasoning effort.
# codex-only design model: gpt-6.1-sol high
# budget: medium (high)
feature, refactoring: gpt-6.1-sol high
bug-fix: gpt-6.1-sol high
perf-issue: gpt-6.1-sol high
hillclimb: gpt-6.1-sol high
judgment and prose: gpt-6.1-sol high
hardest tasks: gpt-6.1-sol high
how explorer: gpt-6.1-sol high
how explainer: gpt-6.1-sol high
why investigators: gpt-6.1-sol high
why synthesizer: gpt-6.1-sol high
reflect tooling: gpt-6.1-sol high
reflect judgment, divergent, synthesizer: gpt-6.1-sol high
arena runners: gpt-6.1-sol high, gpt-6.1-sol high
arena cross-judge pool: gpt-6.1-sol high, gpt-6.1-sol high
swarm workers: gpt-6.1-sol high
architect runners: gpt-6.1-sol high, gpt-6.1-sol high
interrogate reviewers: gpt-6.1-sol high, gpt-6.1-sol high
