# Visual design for embedded output

Read this when a task produces a UI, prototype, diagram, chart, or interactive explanation. Apply the parts that fit the deliverable. User requirements and the project's design system govern the result. These defaults do not change scope, permissions, or acceptance criteria. For a throwaway prototype, apply only the checks needed to answer its named decision.

## Choose the output

Match the need to a diagram, UI mockup, interactive explanation, data chart, or illustration. Use the available tool or project workflow for that output. A module name in a reference does not establish that a tool exists.

## Keep embedded visuals readable

- For compact diagrams, aim for at most five words in a box subtitle, two color families, and four peer boxes per row. Wrap or split dense rows. Preserve readable text before shrinking boxes.
- When color carries meaning, include a short key. Use a neutral palette when it does not.
- Put the explanation beside a chat visual. Keep necessary labels, units, legends, and controls inside it. A standalone deliverable must retain the context its reader needs.
- Match the host's theme tokens, typography, and controls. Prefer flat surfaces and limited decoration unless the brief calls for another style.
- Use the project's icon set. Hide decorative icons from assistive technology and name icon-only controls.

## Check the actual host

Confirm the runtime's documented capabilities before using its fonts, CSS classes, libraries, or callbacks. In particular, `read_me`, `sendPrompt()`, Tabler webfonts, Anthropic Sans, and Claude's theme variables are not portable dependencies. Keep an existing valid project choice.

For an iframe that measures its content, keep overlays in normal flow and provide measurable height. For streamed HTML, put useful markup before scripts and avoid initially hidden content. Apply these restrictions only when the runtime has those behaviors.

The linked reference's 680px container, 11px type floor, 400/500 weights, and 0.5px borders describe its host. Use the target's supported tokens and accessibility requirements. Explicitly theme SVG text and shapes when the host does not supply suitable classes.

## Verify the result

Inspect the rendered output at its intended width and a narrow width. Exercise the controls and check keyboard focus, readable labels, and supported light and dark themes. Judge against the agreed brief, not a count of decorative rules.

## Source

Adapted from [Unicorn's visual creation post](https://x.com/ohayou792/status/2116884581928296819), read on November 2, 2026. This is a third-party design reference. Its claimed internal origin is unverified. The host-specific restrictions above are conditional adaptations, not verified platform policy.
