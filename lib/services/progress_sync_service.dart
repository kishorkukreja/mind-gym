import '../models/user_model.dart';
import '../models/user_progress_snapshot.dart';
import 'firestore_progress_repository.dart';
import 'progress_repository.dart';
import 'storage_service.dart';

export 'progress_repository.dart';

enum ProgressSyncStatus { synced, localOnly, fallback }

class ProgressSyncResult {
  final ProgressSyncStatus status;
  final UserProgressSnapshot? snapshot;
  final String? error;

  const ProgressSyncResult({
    required this.status,
    this.snapshot,
    this.error,
  });
}

class ProgressSyncService {
  final ProgressRepository? _remoteRepository;

  ProgressSyncService({ProgressRepository? remoteRepository})
      : _remoteRepository = remoteRepository;

  factory ProgressSyncService.fromFirebase() {
    final repository = FirestoreProgressRepository.createIfAvailable();
    return ProgressSyncService(remoteRepository: repository);
  }

  Future<ProgressSyncResult> persistProgress(UserModel user) async {
    final snapshot = UserProgressSnapshot(
      user: user,
      challenges: StorageService.getUserChallenges(user.id),
    );
    final repository = _remoteRepository;

    if (repository == null) {
      return ProgressSyncResult(
        status: ProgressSyncStatus.localOnly,
        snapshot: snapshot,
      );
    }

    try {
      await repository.saveProgress(snapshot);
      return ProgressSyncResult(
        status: ProgressSyncStatus.synced,
        snapshot: snapshot,
      );
    } catch (error) {
      return ProgressSyncResult(
        status: ProgressSyncStatus.fallback,
        snapshot: snapshot,
        error: error.toString(),
      );
    }
  }

  Future<ProgressSyncResult> restoreProgress(String userId) async {
    final repository = _remoteRepository;

    if (repository == null) {
      return ProgressSyncResult(
        status: ProgressSyncStatus.localOnly,
        snapshot: _localSnapshot(userId),
      );
    }

    try {
      final snapshot = await repository.loadProgress(userId);
      if (snapshot == null) {
        return ProgressSyncResult(
          status: ProgressSyncStatus.localOnly,
          snapshot: _localSnapshot(userId),
        );
      }

      final restoredSnapshot = _mergeSnapshotWithLocalSecrets(snapshot, userId);
      await StorageService.saveUser(restoredSnapshot.user);
      await StorageService.saveAllUserChallenges(
        userId,
        restoredSnapshot.challenges,
      );

      return ProgressSyncResult(
        status: ProgressSyncStatus.synced,
        snapshot: restoredSnapshot,
      );
    } catch (error) {
      return ProgressSyncResult(
        status: ProgressSyncStatus.fallback,
        snapshot: _localSnapshot(userId),
        error: error.toString(),
      );
    }
  }

  UserProgressSnapshot? _localSnapshot(String userId) {
    UserModel? user;
    for (final candidate in StorageService.getAllUsers()) {
      if (candidate.id == userId) {
        user = candidate;
        break;
      }
    }
    if (user == null) return null;

    return UserProgressSnapshot(
      user: user,
      challenges: StorageService.getUserChallenges(userId),
    );
  }

  UserProgressSnapshot _mergeSnapshotWithLocalSecrets(
    UserProgressSnapshot snapshot,
    String userId,
  ) {
    final local = _localSnapshot(userId)?.user;
    if (local == null) return snapshot;

    final remote = snapshot.user;
    final mergedUser = UserModel(
      id: remote.id,
      username: remote.username.isNotEmpty ? remote.username : local.username,
      pinHash: local.pinHash,
      xp: remote.xp,
      level: remote.level,
      totalChallengesCompleted: remote.totalChallengesCompleted,
      totalChallengesSkipped: remote.totalChallengesSkipped,
      currentStreak: remote.currentStreak,
      bestStreak: remote.bestStreak,
      lastActiveDate: remote.lastActiveDate,
      completedChallengeIds: remote.completedChallengeIds,
      skippedChallengeIds: remote.skippedChallengeIds,
      weeklyStats: remote.weeklyStats,
      createdAt: remote.createdAt,
      openRouterApiKey: local.openRouterApiKey,
      weekdayHour: remote.weekdayHour,
      weekendHour: remote.weekendHour,
      weekdayChallengeDay: remote.weekdayChallengeDay,
      weekendChallengeDay: remote.weekendChallengeDay,
    );

    return UserProgressSnapshot(
      user: mergedUser,
      challenges: snapshot.challenges,
      updatedAt: snapshot.updatedAt,
    );
  }
}
