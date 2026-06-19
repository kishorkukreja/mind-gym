# Issue 002: Runnable and Documented

## Source

- GitHub issue: https://github.com/kishorkukreja/mind-gym/issues/2
- Parent PRD: `docs/prd-mind-gym-product-improvements.md`

## Goal

Make Mind Gym understandable and runnable for a new developer by replacing the default Flutter README, documenting setup and product direction, and fixing setup problems found while documenting.

## Requirements

- README explains what Mind Gym is, the core training loop, the current tech stack, and local-first limits.
- README includes install, run, analyze, and test commands for local Flutter development.
- README explains OpenRouter API key behavior accurately: the key is entered in-app, stored locally with the prototype user record, and powers Socratic debate responses.
- README names Firebase Authentication and Cloud Firestore as the planned backend/database direction, without implying they are implemented.
- Invalid or missing Flutter asset declarations are corrected.
- A new developer can follow the README to run the app locally.

## Existing Findings

- `README.md` is still the default Flutter starter README.
- `pubspec.yaml` declares `assets/images/`, but the repository has no `assets/images` directory.
- `assets/icons/app_icon.png` exists and is the only declared runtime asset directory needed by the current codebase.
- The app currently persists users, challenge state, weekly assignments, and OpenRouter API keys in local shared preferences.
- Firebase is not configured in this repository yet.

## Plan

1. Add a regression test that reads `pubspec.yaml` and fails when a declared Flutter asset path does not exist.
2. Run the focused test to observe the current failure for `assets/images/`.
3. Remove the invalid `assets/images/` declaration from `pubspec.yaml`.
4. Replace the README with product-focused setup and run documentation.
5. Run `flutter pub get`, `flutter test`, and `flutter analyze`.
6. Review the diff against the issue and PRD acceptance criteria.
7. Commit, push `codex/issue-002-runnable-documented`, open a draft PR linked to issue #2, and comment on the issue with verification details.

## Out of Scope

- Implementing Firebase authentication or Firestore sync.
- Changing OpenRouter provider/model behavior.
- Reworking onboarding, challenge scheduling, scoring, or debate UX beyond documentation.
- Cleaning existing text encoding issues outside the asset/setup surface.
