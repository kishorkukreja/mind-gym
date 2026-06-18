# Issue 032 Flutter CI and Firebase Preview Verification

## Context

Issue #32 adds cloud verification for Mind Gym pull requests so contributors are not blocked by local machines that do not have Flutter installed. The PRD identifies documented setup, Firebase-backed auth and persistence, and future test coverage around local product mechanics as near-term developer needs.

## Goals

- Run Flutter verification automatically for pull requests and pushes to `main`.
- Install Flutter in CI, restore dependencies, check formatting, run static analysis, run tests, and build Flutter web.
- Keep the normal Flutter CI path independent of production Firebase secrets.
- Prepare a Firebase Hosting preview path for same-repository pull requests once preview credentials are configured.
- Document Firebase Emulator Suite usage for future Firebase Auth and Cloud Firestore tests.
- Give existing open PRs a clear rebase path onto the CI baseline.

## Non-Goals

- Add Firebase Authentication or Cloud Firestore application code.
- Require production Firebase credentials for formatting, analysis, tests, or web builds.
- Deploy production Firebase Hosting from this issue.
- Add browser, integration, or emulator-backed tests before Firebase app code exists.

## Implementation Plan

1. Add `.github/workflows/flutter-ci.yml` for pull requests and `main` pushes.
2. Use `subosito/flutter-action@v2` with Flutter `3.35.0`, the SDK floor represented by the current lockfile, and dependency caching.
3. Run `flutter pub get`, a changed-Dart-file formatting gate, `flutter analyze`, `flutter test`, and `flutter build web --release --no-pub`.
4. Add `.github/workflows/firebase-hosting-preview.yml` as an optional same-repository pull request workflow.
5. Gate preview deployment on `FIREBASE_PROJECT_ID` and `FIREBASE_SERVICE_ACCOUNT_MIND_GYM`; skip deployment when they are absent.
6. Add `firebase.json` with Flutter web Hosting output and emulator ports for future Auth and Firestore work.
7. Document Firebase Emulator Suite setup, preview channel secrets, run conditions, and rebase guidance in `docs/firebase-preview-and-emulators.md`.
8. Verify workflow files and repository diff locally. If Flutter is not installed locally, record that CI will execute Flutter commands after the PR is opened.

## Acceptance Mapping

- Pull requests and `main` pushes run Flutter checks through `.github/workflows/flutter-ci.yml`.
- The workflow installs Flutter and restores packages with `flutter pub get`.
- The workflow checks changed Dart formatting, analyzes code, runs tests, and builds web.
- Normal Flutter CI has read-only permissions and no Firebase secret references.
- Firebase Emulator Suite usage is documented in `docs/firebase-preview-and-emulators.md`.
- Firebase Hosting preview setup is documented and implemented as an optional workflow for same-repository pull requests.
- Existing open PRs can rebase onto this branch after merge and use the new checks for verification.
