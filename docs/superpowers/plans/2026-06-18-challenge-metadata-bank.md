# Challenge Metadata Bank Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add metadata-rich challenge content and metadata-aware weekly selection for issue #11.

**Architecture:** Extend the existing static Dart challenge model because persisted user assignments store challenge IDs only. Add metadata helpers to `ChallengeLibrary`, keep weekly scheduling in `ScheduleService`, and surface compact metadata in existing home/debate UI components.

**Tech Stack:** Flutter, Dart, `flutter_test`.

---

### Task 1: Metadata Tests

**Files:**
- Create: `test/challenge_library_test.dart`
- Modify: none

- [ ] **Step 1: Write failing tests**

Add tests that assert every challenge has tags, estimated minutes, valid difficulty, category, type label, and three hints; that all required domains are represented; that at least one challenge has variants; and that weekly selection returns one philosophy-style and one cognitive-bias-style challenge while avoiding recent IDs.

- [ ] **Step 2: Run tests to verify failure**

Run: `flutter test test/challenge_library_test.dart`
Expected: FAIL because the model lacks `tags`, `estimatedTimeMinutes`, variants, and expanded types.

### Task 2: Model And Library

**Files:**
- Modify: `lib/models/challenge_model.dart`
- Modify: `lib/services/challenge_library.dart`

- [ ] **Step 1: Extend the model**

Add challenge types for `logic`, `decisionTheory`, `statistics`, `rhetoric`, and `mediaLiteracy`; add `tags`, `estimatedTimeMinutes`, and `variants`; add helpers for type labels, difficulty labels, and metadata labels.

- [ ] **Step 2: Expand content**

Update existing challenges with tags and estimated times. Add new challenge entries across logic, decision theory, statistics, rhetoric, and media literacy, using clean ASCII punctuation.

- [ ] **Step 3: Make selection metadata-aware**

Prefer eligible pools by type, avoid recent parent and variant IDs, sort candidates by category/tag diversity before deterministic selection, and fall back to the full bank when a pool is exhausted.

- [ ] **Step 4: Run focused tests**

Run: `flutter test test/challenge_library_test.dart`
Expected: PASS.

### Task 3: Metadata UI

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Modify: `lib/screens/debate_screen.dart`

- [ ] **Step 1: Add compact metadata display**

Show type/category, difficulty label, estimated minutes, and up to two tags in existing challenge card/header space.

- [ ] **Step 2: Run widget tests**

Run: `flutter test`
Expected: PASS.

### Task 4: Verification And Publish

**Files:**
- Inspect all modified files.

- [ ] **Step 1: Run full verification**

Run: `flutter test`
Expected: PASS, or document missing local Flutter tooling if unavailable.

- [ ] **Step 2: Review diff**

Run: `git diff --check` and inspect `git diff`.

- [ ] **Step 3: Commit and publish**

Stage only issue files, commit `feat: add challenge metadata bank`, push `codex/issue-011-challenge-metadata-bank`, open a draft PR linked to #11, and comment on the issue with verification status.
