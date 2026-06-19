import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/models/user_model.dart';
import 'package:mind_gym/services/schedule_service.dart';
import 'package:mind_gym/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('refreshChallengeStates promotes due pending challenge to ready',
      () async {
    final now = DateTime(2026, 6, 19, 12);
    final user = _user();
    final challenge = _challenge(
      status: ChallengeStatus.pending,
      scheduledFor: now.subtract(const Duration(minutes: 1)),
    );
    await StorageService.saveUser(user);
    await StorageService.saveUserChallenge(challenge);

    await ScheduleService.refreshChallengeStates(user, now: now);

    final stored = StorageService.getUserChallenges(user.id).single;
    expect(stored.status, ChallengeStatus.ready);
    expect(user.totalChallengesSkipped, 0);
    expect(user.expiredChallengeIds, isEmpty);
  });

  test('refreshChallengeStates expires stale ready challenge once', () async {
    final now = DateTime(2026, 6, 19, 12);
    final user = _user(xp: 80, currentStreak: 3);
    final challenge = _challenge(
      status: ChallengeStatus.ready,
      scheduledFor: now.subtract(const Duration(days: 5)),
    );
    await StorageService.saveUser(user);
    await StorageService.saveUserChallenge(challenge);

    await ScheduleService.refreshChallengeStates(user, now: now);
    await ScheduleService.refreshChallengeStates(user, now: now);

    final storedUser = StorageService.getCurrentUser() ??
        StorageService.getAllUsers().firstWhere((candidate) => candidate.id == user.id);
    final storedChallenge = StorageService.getUserChallenges(user.id).single;
    expect(storedChallenge.status, ChallengeStatus.expired);
    expect(storedUser.totalChallengesSkipped, 1);
    expect(storedUser.skippedChallengeIds, isEmpty);
    expect(storedUser.expiredChallengeIds, [challenge.id]);
    expect(storedUser.xp, 30);
    expect(storedUser.currentStreak, 0);
  });

  test('getThisWeekChallenges returns persisted explicit states after restart',
      () async {
    final now = DateTime.now();
    final user = _user();
    final ready = _challenge(
      id: 'uc-ready',
      status: ChallengeStatus.pending,
      scheduledFor: now.subtract(const Duration(hours: 1)),
    );
    final expired = _challenge(
      id: 'uc-expired',
      status: ChallengeStatus.pending,
      scheduledFor: now.subtract(const Duration(days: 5)),
    );
    await StorageService.saveUser(user);
    await StorageService.setCurrentUser(user.id);
    await StorageService.saveUserChallenge(ready);
    await StorageService.saveUserChallenge(expired);
    await StorageService.saveWeeklyAssignments(user.id, {
      'week': ScheduleService.weekKey(now),
      'challenges': [ready.id, expired.id],
      'recentChallengeIds': ['phi_001', 'cog_001'],
    });

    final week = ScheduleService.getThisWeekChallenges(user);

    expect(week.map((challenge) => challenge.status), [
      ChallengeStatus.ready,
      ChallengeStatus.expired,
    ]);
  });
}

UserModel _user({int xp = 0, int currentStreak = 0}) {
  return UserModel(
    id: 'user-1',
    username: 'Ada',
    pinHash: 'hash',
    xp: xp,
    currentStreak: currentStreak,
  );
}

UserChallenge _challenge({
  String id = 'uc-1',
  required ChallengeStatus status,
  required DateTime scheduledFor,
}) {
  return UserChallenge(
    id: id,
    challengeId: id == 'uc-expired' ? 'cog_001' : 'phi_001',
    userId: 'user-1',
    status: status,
    scheduledFor: scheduledFor,
  );
}
