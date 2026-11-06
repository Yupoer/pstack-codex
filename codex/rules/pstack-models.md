# Latest-version-only policy applies to every role, panel, and nested delegation.
# Current tier versions (2026-11-06): Luna gpt-6-luna; Terra gpt-6.1-terra; Sol gpt-6.1-sol; Astra gpt-6-astra.
# Use only the newest released version within the selected provider/family/tier; verify new or uncertain releases against official sources and native tool support.
# Newer confirmed releases replace these dated versions. Older versions remain forbidden even when still available.
# Apply the same rule to other providers. Never fall back to an older version or bypass this policy through auto, reserve, routing aliases, or another CLI.
# Inherit or omit an override only when the resolved model is verified compliant. If the latest cannot run or be verified, stop the affected call and report it.
# Preserve role choices, reasoning effort, and panel seats. This policy overrides conflicting skill/runtime fallback guidance; see ~/.codex/AGENTS.md.
# pstack model configuration. One line per role. Missing roles use the current Codex model.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Task `model`). Alias entries in a panel list still count toward its fan-out.
# All roles use GPT-6.1 Sol with max reasoning effort.
# Codex reads ~/.codex/pstack/pstack-models.md and uses native subagents.
# Use model gpt-6.1-sol and reasoning_effort max when those fields are supported.
# Panel lists retain two entries and therefore two agents, both using the same model and reasoning effort.
# budget: max (max)
feature, refactoring: gpt-6.1-sol max
bug-fix: gpt-6.1-sol max
perf-issue: gpt-6.1-sol max
hillclimb: gpt-6.1-sol max
judgment and prose: gpt-6.1-sol max
hardest tasks: gpt-6.1-sol max
how explorer: gpt-6.1-sol max
how explainer: gpt-6.1-sol max
why investigators: gpt-6.1-sol max
why synthesizer: gpt-6.1-sol max
reflect tooling: gpt-6.1-sol max
reflect judgment, divergent, synthesizer: gpt-6.1-sol max
arena runners: gpt-6.1-sol max, gpt-6.1-sol max
arena cross-judge pool: gpt-6.1-sol max, gpt-6.1-sol max
swarm workers: gpt-6.1-sol max
architect runners: gpt-6.1-sol max, gpt-6.1-sol max
interrogate reviewers: gpt-6.1-sol max, gpt-6.1-sol max
