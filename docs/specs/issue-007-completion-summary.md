# Issue 007: Completion Summary After Debate

## Context

GitHub issue #7 asks for a completion summary after a user completes a debate challenge. The issue is blocked by #6, which asks for explainable XP factors. The current app only returns an integer XP amount from `ScheduleService.calculateXpReward` and shows a generic completion dialog.

## Requirements

- Show a completion summary instead of only a generic success dialog.
- Include total XP earned and named scoring factors.
- Include challenge-specific feedback and next-step guidance.
- Let users navigate back to home or progress from the summary.
- Persist enough summary data on completed `UserChallenge` records for later progress review.
- Add tests for completed challenge summary rendering and summary persistence serialization.

## Scope

- Add a lightweight completion summary model to `lib/models/challenge_model.dart`.
- Add an explainable XP result in `lib/services/schedule_service.dart` while preserving the existing `calculateXpReward` integer API.
- Populate and persist the completion summary in `AppProvider.markChallengeComplete`.
- Replace the old completion dialog in `DebateScreen` with a richer summary dialog.
- Add focused widget/model tests.

## Out Of Scope

- Full AI-assessed debate evaluation.
- Firebase or remote persistence.
- Historical progress screen redesign.
- Completing the broader anti-farming work from issue #6 beyond exposing the existing factor inputs.

## Acceptance Mapping

- Total XP and scoring factors: summary dialog renders `totalXp` and each persisted factor.
- Feedback/next step: summary model derives feedback from response count, hints, challenge type, and category.
- Navigation: summary dialog has Home and Progress actions.
- Persistence: `UserChallenge.toJson` and `fromJson` include `completionSummary`.
- Tests: widget test covers summary rendering; model test covers JSON round-trip.
