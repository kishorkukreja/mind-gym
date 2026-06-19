# Issue 003 Starter Challenge Spec

## Goal

Add a first-run path where a new account or guest user understands Mind Gym and can start one starter challenge immediately, without waiting for the weekly schedule.

## Context

- Issue #3 is open and linked to `docs/prd-mind-gym-product-improvements.md`.
- Issue #3 lists #1 and #2 as blockers. Both are still open, so this slice avoids broad text cleanup and README/setup work except where starter-flow copy is new.
- The PRD calls for a local-first starter challenge, guest trial mode, explicit challenge state transitions, offline fallback behavior, and tests at service/provider boundaries.

## Product Behavior

- Unauthenticated users see concise onboarding copy on the auth screen:
  - scheduled challenges
  - debate loop
  - XP rewards
  - progress tracking
- The auth screen offers a guest start action.
- Registering a new account or starting as guest creates one persisted starter `UserChallenge` scheduled for now.
- The starter challenge appears before weekly scheduled challenges on Home.
- Opening the starter challenge uses the existing `DebateScreen`.
- Users without an OpenRouter API key still get a local Socratic fallback reply so the starter path can be debated.
- Hints and completion use the existing challenge methods.
- Completing the starter challenge awards XP, increments completed challenge progress, and persists the completed challenge locally.

## Implementation Plan

### Files

- Modify `lib/services/challenge_library.dart` to add a starter challenge and lookup helpers.
- Modify `lib/services/app_provider.dart` to create starter challenges for first-run users, create guest users, and provide offline debate replies.
- Modify `lib/screens/auth_screen.dart` to show onboarding and guest start.
- Modify `lib/screens/home_screen.dart` to label the starter challenge separately from scheduled weekly challenges.
- Add `test/app_provider_starter_challenge_test.dart` for provider-level starter path coverage.

### Tasks

1. Write failing provider tests for:
   - new registration creates a persisted starter challenge that is open immediately
   - guest session creates a guest user and starter challenge
   - starter challenge supports debate, hint, completion, and progress update without an API key
2. Run the focused test and confirm it fails because the starter API does not exist yet.
3. Add a starter challenge definition with stable id `starter_001`.
4. Add provider logic to ensure one starter challenge per user when the user has never completed or started it.
5. Add `startGuestSession()` to create a local guest user and load the starter challenge.
6. Add a local fallback debate response when no API key is configured.
7. Update auth UI onboarding and guest CTA.
8. Update home UI to surface the starter card before weekly scheduled challenges.
9. Run the focused test, then broader Flutter checks.
10. Review the diff independently, fix findings, commit, push, and open a draft PR linked to #3.

## Out Of Scope

- Full issue #1 text encoding cleanup outside changed starter-flow copy.
- Issue #2 README/setup fixes.
- Firebase, Google auth, backend sync, or analytics.
- Replacing the existing weekly scheduler.
