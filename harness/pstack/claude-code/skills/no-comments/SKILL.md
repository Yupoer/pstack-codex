---
name: no-comments
description: "Review comments with Comment Sicko, remove redundant narration, preserve necessary contracts, and fix accepted clarity findings within scope."
disable-model-invocation: true
---

# No comments

In Claude Code, read [the Claude Code adapter](../../docs/harness/claude-code.md) once per session before you follow this skill. It maps the Cursor names in pstack skills to Claude Code.

Spawn Comment Sicko. Act on accepted findings.

Check Comment Sicko's findings against the code and the task's scope.

## Scope

Use the caller's files or diff. Otherwise use the current diff against the base branch, default `main`, including the working tree.

## Steps

1. Spawn `Task` with `subagent_type: "comment-sicko"`. Pass the scope. Pick each subagent's reasoning level and fast or standard speed for the job, per the Subagents section of the **poteto-mode** skill. Do not restate its rules.
2. Inspect its report and diff. Reject application-code edits, scope escapes, exception-protected deletions, and unsupported defect claims. Restore necessary comments or directives deleted without evidence. Trace ambiguous constraint claims with `/how` or `/why`; preserve them while the reason is unresolved. Report that gap.
3. Accept a rename or structural fix only when it improves clarity within the existing task. Do not create helpers, broad refactors, or redundant tests just to eliminate comments. Use **architect** only when an accepted fix genuinely needs a new shape.
4. Fix accepted owning causes within scope and run the affected checks. Preserve safeguards and suppressions until their verified replacement works. If a root cause is outside scope, retain the necessary explanation and report the remaining work.
5. For a constraint that a deterministic type, runtime check, test, or lint can enforce, follow **principle-encode-lessons-in-structure**. Encode it when the authorized scope covers the change, then prove it rejects the violation before deleting its explanation. Ask only for a consequential decision or speculative complexity outside that authorization. Keep necessary reasons that the check cannot express. A project may adopt a comment lint with explicit legal, API, external-constraint, and tool-directive exceptions.
6. Report removed narration, kept exceptions, accepted fixes and their verification, and unresolved constraints. Separate code defects from optional style suggestions.
