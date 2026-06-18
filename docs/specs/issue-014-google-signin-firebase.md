# Google Sign-In With Firebase Slice

## Issue Context

- GitHub issue: #14, "Add Google Sign-In with Firebase for one user path"
- Parent PRD: `docs/prd-mind-gym-product-improvements.md`
- Blocker reference: #13, "Prepare Firebase auth and Firestore architecture"

Issue #13 is still open and has no implementation comments or committed architecture document in this checkout. This slice therefore implements the smallest reversible Firebase Auth path that matches the PRD direction without moving all Mind Gym persistence to Firestore.

## Scope

This issue adds a first account path:

- Firebase Auth with Google Sign-In as the external identity provider.
- Android and Web as the selected Flutter platforms for this slice.
- Existing local PIN accounts remain available.
- Signed-in Google users get a local Mind Gym profile keyed by their Firebase UID.
- Existing Google profiles are restored from local storage on app restart or repeat sign-in.
- Sign-out clears both local current-user state and the Firebase session.
- Auth failures are surfaced as clear user-facing messages.

## Architecture Decisions For This Slice

- Firebase Auth is the account identity source for Google users.
- Cloud Firestore is added as a dependency because #13 names it as the production persistence target, but Firestore reads and writes are intentionally deferred.
- The local profile remains the source of truth for XP, schedule settings, challenges, API key, streaks, and progress in this first slice.
- A Google profile uses the Firebase UID as `UserModel.id`.
- `UserModel.authProvider` distinguishes local PIN profiles from Google profiles.
- `UserModel.email` and `UserModel.photoUrl` store Google account metadata when available.
- Google users do not require a PIN; their `pinHash` is empty.
- Local users continue to register and log in by username/PIN.
- Guest trial remains represented by the existing local account path until a dedicated guest mode exists.

## Firebase Configuration

The code expects real Firebase configuration to be supplied by project owners before a production build:

- `lib/firebase_options.dart` contains placeholder `FirebaseOptions` for Android and Web so the app compiles and the integration point is explicit.
- `android/app/google-services.json.example` documents the Android Firebase file location without committing secrets.
- `web/firebase-config.example.json` documents required Web app configuration fields.
- `android/build.gradle.kts` and `android/app/build.gradle.kts` apply the Google Services plugin for Android.

## User Flow

1. User taps "Continue with Google" on the auth screen.
2. App starts Firebase if it is not already initialized.
3. Google Sign-In returns a Google account and Firebase credential.
4. Firebase Auth signs in and returns a Firebase user.
5. App looks up a local `UserModel` by Firebase UID.
6. If the profile exists, the app restores it and reloads weekly challenges.
7. If no profile exists, the app creates a new local profile using Google display name or email prefix.
8. User lands in the existing main app.
9. User can sign out from settings; Firebase and local current-user state are cleared.

## Test Plan

Automated tests cover:

- Creating a local profile from a Google/Firebase user.
- Restoring an existing Google profile by Firebase UID.
- Preserving local PIN auth behavior.
- Clearing provider error state after failed auth and after success.

Manual verification covers:

- Android Google Sign-In with a real `google-services.json`.
- Web Google Sign-In with real Firebase Web options.
- Sign-out and repeat sign-in restore the same profile.
- Local username/PIN login still reaches the app.

## Out Of Scope

- Firestore sync.
- Migrating existing local users into Firebase accounts.
- Dedicated anonymous Firebase guest auth.
- iOS, macOS, Windows, and Linux Google Sign-In configuration.
- Account linking, account deletion, and multi-account switching.
