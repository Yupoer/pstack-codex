# Audit sequential async calls

Use this prompt for a repository-wide async audit. Replace `<repository>` with the intended project.

```text
On <repository>, do a deep scan of all hot paths and fix any unnecessary sequential async function calls.

Read the current project instructions and preserve existing work. Establish observable acceptance criteria, inventory production async entry points, and trace each candidate's inputs, side effects, callers, and cancellation behavior before editing.

Overlap independent work only when doing so preserves authorization, required writes, resource ownership, and error behavior. Keep real dependencies, transactions, permission prompts, rate limits, and same-resource mutations ordered. Remember that constructing a lazy query does not start it. Do not replace every pair of awaits with Promise.all.

Make the smallest coherent changes. Add no speculative retries, fallbacks, or concurrency framework. Use deterministic behavior checks to show that sibling work starts before either result is released, required downstream work still waits, and failures remain visible. Reuse relevant existing integration tests and complete the project's applicable gates.

Review the final diff independently when available. Report audited paths, fixes, intentionally serial paths, verification, and remaining gaps. Distinguish source-based scheduling improvements from measured end-to-end latency. Claim a speedup only with comparable before-and-after measurements.

After completing the work, create a GitHub issue in the repository with the findings, delivered code links, validation evidence, and any remaining work. Follow the project's delivery workflow and verify each external write before retrying it.
```

The original request was "do a deep scan of all hot paths and fix any unnecessary sequential async functions calls". The reusable prompt keeps that outcome and makes the checks explicit.

For measured slowness, use the [Perf issue playbook](../playbooks/perf-issue.md) and its baseline requirements. An unprofiled audit establishes scheduling and correctness, not a device latency result. Issue creation above is authorized when the user runs the full prompt. Omit that paragraph for a local-only audit.
