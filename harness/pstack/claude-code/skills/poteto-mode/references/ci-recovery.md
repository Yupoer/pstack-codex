# Diagnose CI and prove recovery

Use this for failed CI or CD, historical failure reviews, and changes to workflow gates. Keep an audit read-only unless the request also authorizes fixes or retriggers. For latency or cost analysis, use [CI performance diagnosis](../../benchmark-checklist/references/ci-performance.md).

## Define what the sample counts

State the repository, cutoff, filters, order, and unit before counting. A workflow run, a run attempt, a failed job, and an independent incident are different units. Several runs can share one cause.

A query for runs whose current conclusion is `failure` omits earlier failed attempts that later succeeded. State that limit. Exclude cancellations unless they are part of the question. Retain the selected run IDs so a later query cannot silently change the sample.

## Keep one record per failure

Record these fields in a table or structured file. Store raw evidence separately and keep credentials and private environment values out of shared reports.

- Run URL, attempt, event, branch, head SHA, and actual checkout revision. A pull-request merge revision can differ from the head SHA.
- Workflow path and revision, failing job and step, command, relevant tool versions, and the first actionable error.
- Child-process logs or artifacts when the parent only reports an exit code or an aggregate gate failure.
- Candidate recovery run and attempt, the formerly failing gate's executed result, and relevant configuration differences.
- Intervening commit or narrow diff, the proposed mechanism, the missed check, and the attribution limit.

Read the failed child job before diagnosing an aggregator such as a required-check summary. Preserve evidence before rerunning or changing the job. If logs or artifacts expired, state the gap. A commit title cannot substitute for the missing error.

## Compare the same acceptance condition

Find a later run with credible source lineage and the same relevant workflow, event, inputs, and environment. Inspect the jobs and steps. A successful workflow that skips the failed job, runs inventory only, or changes the scenario does not prove recovery.

Separate the conclusions.

- **Gate recovered.** The formerly failing acceptance condition actually executes and passes on the related later revision or attempt.
- **Fix attributed.** The logs and intervening diff explain the failed mechanism. Distinguish an isolated correction from a candidate among several commits. Use a same-surface failing-then-passing reproduction when the authorized environment supports it.
- **Unresolved.** No comparable gate passes, lineage is unclear, evidence is missing, or the later run exercises only part of the original failure.

One row can have a repaired test and an unresolved benchmark or release gate. A diagnostic improvement can make the next failure useful without repairing the product. Report both facts.

## Let the error choose the next check

| Observed failure | Inspect before changing code | Evidence that addresses it |
| --- | --- | --- |
| Workflow contract or fixture fails | Compare the checker with the actual job dependencies, inputs, and intended behavior. Assertions about comments or exact source text can outlive the contract. | A meaningful behavior or contract check passes with the changed workflow. Removing an assertion alone does not prove the replacement behavior. |
| Tests pass but changed-code coverage fails | Read uncovered changed branches and the gate's report. | Add distinct behavior cases that cover the missing requirement. Keep the threshold and avoid duplicate tests written only to raise the count. |
| Tests still target a wrapper or an older call shape | Trace the current owning implementation and external call. Check that fault injection reaches the real request after batching or API migration. | The intended fault actually occurs and the behavior check reaches the current owner. A stale mock that never intercepts the call proves nothing. |
| An upgrade check runs after all migrations | Inspect the required old schema, seed data, migration order, and the job that creates them. | Exercise the old state through the upgrade and assert the required result. Keep fresh-schema tests distinct from upgrade tests. |
| A PR contract check fails before tests start | Read the checker's required durable metadata and the saved PR state. | The required record exists and the checker accepts it. A local draft or a chat message is not persisted PR metadata. |
| Tool is installed but the wrong version runs | Read the selected executable, developer directory, runtime, and command version in the failing job. | The job explicitly selects and runs the required toolchain. Presence on disk is insufficient. |
| CLI or process collector fails before the application | Inspect the real command's output streams, child lifetime, wait or reap behavior, and collector self-check. | The collector passes its own check and then reaches the original application acceptance condition. A host-side replay alone is not application recovery. |
| Startup or readiness is intermittent | Read the readiness signal and causal log sequence. Check whether the observed state is an intermediate state. | Wait for the observable condition the test requires, then prove the affected integration passes. An added delay or retry does not establish the cause. |
| Service startup reports an occupied port | Identify which process owns the port and how that job allocates and cleans up services. | The intended service starts and the affected tests run. Do not kill unrelated processes or assume the application caused the collision. |
| A process exits with a signal or debugger error | Correlate process identity, time window, original launch, and any later replay. Inspect the first missing application milestone. | Evidence belongs to the target process and original scenario. A collector failure, debugger exit, or unrelated process signal cannot establish the application's cause. |
| Benchmark or release workflow is green after a change | Compare required jobs, worker modes, artifacts, deployment inputs, and skipped steps. | The benchmark work or release acceptance actually executes. Inventory, static checks, and unrelated green workflows prove only their own scope. |

Classify source defects, stale tests, workflow configuration, base drift, infrastructure, and nondeterminism from evidence. A failure outside the diff does not prove a stale base. Compare ancestry and check the base's actual result. Fix the owning cause within the authorized scope or report its owner and remaining evidence.

## Retry only the evidence-supported scope

Before a retrigger, check whether another attempt already completed and whether authorization covers the action. For a transient infrastructure failure, choose the smallest valid retry. A job-only retry is useful when its dependencies remain valid. Use a fresh run when dependency artifacts, event inputs, or shared setup must be rebuilt. Do not rerun a deployment with external effects merely because a CI retry would be harmless.

Keep the prior attempt and inputs. If the same failure repeats after one diagnostic retry, read the new evidence and revise the hypothesis before another attempt. A pass on the same source shows the result can vary. It does not establish a code fix or a flake rate.

## Close the loop at the owning workflow

Run the affected local check when available, then verify the relevant remote gate on the reviewed head. Read back the actual PR or release state. Separate green checks, mergeability, merge completion, installation, and deployment.

Before closing recovery, record why the failure escaped the existing checks and choose a prevention outcome: the existing check is sufficient, an existing check needs repair, one distinct check or structural constraint is missing, or no new check is justified. Tie the choice to the observed cause. Fix a selected gap within scope and prove the check catches the original violation. Infrastructure faults and tool-selection errors do not automatically require a new lint.

Promote lessons to the workflow that owns the decision. For a demonstrated repeat class, use [correct](../../correct/SKILL.md) to choose the highest useful constraint. Prefer a useful test or executable contract when the rule is deterministic. Keep judgment guidance here and link it from callers. Put project-specific run IDs, fixes, and uncertainty in the audit report rather than in a global skill. Stop adding checks once distinct requirements and credible regression risks are covered.
