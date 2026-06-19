# Debate Difficulty Selection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a persisted debate difficulty preference that can be inherited or explicitly set, then use the active mode in debate UI, prompt construction, and completion gating.

**Architecture:** Introduce a small model-level enum for difficulty preference and active difficulty. Persist the preference on `UserModel`, compute effective debate mode through service/helpers, and thread it from `AppProvider` into `OpenRouterService` and `DebateScreen`.

**Tech Stack:** Flutter, Dart, Provider, SharedPreferences, `flutter_test`.

---

### Task 1: Model And Persistence

**Files:**
- Create: `lib/models/debate_difficulty.dart`
- Modify: `lib/models/user_model.dart`
- Test: `test/debate_difficulty_test.dart`

- [x] **Step 1: Write failing persistence tests**

Test `UserModel` defaults to `inherit`, serializes explicit `advanced`, and tolerates legacy/malformed values by returning `inherit`.

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/debate_difficulty_test.dart`
Expected: FAIL because `debate_difficulty.dart` and `debateDifficultyPreference` do not exist yet.

- [x] **Step 3: Implement model and persistence**

Add `DebateDifficultyPreference`, `DebateDifficulty`, parsing helpers, labels, completion thresholds, and inherited-mode resolution.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/debate_difficulty_test.dart`
Expected: PASS.

### Task 2: Prompt Adaptation

**Files:**
- Modify: `lib/services/openrouter_service.dart`
- Test: `test/debate_difficulty_test.dart`

- [x] **Step 1: Write failing prompt tests**

Test beginner/intermediate/advanced prompt text includes the expected tone, terminology, rigor, and response-count expectations.

- [x] **Step 2: Run test to verify it fails**

Run: `flutter test test/debate_difficulty_test.dart`
Expected: FAIL because `OpenRouterService.buildSocraticSystemPrompt` and the difficulty parameter do not exist yet.

- [x] **Step 3: Implement prompt adaptation**

Thread `DebateDifficulty` into `getSocraticResponse` and build difficulty-specific prompt instructions.

- [ ] **Step 4: Run focused tests**

Run: `flutter test test/debate_difficulty_test.dart`
Expected: PASS.

### Task 3: Provider And Completion Gating

**Files:**
- Modify: `lib/services/app_provider.dart`
- Modify: `lib/screens/debate_screen.dart`

- [x] **Step 1: Add provider API**

Add `updateDebateDifficultyPreference`, `getActiveDebateDifficulty`, and `getCompletionResponseRequirement`.

- [x] **Step 2: Use provider API in debate**

Show active mode in the challenge header and require the difficulty-specific minimum response count before completion.

- [x] **Step 3: Pass active mode to AI service**

Pass active mode from `sendDebateMessage` into `OpenRouterService.getSocraticResponse`.

### Task 4: Settings UI

**Files:**
- Modify: `lib/screens/settings_screen.dart`

- [x] **Step 1: Add local settings state**

Track selected `DebateDifficultyPreference` from the current user.

- [x] **Step 2: Add selector UI**

Add a "Debate Difficulty" section with choices for Inherit, Beginner, Intermediate, and Advanced.

- [x] **Step 3: Persist setting**

Call provider update when the selector changes.

### Task 5: Verification And Publish

**Files:**
- All changed files.

- [ ] **Step 1: Format**

Run: `dart format lib test`

- [ ] **Step 2: Test**

Run: `flutter test`

- [ ] **Step 3: Review diff**

Run: `git diff --check` and inspect `git diff`.

- [ ] **Step 4: Commit and PR**

Stage scoped files, commit `feat: add debate difficulty selection`, push `codex/issue-010-debate-difficulty`, and open a draft PR linked to #10.
