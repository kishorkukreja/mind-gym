# Issue #14 Manual Verification

## Prerequisites

1. Create or select a Firebase project.
2. Enable Authentication > Sign-in method > Google.
3. Register an Android app with package `com.mindgym.challenges`.
4. Add the debug SHA-1 certificate fingerprint for the local Android build.
5. Copy the generated Android config to `android/app/google-services.json`.
6. Register a Web app and copy its values into `lib/firebase_options.dart`.
7. Replace the placeholder Android values in `lib/firebase_options.dart`.
8. Run `flutter pub get`.

## Android Google Sign-In

1. Run `flutter run -d android`.
2. On the auth screen, tap `Continue with Google`.
3. Choose a Google account.
4. Confirm the app lands in the main Mind Gym shell.
5. Open Settings and confirm the existing `Log Out` action is visible.

Expected result: the user reaches the app and a local Mind Gym profile is created with the Firebase UID.

## Sign-Out And Profile Restoration

1. Complete Android Google Sign-In.
2. Open Settings.
3. Tap `Log Out` and confirm.
4. Tap `Continue with Google` again with the same Google account.
5. Open Progress or Home and verify the same profile state is present.

Expected result: sign-out clears the app session, and repeat sign-in restores the existing local profile instead of creating a duplicate.

## Web Google Sign-In

1. Ensure the Firebase Web app has the local development origin authorized.
2. Run `flutter run -d chrome`.
3. On the auth screen, tap `Continue with Google`.
4. Complete the popup sign-in.
5. Confirm the app lands in the main Mind Gym shell.

Expected result: Firebase Auth popup sign-in succeeds and the user reaches the app.

## Local PIN Regression

1. On the auth screen, switch to local account creation.
2. Create a username/PIN account.
3. Log out from Settings.
4. Log back in with the same username/PIN.

Expected result: the local account path still reaches the app and does not require Google or Firebase.

## Error Handling

1. Temporarily use invalid Firebase options or disable the network.
2. Tap `Continue with Google`.

Expected result: the app shows a clear snackbar error instead of silently failing.
