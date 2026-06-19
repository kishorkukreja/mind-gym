# Firestore Progress Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a vertical Firestore sync path that writes and restores one signed-in user's progress while preserving local fallback behavior.

**Architecture:** Keep SharedPreferences as the immediate local store. Add a serializable progress snapshot, a repository boundary for remote persistence, and a sync service that `AppProvider` calls during init, login, registration, and challenge completion.

**Tech Stack:** Flutter, Provider, SharedPreferences, Cloud Firestore through `cloud_firestore`, Firebase availability detection through `firebase_core`, Flutter unit tests with fakes.

---

### Task 1: Spec And Dependencies

**Files:**
- Create: `docs/specs/issue-015-firestore-progress-sync.md`
- Modify: `pubspec.yaml`

- [x] **Step 1: Write issue spec**

Document issue context, Firestore shape, fallback behavior, acceptance mapping, and out-of-scope items.

- [ ] **Step 2: Add Firebase dependencies**

Run: `flutter pub add firebase_core cloud_firestore`

Expected: `pubspec.yaml` and `pubspec.lock` include Firebase packages.

### Task 2: Progress Snapshot Tests

**Files:**
- Create: `test/services/progress_sync_service_test.dart`
- Create: `lib/models/user_progress_snapshot.dart`

- [ ] **Step 1: Write the failing serialization/write test**

Create a fake repository, a user with XP/streak/completed IDs, and one completed challenge with conversation history. Call `ProgressSyncService.persistProgress` and assert the fake repository received the complete snapshot.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/services/progress_sync_service_test.dart`

Expected: FAIL because progress sync classes do not exist.

- [ ] **Step 3: Implement minimal snapshot and service surface**

Add `UserProgressSnapshot`, `ProgressRepository`, `ProgressSyncService`, and `ProgressSyncResult`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/services/progress_sync_service_test.dart`

Expected: PASS for the write test.

### Task 3: Restore And Fallback Tests

**Files:**
- Modify: `test/services/progress_sync_service_test.dart`
- Modify: `lib/services/progress_sync_service.dart`
- Modify: `lib/services/storage_service.dart`

- [ ] **Step 1: Write restore test**

Seed mocked SharedPreferences, have the fake repository return a remote snapshot, call `restoreProgress`, and assert `StorageService.getCurrentUser()` plus `StorageService.getUserChallenges(user.id)` reflect remote data.

- [ ] **Step 2: Write failure fallback test**

Have the fake repository throw during persist and restore. Assert local data remains available and the result status is `fallback`.

- [ ] **Step 3: Run tests to verify expected failures**

Run: `flutter test test/services/progress_sync_service_test.dart`

Expected: FAIL until restore and fallback code exists.

- [ ] **Step 4: Implement restore and fallback**

Save remote snapshots into `StorageService.saveUser` and `StorageService.saveAllUserChallenges`. Catch remote errors and return diagnostic result objects without clearing local storage.

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/services/progress_sync_service_test.dart`

Expected: PASS.

### Task 4: AppProvider Integration Tests

**Files:**
- Create: `test/services/app_provider_progress_sync_test.dart`
- Modify: `lib/services/app_provider.dart`

- [ ] **Step 1: Write completion sync test**

Register a user, force an open challenge through local storage, call `markChallengeComplete`, and assert the injected fake sync service received a snapshot with earned XP, updated streak, completed status, and history.

- [ ] **Step 2: Write init restore test**

Seed current user locally, have injected sync service restore a remote snapshot, call `AppProvider.init`, and assert provider state uses restored XP/challenge state.

- [ ] **Step 3: Run tests to verify expected failures**

Run: `flutter test test/services/app_provider_progress_sync_test.dart`

Expected: FAIL until provider accepts an injected sync service and calls it.

- [ ] **Step 4: Integrate provider**

Add constructor injection for `ProgressSyncService`, expose `progressSyncStatus`/`progressSyncError`, call restore in `init` and `login`, and call persist after register, completion, API key updates, and schedule updates.

- [ ] **Step 5: Run provider tests**

Run: `flutter test test/services/app_provider_progress_sync_test.dart`

Expected: PASS.

### Task 5: Firestore Repository

**Files:**
- Create: `lib/services/firestore_progress_repository.dart`
- Modify: `lib/services/progress_sync_service.dart`

- [ ] **Step 1: Implement Firestore repository**

Write snapshots to `users/{userId}/progress/current` with `set`, and restore with `get`. Parse snapshot JSON through `UserProgressSnapshot.fromJson`.

- [ ] **Step 2: Wire default service**

`ProgressSyncService.fromFirebase()` uses `FirestoreProgressRepository` only when `Firebase.apps.isNotEmpty`; otherwise it returns local-only mode.

- [ ] **Step 3: Run focused tests**

Run: `flutter test test/services`

Expected: PASS.

### Task 6: Full Verification And Publish

**Files:**
- All changed files

- [ ] **Step 1: Format**

Run: `dart format lib test`

- [ ] **Step 2: Analyze**

Run: `flutter analyze`

- [ ] **Step 3: Test**

Run: `flutter test`

- [ ] **Step 4: Manual verification doc update**

Add setup/manual verification notes to the issue spec if real Firestore cannot be exercised in this environment.

- [ ] **Step 5: Review diff**

Run: `git diff --check`, `git diff --stat`, and inspect the diff for unrelated changes.

- [ ] **Step 6: Commit, push, and draft PR**

Stage scoped files, commit, push `codex/issue-015-firestore-progress-sync`, open a draft PR linked to #15, and comment on the issue with verification status.
