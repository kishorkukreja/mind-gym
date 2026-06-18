# Firebase Preview and Emulator Verification

Mind Gym is still a local-first Flutter app. The normal CI workflow does not require Firebase credentials, production Firebase secrets, or live Firebase services. Firebase setup in this repository is for future Auth, Firestore, and Hosting preview work.

## Normal Pull Request Verification

`.github/workflows/flutter-ci.yml` runs on every pull request and on pushes to `main`.

It performs:

- `flutter pub get`
- `dart format --output=none --set-exit-if-changed` for Dart files changed by the pull request or push
- `flutter analyze --no-fatal-infos`
- `flutter test`
- `flutter build web --release --no-pub`

This workflow intentionally does not read Firebase secrets. Future Firebase-backed tests should use local emulators when possible so the default pull request path stays safe for forks and contributor branches.

## Firebase Emulator Suite

Use the Firebase Emulator Suite for future Firebase Authentication and Cloud Firestore tests.

Recommended local setup:

```bash
npm install -g firebase-tools
firebase login
firebase emulators:start --only auth,firestore
```

The repository's `firebase.json` reserves these local ports:

- Auth emulator: `9099`
- Firestore emulator: `8080`
- Emulator UI: `4000`

When Firebase code is added to the Flutter app, tests should point to emulator hosts instead of production services. Prefer a test-only configuration path such as:

```bash
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080
flutter test
```

For CI emulator tests later, add a separate job that installs `firebase-tools`, starts the emulators, waits for the ports to become available, and runs only the Firebase-backed test suite. Keep that job independent from the normal Flutter checks unless the emulator setup becomes required app infrastructure.

## Firebase Hosting Preview Channels

`.github/workflows/firebase-hosting-preview.yml` builds the Flutter web app and deploys it to a Firebase Hosting preview channel for same-repository pull requests when preview credentials are configured.

Required repository configuration:

- Repository variable `FIREBASE_PROJECT_ID`: Firebase project ID used for preview hosting.
- Repository secret `FIREBASE_SERVICE_ACCOUNT_MIND_GYM`: JSON service account for preview deploys.

The service account should be scoped to preview deployment needs. Do not use a broad production owner key.

The preview workflow runs only for pull requests whose source branch is in `kishorkukreja/mind-gym`. Pull requests from forks are skipped so secrets are not exposed. If either Firebase setting is missing, the workflow still builds Flutter web and then records a skip message instead of failing the normal verification path.

Preview channels use:

```text
pr-<pull-request-number>
```

Preview channels expire after seven days. Re-running the workflow refreshes the channel.

## Rebase Guidance for Existing Pull Requests

After this CI baseline is merged into `main`, existing open pull requests should rebase onto the updated main branch:

```bash
git fetch origin
git checkout <existing-pr-branch>
git rebase origin/main
git push --force-with-lease
```

After the rebase, GitHub will run the new Flutter CI workflow on the pull request. If the branch is in the main repository and Firebase preview secrets are configured, the Firebase Hosting preview workflow can also publish a preview channel. Forked pull requests should rely on the normal Flutter CI checks unless a maintainer reruns preview verification from a trusted branch.
