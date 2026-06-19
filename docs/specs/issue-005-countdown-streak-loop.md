# Issue 005 Countdown And Streak Loop

## Source Context

- GitHub issue: https://github.com/kishorkukreja/mind-gym/issues/5
- Parent PRD: `docs/prd-mind-gym-product-improvements.md`
- Blocker context: issue #4 asks for explicit weekly challenge state transitions across pending, ready, in progress, completed, skipped, and expired states.

## Goal

Improve the local-first habit loop so a user can see the next challenge countdown, understand streak risk, and see how completion, skip, or expiry affects activity streaks, weekly completion streaks, and perfect-week status.

## Scope

- Add persisted user fields for activity streak and weekly completion streak while preserving legacy `currentStreak` and `bestStreak` migration behavior.
- Add an explicit expired challenge status and route expiry through the same progress/streak update path as a skipped challenge.
- Keep countdown logic deterministic and testable by allowing an injected clock.
- Update the home screen with a clear next-challenge countdown, streak summary, and at-risk/broken messaging.
- Update the progress screen to distinguish activity streak, weekly completion streak, and perfect-week status.
- Add focused tests for countdown selection and streak updates on completion, skip, and expiry.

## Out Of Scope

- Push/local notification infrastructure.
- Firebase or multi-device persistence.
- Full issue #4 UI polish beyond the expired status needed for issue #5.
- A new scoring rubric or debate quality model.

## Data Model

- `UserModel.activityStreak`: consecutive calendar days with at least one completed challenge.
- `UserModel.bestActivityStreak`: best recorded activity streak.
- `UserModel.weeklyCompletionStreak`: consecutive weeks where all assigned challenges were completed.
- `UserModel.bestWeeklyCompletionStreak`: best recorded weekly completion streak.
- `UserModel.lastActivityDate`: most recent date that incremented activity streak.
- `UserModel.lastCompletedWeekKey`: most recent week credited for weekly completion streak.
- `ChallengeStatus.expired`: terminal status for missed challenges that aged past their active window.

Legacy fields remain:

- `currentStreak` mirrors `activityStreak`.
- `bestStreak` mirrors `bestActivityStreak`.
- `lastActiveDate` mirrors `lastActivityDate`.

## Implementation Plan

1. Add service tests in `test/services/schedule_service_test.dart` for countdown selection with an injected `now`.
2. Add service tests in `test/services/streak_service_test.dart` for completion streak updates, same-day activity de-duplication, skip breakage, and expiry processing.
3. Add `ChallengeStatus.expired` and status parsing support.
4. Extend `UserModel` JSON serialization/deserialization for the new streak fields with migration fallback from legacy fields.
5. Add `lib/services/streak_service.dart` for pure streak calculations.
6. Update `ScheduleService.getCountdownToNextChallenge` to accept `now`, ignore non-pending terminal states, and select the next pending future challenge.
7. Update `ScheduleService.processExpiredChallenges` to mark stale pending challenges as `expired`, count them as skipped, apply the XP penalty, and call the streak break path.
8. Update `AppProvider.markChallengeComplete` to persist completion, reload all user challenges, and call `StreakService.recordCompletion`.
9. Update provider accessors for streak summary, perfect-week status, and countdown copy.
10. Update home and progress UI copy to distinguish activity streak, weekly completion streak, and perfect-week status.
11. Run focused tests, `flutter test`, and `flutter analyze`.

## Acceptance Mapping

- Home screen countdown: `ScheduleService.getCountdownToNextChallenge` plus home countdown card.
- Distinct streaks in data and UI: new `UserModel` fields plus home/progress cards.
- Completion updates streak state: `StreakService.recordCompletion` from `AppProvider.markChallengeComplete`.
- Skip/expiry updates streak state: `StreakService.recordMissedChallenge` from `ScheduleService.processExpiredChallenges`.
- Tests cover countdown/streak updates: focused service tests.
