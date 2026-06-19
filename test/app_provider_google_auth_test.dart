import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/user_model.dart';
import 'package:mind_gym/services/app_provider.dart';
import 'package:mind_gym/services/auth_service.dart';
import 'package:mind_gym/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('creates a local Mind Gym profile for a new Google user', () async {
    final provider = AppProvider(
      googleAuthService: FakeGoogleAuthService(
        profile: const GoogleAuthProfile(
          uid: 'firebase-uid-1',
          email: 'ada@example.com',
          displayName: 'Ada Lovelace',
          photoUrl: 'https://example.com/ada.png',
        ),
      ),
    );
    await provider.init();

    final success = await provider.signInWithGoogle();

    expect(success, isTrue);
    expect(provider.currentUser, isNotNull);
    expect(provider.currentUser!.id, 'firebase-uid-1');
    expect(provider.currentUser!.username, 'Ada Lovelace');
    expect(provider.currentUser!.authProvider, AuthProvider.google);
    expect(provider.currentUser!.email, 'ada@example.com');
    expect(provider.currentUser!.photoUrl, 'https://example.com/ada.png');
    expect(StorageService.getCurrentUser()!.id, 'firebase-uid-1');
  });

  test(
    'restores an existing local profile for a returning Google user',
    () async {
      final returningUser = UserModel(
        id: 'firebase-uid-2',
        username: 'Grace Hopper',
        pinHash: '',
        authProvider: AuthProvider.google,
        email: 'grace@example.com',
        xp: 450,
        level: 4,
      );
      await StorageService.saveUser(returningUser);

      final provider = AppProvider(
        googleAuthService: FakeGoogleAuthService(
          profile: const GoogleAuthProfile(
            uid: 'firebase-uid-2',
            email: 'grace@example.com',
            displayName: 'Grace Hopper',
          ),
        ),
      );
      await provider.init();

      final success = await provider.signInWithGoogle();

      expect(success, isTrue);
      expect(provider.currentUser!.id, 'firebase-uid-2');
      expect(provider.currentUser!.xp, 450);
      expect(provider.currentUser!.level, 4);
      expect(StorageService.getAllUsers(), hasLength(1));
    },
  );

  test('keeps local PIN login working for existing local users', () async {
    await StorageService.saveUser(
      UserModel(
        id: 'local-user-1',
        username: 'local_user',
        pinHash: StorageService.hashPin('1234'),
      ),
    );
    final provider = AppProvider(
      googleAuthService: FakeGoogleAuthService(
        profile: const GoogleAuthProfile(uid: 'unused'),
      ),
    );
    await provider.init();

    final success = await provider.login('local_user', '1234');

    expect(success, isTrue);
    expect(provider.currentUser!.id, 'local-user-1');
    expect(provider.currentUser!.authProvider, AuthProvider.local);
  });

  test('surfaces Google auth errors and clears them after success', () async {
    final googleAuth = FakeGoogleAuthService(
      error: GoogleAuthException('Google sign-in was cancelled.'),
    );
    final provider = AppProvider(googleAuthService: googleAuth);
    await provider.init();

    final failed = await provider.signInWithGoogle();

    expect(failed, isFalse);
    expect(provider.error, 'Google sign-in was cancelled.');

    googleAuth
      ..error = null
      ..profile = const GoogleAuthProfile(
        uid: 'firebase-uid-3',
        email: 'alan@example.com',
        displayName: 'Alan Turing',
      );

    final succeeded = await provider.signInWithGoogle();

    expect(succeeded, isTrue);
    expect(provider.error, isNull);
    expect(provider.currentUser!.id, 'firebase-uid-3');
  });

  test('signs out of Firebase when logging out a Google user', () async {
    final googleAuth = FakeGoogleAuthService(
      profile: const GoogleAuthProfile(uid: 'firebase-uid-4'),
    );
    final provider = AppProvider(googleAuthService: googleAuth);
    await provider.init();
    await provider.signInWithGoogle();

    await provider.logout();

    expect(googleAuth.signOutCount, 1);
    expect(provider.currentUser, isNull);
    expect(StorageService.getCurrentUser(), isNull);
  });
}

class FakeGoogleAuthService implements GoogleAuthService {
  FakeGoogleAuthService({this.profile, this.error});

  GoogleAuthProfile? profile;
  GoogleAuthException? error;
  int signOutCount = 0;

  @override
  Future<GoogleAuthProfile?> signIn() async {
    if (error != null) throw error!;
    return profile;
  }

  @override
  Future<void> signOut() async {
    signOutCount++;
  }
}
