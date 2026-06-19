import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/models/user_model.dart';
import 'package:mind_gym/models/user_progress_snapshot.dart';
import 'package:mind_gym/services/progress_sync_service.dart';
import 'package:mind_gym/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FakeProgressRepository repository;
  late ProgressSyncService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    repository = FakeProgressRepository();
    service = ProgressSyncService(remoteRepository: repository);
  });

  test(
    'persists XP, streak, completed challenge status, and history remotely',
    () async {
      final user = _user(
        xp: 220,
        currentStreak: 3,
        bestStreak: 5,
        completedChallengeIds: ['uc-1'],
      );
      final challenge = _completedChallenge(
        xpEarned: 140,
        responseCount: 2,
        conversation: [
          ChallengeMessage(
            role: 'user',
            content: 'My first answer',
            timestamp: DateTime.utc(2026, 6, 18, 9),
          ),
          ChallengeMessage(
            role: 'assistant',
            content: 'Push the argument further.',
            timestamp: DateTime.utc(2026, 6, 18, 9, 1),
          ),
        ],
      );

      await StorageService.saveUser(user);
      await StorageService.saveUserChallenge(challenge);

      final result = await service.persistProgress(user);

      expect(result.status, ProgressSyncStatus.synced);
      expect(repository.savedSnapshot, isNotNull);
      expect(repository.savedSnapshot!.user.xp, 220);
      expect(repository.savedSnapshot!.user.currentStreak, 3);
      expect(repository.savedSnapshot!.user.bestStreak, 5);
      expect(repository.savedSnapshot!.user.completedChallengeIds, ['uc-1']);
      expect(
        repository.savedSnapshot!.challenges.single.status,
        ChallengeStatus.completed,
      );
      expect(repository.savedSnapshot!.challenges.single.xpEarned, 140);
      expect(
        repository.savedSnapshot!.challenges.single.conversation.map(
          (message) => message.content,
        ),
        [
          'My first answer',
          'Push the argument further.',
        ],
      );
    },
  );

  test('does not serialize local auth secrets into progress snapshots', () {
    final user = _user(xp: 220)..openRouterApiKey = 'sk-secret-openrouter-key';
    final snapshot = UserProgressSnapshot(
      user: user,
      challenges: [_completedChallenge()],
      updatedAt: DateTime.utc(2026, 6, 18, 12),
    );

    final userJson = snapshot.toJson()['user'] as Map<String, dynamic>;

    expect(userJson.containsKey('pinHash'), isFalse);
    expect(userJson.containsKey('openRouterApiKey'), isFalse);
  });

  test('restores remote progress into local storage', () async {
    final localUser = _user(xp: 10);
    localUser.openRouterApiKey = 'local-api-key';
    final remoteUser = _user(
      xp: 480,
      currentStreak: 4,
      bestStreak: 6,
      completedChallengeIds: ['uc-1'],
    );
    final remoteChallenge = _completedChallenge(xpEarned: 180);
    repository.snapshotToLoad = UserProgressSnapshot(
      user: remoteUser,
      challenges: [remoteChallenge],
      updatedAt: DateTime.utc(2026, 6, 18, 10),
    );

    await StorageService.saveUser(localUser);
    await StorageService.setCurrentUser(localUser.id);

    final result = await service.restoreProgress(localUser.id);

    expect(result.status, ProgressSyncStatus.synced);
    expect(StorageService.getCurrentUser()!.xp, 480);
    expect(StorageService.getCurrentUser()!.currentStreak, 4);
    expect(StorageService.getCurrentUser()!.pinHash, localUser.pinHash);
    expect(StorageService.getCurrentUser()!.openRouterApiKey, 'local-api-key');
    expect(
      StorageService.getUserChallenges(localUser.id).single.status,
      ChallengeStatus.completed,
    );
    expect(StorageService.getUserChallenges(localUser.id).single.xpEarned, 180);
  });

  test('falls back to local progress when remote persistence fails', () async {
    final user = _user(xp: 90);
    final challenge = _completedChallenge(xpEarned: 90);
    repository.errorToThrow = StateError('firestore unavailable');

    await StorageService.saveUser(user);
    await StorageService.setCurrentUser(user.id);
    await StorageService.saveUserChallenge(challenge);

    final persistResult = await service.persistProgress(user);
    final restoreResult = await service.restoreProgress(user.id);

    expect(persistResult.status, ProgressSyncStatus.fallback);
    expect(restoreResult.status, ProgressSyncStatus.fallback);
    expect(StorageService.getCurrentUser()!.xp, 90);
    expect(StorageService.getUserChallenges(user.id).single.xpEarned, 90);
    expect(persistResult.error, contains('firestore unavailable'));
  });
}

class FakeProgressRepository implements ProgressRepository {
  UserProgressSnapshot? savedSnapshot;
  UserProgressSnapshot? snapshotToLoad;
  Object? errorToThrow;

  @override
  Future<void> saveProgress(UserProgressSnapshot snapshot) async {
    final error = errorToThrow;
    if (error != null) throw error;
    savedSnapshot = snapshot;
  }

  @override
  Future<UserProgressSnapshot?> loadProgress(String userId) async {
    final error = errorToThrow;
    if (error != null) throw error;
    return snapshotToLoad;
  }
}

UserModel _user({
  int xp = 0,
  int currentStreak = 0,
  int bestStreak = 0,
  List<String>? completedChallengeIds,
}) {
  return UserModel(
    id: 'user-1',
    username: 'kish',
    pinHash: 'hash',
    xp: xp,
    level: 2,
    totalChallengesCompleted: completedChallengeIds?.length ?? 0,
    currentStreak: currentStreak,
    bestStreak: bestStreak,
    lastActiveDate: DateTime.utc(2026, 6, 18),
    completedChallengeIds: completedChallengeIds,
  );
}

UserChallenge _completedChallenge({
  int xpEarned = 120,
  int responseCount = 1,
  List<ChallengeMessage>? conversation,
}) {
  return UserChallenge(
    id: 'uc-1',
    challengeId: 'challenge-1',
    userId: 'user-1',
    status: ChallengeStatus.completed,
    scheduledFor: DateTime.utc(2026, 6, 17),
    completedAt: DateTime.utc(2026, 6, 18),
    xpEarned: xpEarned,
    responseCount: responseCount,
    conversation: conversation,
  );
}
