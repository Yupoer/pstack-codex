# Diagnose CI latency

Use this for a CI performance audit or an authorized optimization. An audit produces a report without changing workflows. An implementation request keeps its existing scope and approval boundaries.

## Establish the baseline

Use the connected forge tools or `gh` to inspect a representative recent window, about 150 runs when available. Group comparable workflow, trigger, runner, and revision configurations. Record the sample and missing data.

Separate waiting, setup, and task execution. Distinguish dependency waits from runner queueing. If timestamps cannot separate them, report the gap. Rank the five slowest jobs with seconds for each phase.

Also measure the elapsed path the PR waits on. Parallel job durations cannot be added to claim wall-clock savings. Tie every proposed saving to time on that path.

## Inspect the measured bottlenecks

Check these candidates where the evidence points:

- Runner availability and queue delay.
- Lint cost and equivalent rule coverage with another engine.
- Typecheck cost and diagnostic compatibility with another checker.
- Test shards, machine size, and isolated test databases.
- Repeated application imports. Change worker isolation only after proving state cleanup.
- Setup costs, cache hits and branch scope, checkout history needs, and concurrency relative to available cores.
- Unnecessary job dependencies and an overloaded final shard.
- Changed-project selection, its dependency graph, and checks that fail if required tests all skip. Retain an authorized full-suite path.
- Existing fast local checks before push. A durable hook can enforce them when hook changes are in scope.

Do not prescribe vendors, tools, cache formats, or worker settings from another repository's timings. Preserve dependency integrity, runner trust, required checks, and actual test execution.

## Use local feedback without a second pipeline

Reuse the project's existing verification commands. During edits, run affected checks. Before push, run a quick group of cheap deterministic checks and the relevant behavior tests. Keep the full relevant suite and platform-specific gates in CI. Centralize command definitions so local and remote invocations cannot drift; do not maintain a separate imitation of the workflow.

Keep valid results while the checked content, dependencies, configuration, and relevant environment are unchanged. Small checks may intentionally run in both places to verify the saved revision in a clean runner. Do not use a local success file to bypass remote required checks. Avoid running the full suite locally on every edit and then repeating it remotely without a distinct reason.

Where measurements support it, remove duplicate push and PR executions and cancel superseded verification runs for the same PR. Preserve release jobs and distinct event requirements. These are changes to the owning workflow within the authorized scope, not blanket defaults for every repository.

## Report and verify

For each finding, give the observed cost, supporting run, owning file and line, proposed change, and estimated saving with its assumptions. Label estimates separately from measurements. Identify added spend and reduced coverage explicitly. Obtain a decision for those changes unless existing authorization already covers them.

With implementation authorized, change one measured bottleneck, compare equivalent runs, and verify the work still ran correctly. Use the parent benchmark checklist. Stop when the agreed target is met. Do not turn retrying a slow job into the optimization.

## Sources

Adapted from [Vox's CI audit prompt](https://x.com/voxyz_ai/status/2116636332344889391) and [Owen's original CI article](https://x.com/owengretzinger/status/2116291924219060319), read on November 2, 2026. Their reported results describe their own workloads, not an expected speedup here.
