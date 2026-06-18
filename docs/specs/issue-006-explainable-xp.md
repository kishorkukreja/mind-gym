# Issue 006: Explainable XP For Completed Debate

## Context

GitHub issue: https://github.com/kishorkukreja/mind-gym/issues/6

Parent PRD: `docs/prd-mind-gym-product-improvements.md`

Issue #6 is marked as blocked by #4, which is still open. This implementation keeps the current challenge states intact and limits scope to the completed debate path so it can land without redefining the full weekly state model.

## Goals

- Replace the opaque XP calculation for one completed debate with a named breakdown.
- Score completion from difficulty, hints used, timeliness, and substantive engagement.
- Limit XP farming from repeated low-effort messages.
- Persist the breakdown on `UserChallenge` so UI can show why XP was awarded.
- Preserve existing user XP totals and level progression behavior.

## Scoring Model

The completion path calculates an `XpBreakdown` with ordered factors:

- Difficulty: positive base points from challenge difficulty.
- Hints: negative adjustment for each hint used.
- Timeliness: positive on-time bonus or late penalty.
- Substantive engagement: positive points for distinct user messages with enough reasoning content.
- Anti-farming: negative adjustment/cap when the debate contains repeated or low-effort messages.

The anti-farming rule is intentionally deterministic for this local-first pass. It does not try to grade reasoning quality like a full AI evaluator. It only prevents obvious farming patterns from earning high XP.

## Persistence And UI

- `UserChallenge.xpEarned` remains the canonical numeric reward for existing progress totals.
- `UserChallenge.xpBreakdown` stores the explainable factor list for completed challenge UI.
- Existing completed challenge cards continue to show total XP.
- The completion dialog additionally shows the factor breakdown.

## Out Of Scope

- Full issue #4 state redesign.
- AI-generated structured debate evaluation.
- Long-term trend charts for quality scores.
- Backend or cross-device persistence.

## Verification

- Unit tests cover representative high-effort scoring and low-effort anti-farming.
- Model tests cover breakdown JSON persistence.
- Existing widget smoke test remains in scope.
