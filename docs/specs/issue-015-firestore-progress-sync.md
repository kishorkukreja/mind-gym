# Issue 015: Firestore Progress Sync

## Context

Issue #15 asks for the first end-to-end Firestore persistence path for a signed-in user. The signed-in path in the current codebase is still the local username/PIN `UserModel` flow because #14, Google Sign-In with Firebase Auth, is still open. Issue #6, explainable XP, is also still open, so this slice preserves the existing XP calculation and syncs the values it produces.

The PRD names Firebase Authentication and Cloud Firestore as the default production architecture for account identity and user progress. It also says the current local-first app should remain usable as a guest/local trial path.

## Scope

This slice persists one signed-in user's local progress snapshot to Firestore when Firestore is configured and available. The same snapshot restores into local storage on app init/login before weekly challenge state is loaded.

The synced snapshot includes:

- User progress totals: XP, level, completion count, skip count.
- Streak state: current streak, best streak, last active date.
- Challenge references: completed challenge IDs and skipped challenge IDs.
- Challenge history: all stored `UserChallenge` records, including status, completion time, XP earned, hints, response count, quality score, self-assessment note, and conversation messages.

## Firestore Shape

The first vertical path writes a single progress document:

`users/{userId}/progress/current`

Document fields:

- `userId`: local user ID used until Firebase Auth lands.
- `user`: progress-safe user fields from `UserModel`, excluding `pinHash` and `openRouterApiKey`.
- `challenges`: array of `UserChallenge.toJson()`.
- `updatedAt`: ISO-8601 string written by the client.

This is deliberately narrow. A later Firebase Auth issue can map `userId` to the Firebase UID or migrate the document path without changing the sync service contract.

## Fallback Behavior

Local SharedPreferences storage remains the source of immediate app state. Writes save locally first, then attempt Firestore sync. If Firestore is not configured or a write/restore fails, the app keeps local progress and exposes sync status for diagnostics/tests.

Fallback status values:

- `synced`: remote write or restore succeeded.
- `localOnly`: no remote repository is configured.
- `fallback`: remote failed and local storage is being used.

## Acceptance Mapping

- Signed-in completion writes to Firestore: `AppProvider.markChallengeComplete` saves local progress, then calls progress sync with all user challenges.
- XP/streak/status/history included: `UserProgressSnapshot` serializes progress-safe `UserModel` fields plus all `UserChallenge` records.
- Restore after restart: `AppProvider.init` and `login` call restore before loading weekly challenges.
- Local fallback: `ProgressSyncService` catches repository failures and leaves local storage intact.
- Verification: tests cover repository write payload, restore into local storage, failure fallback, and provider completion sync.

## Verification

Automated checks:

- `flutter test test/services/progress_sync_service_test.dart`
- `flutter test test/services/app_provider_progress_sync_test.dart`
- `flutter test`
- `flutter analyze`

Manual Firestore write/restore check:

1. Configure Firebase for the target platform so `Firebase.initializeApp()` succeeds.
2. Sign in with the current local username/PIN flow.
3. Complete one challenge.
4. Inspect Firestore at `users/{userId}/progress/current`.
5. Confirm `user.xp`, `user.currentStreak`, `user.bestStreak`, `user.completedChallengeIds`, and the completed challenge record are present.
6. Restart/reload the app with the same local current user.
7. Confirm the restored progress screen and completed challenge state match the Firestore document.

Manual fallback check:

1. Run the app without Firebase platform configuration, or inject a failing `ProgressRepository` in tests.
2. Complete one challenge.
3. Confirm the app keeps local progress, `progressSyncStatus` is `localOnly` or `fallback`, and the user can restart/reload with local progress intact.

Environment note from this implementation pass: the current Codex container does not have `flutter` on PATH, so Flutter test/analyze commands could not be executed locally here. The non-Flutter check `git diff --check` completed successfully.

## Out Of Scope

- Google Sign-In and Firebase Auth configuration from #14.
- Replacing the current XP model from #6.
- Multi-user remote conflict resolution.
- Remote challenge assignment generation.
- Firestore security rules.
