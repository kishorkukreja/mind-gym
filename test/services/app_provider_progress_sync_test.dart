import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/models/user_model.dart';
import 'package:mind_gym/models/user_progress_snapshot.dart';
import 'package:mind_gym/services/app_provider.dart';
import 'package:mind_gym/services/progress_sync_service.dart';
import 'package:mind_gym/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FakeProgressRepository repository;
  late ProgressSyncService syncService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    repository = FakeProgressRepository();
    syncService = ProgressSyncService(remoteRepository: repository);
  });

  test('markChallengeComplete syncs updated progress after local completion',
      () async {
    final provider = AppProvider(progressSyncService: syncService);
    final registerError = await provider.register('kish', '1234');
    expect(registerError, isNull);

    final challengeId = provider.weekChallenges.first.id;
    final xpEarned = await provider.markChallengeComplete(challengeId);

    expect(xpEarned, greaterThan(0));
    expect(repository.savedSnapshot, isNotNull);
    expect(repository.savedSnapshot!.user.xp, xpEarned);
    expect(repository.savedSnapshot!.user.currentStreak, 1);
    expect(repository.savedSnapshot!.user.completedChallengeIds,
        contains(challengeId));
    expect(
      repository.savedSnapshot!.challenges
          .firstWhere((challenge) => challenge.id == challengeId)
          .status,
      ChallengeStatus.completed,
    );
  });

  test('init restores remote progress before provider loads challenges',
      () async {
    final localUser = UserModel(
      id: 'user-1',
      username: 'kish',
      pinHash: StorageService.hashPin('1234'),
    );
    final remoteUser = UserModel(
      id: 'user-1',
      username: 'kish',
      pinHash: StorageService.hashPin('1234'),
      xp: 360,
      currentStreak: 2,
      completedChallengeIds: ['uc-remote'],
    );
    final remoteChallenge = UserChallenge(
      id: 'uc-remote',
      challengeId: 'challenge-remote',
      userId: 'user-1',
      status: ChallengeStatus.completed,
      scheduledFor: DateTime.utc(2026, 6, 17),
      completedAt: DateTime.utc(2026, 6, 18),
      xpEarned: 160,
    );
    repository.snapshotToLoad = UserProgressSnapshot(
      user: remoteUser,
      challenges: [remoteChallenge],
      updatedAt: DateTime.utc(2026, 6, 18, 11),
    );

    await StorageService.saveUser(localUser);
    await StorageService.setCurrentUser(localUser.id);

    final provider = AppProvider(progressSyncService: syncService);
    await provider.init();

    expect(provider.currentUser!.xp, 360);
    expect(provider.currentUser!.currentStreak, 2);
    expect(provider.getAllUserChallenges()
        .any((challenge) => challenge.id == 'uc-remote'), isTrue);
  });
}

class FakeProgressRepository implements ProgressRepository {
  UserProgressSnapshot? savedSnapshot;
  UserProgressSnapshot? snapshotToLoad;

  @override
  Future<void> saveProgress(UserProgressSnapshot snapshot) async {
    savedSnapshot = snapshot;
  }

  @override
  Future<UserProgressSnapshot?> loadProgress(String userId) async {
    return snapshotToLoad;
  }
}
