---
name: principle-encode-lessons-in-structure
description: "Apply when you catch yourself writing the same instruction a second time, or notice a recurring correction. Encode the rule as a lint, metadata flag, runtime check, or script instead of more text."
disable-model-invocation: true
---

# Encode Lessons in Structure

If the lesson needs judgment and cannot be encoded, make the instruction more prominent and add an example of the failure mode.

**Corollary:** If the fix is structural, only use the structural fix. The instruction is the symptom.

Use a file path, name, or type to carry execution context when a real constraint needs enforcement. Reuse existing conventions before introducing one. Pair the marker with a project-owned check; a name alone enforces nothing.

For example, `*.hot.ts` can identify code executed every frame or tick, with a scoped lint against temporary allocations. Keep one-time initialization separate when that makes the boundary clearer. Enable allocation restrictions only for an established performance requirement or measured bottleneck. A syntax rule can miss allocations inside called functions and does not prove the absence of GC pauses. Check the runtime behavior before claiming a gain. Other projects may enforce import or I/O boundaries instead. The game-specific suffix and allocation policy are examples, not global defaults.

Prove a new deterministic check rejects a real violation and accepts valid code. Run the same project command locally and in CI. Keep judgment calls explicit rather than disguising them as reliable lint rules.
