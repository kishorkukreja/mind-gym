# Issue 009: AI Evaluation Path

## Context

Issue #9 implements the first end-to-end debate path that captures structured AI evaluation metadata while preserving the Socratic chat experience. Issue #8 is still open, so this implementation uses the PRD-backed contract below as the local implementation contract.

## Evaluation Contract

The AI may return a hidden evaluation block after the user-facing reply. The visible reply remains normal prose. The hidden block must be wrapped exactly:

```text
<mind_gym_evaluation>
{
  "reasoningDepth": 1,
  "clarity": 1,
  "counterargumentHandling": 1,
  "selfCorrection": 1,
  "specificity": 1,
  "originality": 1,
  "intellectualHonesty": 1,
  "completionReadiness": false,
  "summary": "Short completion feedback when ready or near-ready."
}
</mind_gym_evaluation>
```

Required fields:

- `reasoningDepth`, `clarity`, `counterargumentHandling`, `selfCorrection`, `specificity`, `originality`, and `intellectualHonesty` are integers from 1 to 5.
- `completionReadiness` is a boolean that means the user has substantively wrestled with the challenge.
- `summary` is a short string used as completion feedback when available.

Invalid JSON, missing required fields, out-of-range scores, or a missing wrapper means the evaluation is ignored.

## Fallback Behavior

The debate must not fail because evaluation metadata is missing or invalid. In fallback mode:

- The assistant reply is still shown and stored.
- The app keeps using the existing minimum engagement rule of at least two user responses.
- XP uses the existing response-count depth bonus.
- The completion dialog keeps the generic summary copy.

## Completion And Scoring

When valid evaluation metadata is available:

- `completionReadiness` allows completion even if the user has fewer than two responses.
- If `completionReadiness` is false, completion remains gated until the fallback engagement threshold is met.
- `qualityScore` is the rounded average of the seven rubric scores and is stored on the user challenge.
- XP uses `qualityScore` as a reasoning-quality bonus instead of the response-count-only depth bonus.
- The completion dialog may show the structured summary when available.

## Implementation Plan

1. Add `DebateEvaluation` and `SocraticResponse` model types with JSON serialization and strict parsing.
2. Add an injectable AI client boundary for OpenRouter so tests can use a fake client.
3. Request the wrapped evaluation block in the debate system prompt.
4. Parse and strip the hidden block from the assistant message before storing the visible chat message.
5. Store valid evaluation metadata with `UserChallenge`.
6. Let completion readiness and XP consume valid evaluation metadata while preserving response-count fallback.
7. Cover success and invalid/missing fallback paths with deterministic tests.
