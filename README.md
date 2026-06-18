# Mind Gym

Mind Gym is a Flutter prototype for training critical thinking through scheduled philosophy and cognitive-bias challenges. The app gives users weekly prompts, pushes them through a Socratic debate loop, and tracks progress with XP, levels, streaks, and completion history.

The current project is intentionally local-first. It is meant to validate the core habit loop before adding real accounts, cloud sync, and production persistence.

## Product Loop

1. A user registers locally with a username and PIN.
2. Mind Gym creates weekly challenge assignments from the built-in challenge bank.
3. The user opens a ready challenge and responds to the prompt.
4. If an OpenRouter API key is saved in Settings, the app sends the debate conversation to the Socratic debate engine and receives a challenging follow-up.
5. The user can request hints, continue debating, and mark the challenge complete.
6. Completion awards XP based on difficulty, hints used, response count, and whether the challenge was completed on time.
7. Progress screens summarize weekly completion, skipped challenges, XP, streaks, and level.

## Tech Stack

- Flutter and Dart
- Provider for app state
- Shared preferences for local prototype persistence
- HTTP calls to OpenRouter for AI debate responses
- `fl_chart`, `flutter_animate`, and Google Fonts for UI polish
- Generated Flutter platform projects for Android, iOS, web, Windows, macOS, and Linux

## Setup

Install Flutter 3.x with a Dart SDK compatible with `>=3.0.0 <4.0.0`, then enable the targets you want to run locally.

```bash
flutter doctor
flutter pub get
```

Use `flutter devices` to see the local targets available on your machine.

```bash
flutter devices
```

## Run Locally

Run on Chrome:

```bash
flutter run -d chrome
```

Run on Windows:

```bash
flutter run -d windows
```

Run on Android after starting an emulator or connecting a device:

```bash
flutter run -d android
```

Run on iOS or macOS from a macOS machine with Xcode installed:

```bash
flutter run -d ios
flutter run -d macos
```

Run on Linux from a Linux machine with the required Flutter desktop dependencies installed:

```bash
flutter run -d linux
```

## Test and Check

Run the automated tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

The asset declaration test verifies that every Flutter asset path declared in `pubspec.yaml` exists in the repository. This catches broken setup paths before a new developer tries to build the app.

## OpenRouter

OpenRouter powers the AI debate portion of the prototype:

- Socratic debate responses during a challenge
- A service helper also exists for AI-written weekly report prose, but the current progress screen uses local summary copy

There is no environment variable or checked-in secret for OpenRouter. Create a local user in the app, open Settings, and paste an OpenRouter API key into the OpenRouter API Key field. The key is saved with the local prototype user data through shared preferences.

If no key is saved, built-in challenge scheduling, hints, completion, and local progress still work, but AI debate calls return an in-app message asking the user to add a key.

Do not commit API keys or add them to source files.

## Firebase Direction

Firebase is the planned production backend direction, but it is not implemented or configured in this repository yet.

The intended architecture is:

- Firebase Authentication for real accounts, with Google Sign-In as the preferred account model
- Cloud Firestore for user profiles, challenge assignments, debate history, XP, streaks, settings, and saved insights
- Continued local or guest trial support so users can try a starter challenge before account setup

Until that work lands, all user data is stored locally on the device/browser profile used to run the app.

## Current Limits

- Local PIN auth is prototype-only and is not a production account system.
- Progress, OpenRouter API keys, challenge history, and settings do not sync across devices.
- Challenge content is hardcoded in Dart source rather than stored in a content service or backend.
- OpenRouter provider behavior is wired directly to the current service implementation.
- Firebase, analytics, push notifications, payments, social features, and public leaderboards are out of scope for the current foundation pass.
- Some product improvement work from `docs/prd-mind-gym-product-improvements.md` remains future work, including richer scoring, structured AI evaluation, onboarding polish, and expanded challenge metadata.

## Assets

Runtime Flutter assets are declared in `pubspec.yaml`.

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/
```

If you add another runtime asset directory, create the directory and add a matching declaration. Run `flutter test` afterward so the asset declaration test can catch missing paths.
