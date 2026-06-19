# Challenge States Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make weekly challenge states explicit, persisted, and reflected consistently from storage through home, debate, and progress screens.

**Architecture:** Add explicit `ready` and `expired` states to the existing local-first challenge model, then reconcile scheduled transitions through `ScheduleService` before UI reads weekly challenges. Keep state effects idempotent by recording expired challenge IDs on the user model.

**Tech Stack:** Flutter/Dart, Provider, SharedPreferences, flutter_test.

---

### Task 1: State Model and Persistence

**Files:**
- Modify: `lib/models/challenge_model.dart`
- Modify: `lib/models/user_model.dart`
- Test: `test/challenge_state_model_test.dart`

- [ ] **Step 1: Write failing model tests**

Create tests that assert `ChallengeStatus.ready` and `ChallengeStatus.expired`
round-trip through `UserChallenge.toJson()`/`fromJson()`, and that legacy
`status: "open"` restores as `ChallengeStatus.ready`.

- [ ] **Step 2: Run model tests**

Run: `flutter test test/challenge_state_model_test.dart`
Expected: fail until the enum and legacy restoration are implemented.

- [ ] **Step 3: Implement model changes**

Replace `open` with `ready`, add `expired`, add challenge helpers
`isReady`, `isPending`, `isTerminal`, `canEnterDebate`, `expiresAt`,
`shouldBecomeReady(now)`, and `shouldExpire(now)`. Add
`expiredChallengeIds` to `UserModel` JSON with a default empty list.

- [ ] **Step 4: Rerun model tests**

Run: `flutter test test/challenge_state_model_test.dart`
Expected: pass.

### Task 2: Schedule Transitions and Progress Effects

**Files:**
- Modify: `lib/services/schedule_service.dart`
- Test: `test/challenge_state_schedule_test.dart`

- [ ] **Step 1: Write failing schedule tests**

Cover `pending -> ready`, `ready -> expired`, `pending -> expired` when stale,
and idempotent expiry progress effects on user XP, streak, skipped totals, and
`expiredChallengeIds`.

- [ ] **Step 2: Run schedule tests**

Run: `flutter test test/challenge_state_schedule_test.dart`
Expected: fail until reconciliation logic is added.

- [ ] **Step 3: Implement transition service**

Add `ScheduleService.refreshChallengeStates(user, {DateTime? now})`, call it
from `getThisWeekChallenges`, and update expiry to persist `expired` while
counting it as missed progress exactly once.

- [ ] **Step 4: Rerun schedule tests**

Run: `flutter test test/challenge_state_schedule_test.dart`
Expected: pass.

### Task 3: Provider Guards and Restart Restoration

**Files:**
- Modify: `lib/services/app_provider.dart`
- Test: `test/app_provider_challenge_state_test.dart`

- [ ] **Step 1: Write failing provider tests**

Cover opening a `ready` challenge changes it to `inProgress`, opening pending
or terminal states is blocked, terminal message/hint/complete actions are
blocked, and reload after persisted expiry restores `expired`.

- [ ] **Step 2: Run provider tests**

Run: `flutter test test/app_provider_challenge_state_test.dart`
Expected: fail until guards are implemented.

- [ ] **Step 3: Implement provider guards**

Route `refreshChallenges` through schedule reconciliation, allow debate entry
only from `ready` or `inProgress`, and prevent message/hint/completion mutation
for `pending`, `completed`, `skipped`, or `expired`.

- [ ] **Step 4: Rerun provider tests**

Run: `flutter test test/app_provider_challenge_state_test.dart`
Expected: pass.

### Task 4: Home, Debate, and Progress UI

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Modify: `lib/screens/debate_screen.dart`
- Modify: `lib/screens/progress_screen.dart`
- Test: `test/challenge_state_widget_test.dart`

- [ ] **Step 1: Write failing widget tests**

Cover home badges and CTA copy for pending, ready, in-progress, completed,
skipped, and expired. Cover debate read-only terminal copy for skipped and
expired states.

- [ ] **Step 2: Run widget tests**

Run: `flutter test test/challenge_state_widget_test.dart`
Expected: fail until UI copy and guards are implemented.

- [ ] **Step 3: Implement UI state copy**

Update card badges, CTA copy, disabled behavior, locked dialogs, terminal
debate banners, and progress missed counts to use the explicit state.

- [ ] **Step 4: Rerun widget tests**

Run: `flutter test test/challenge_state_widget_test.dart`
Expected: pass.

### Task 5: Verification and Publishing

**Files:**
- Modify only files touched by Tasks 1-4 plus docs.

- [ ] **Step 1: Format Dart code**

Run: `dart format lib test`
Expected: formatted code, or record local blocker if Dart is unavailable.

- [ ] **Step 2: Run focused checks**

Run: `flutter test test/challenge_state_model_test.dart test/challenge_state_schedule_test.dart test/app_provider_challenge_state_test.dart test/challenge_state_widget_test.dart`
Expected: pass locally when Flutter is installed, otherwise document local SDK blocker and rely on CI.

- [ ] **Step 3: Run broader checks**

Run: `flutter analyze` and `flutter test`
Expected: pass locally when Flutter is installed, otherwise document local SDK blocker and rely on CI.

- [ ] **Step 4: Independent review**

Review the diff against issue #4 acceptance criteria, verify terminal-state
guards and idempotent expiry accounting, and fix findings before publishing.

- [ ] **Step 5: Publish draft PR**

Commit scoped files, push `codex/issue-004-challenge-states-relaunch`, open a
draft PR linked to #4, and comment on issue #4 with the PR URL and verification
status.
