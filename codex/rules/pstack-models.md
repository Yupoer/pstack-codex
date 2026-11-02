# pstack model configuration. One line per role. Missing roles use the current Codex model.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit Task `model`). Alias entries in a panel list still count toward its fan-out.
# All roles use GPT-6.1 Sol with high reasoning effort.
# Codex reads ~/.codex/pstack/pstack-models.md and uses native subagents.
# Use model gpt-6.1-sol and reasoning_effort high when those fields are supported.
# Panel lists retain two entries and therefore two agents, both using the same model and reasoning effort.
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
