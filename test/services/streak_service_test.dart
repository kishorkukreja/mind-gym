import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/models/user_model.dart';
import 'package:mind_gym/services/app_provider.dart';
import 'package:mind_gym/services/schedule_service.dart';
import 'package:mind_gym/services/storage_service.dart';
import 'package:mind_gym/services/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StreakService.recordCompletion', () {
    test('updates activity streak and credits a completed week once', () {
      final user = UserModel(id: 'user-1', username: 'Ada', pinHash: 'pin');
      final monday = DateTime(2026, 6, 15, 20);
      final first = _challenge(
        id: 'first',
        userId: user.id,
        scheduledFor: monday,
        status: ChallengeStatus.completed,
      );
      final second = _challenge(
        id: 'second',
        userId: user.id,
        scheduledFor: monday.add(const Duration(days: 2)),
        status: ChallengeStatus.completed,
      );

      StreakService.recordCompletion(
        user: user,
        completedChallenge: first,
        weekChallenges: [first, second],
        now: DateTime(2026, 6, 18, 10),
      );

      expect(user.activityStreak, 1);
      expect(user.bestActivityStreak, 1);
      expect(user.currentStreak, 1);
      expect(user.weeklyCompletionStreak, 1);
      expect(user.bestWeeklyCompletionStreak, 1);
      expect(user.lastCompletedWeekKey, '2026-W25');

      StreakService.recordCompletion(
        user: user,
        completedChallenge: second,
        weekChallenges: [first, second],
        now: DateTime(2026, 6, 18, 18),
      );

      expect(user.activityStreak, 1);
      expect(user.weeklyCompletionStreak, 1);
    });

    test('continues activity streak on the following day', () {
      final user = UserModel(
        id: 'user-1',
        username: 'Ada',
        pinHash: 'pin',
        activityStreak: 2,
        bestActivityStreak: 2,
        lastActivityDate: DateTime(2026, 6, 17, 12),
      );
      final challenge = _challenge(
        id: 'today',
        userId: user.id,
        scheduledFor: DateTime(2026, 6, 18, 9),
        status: ChallengeStatus.completed,
      );

      StreakService.recordCompletion(
        user: user,
        completedChallenge: challenge,
        weekChallenges: [challenge],
        now: DateTime(2026, 6, 18, 20),
      );

      expect(user.activityStreak, 3);
      expect(user.bestActivityStreak, 3);
      expect(user.currentStreak, 3);
    });
  });

  group('StreakService.recordMissedChallenge', () {
    test('breaks weekly completion and perfect-week status transparently', () {
      final user = UserModel(
        id: 'user-1',
        username: 'Ada',
        pinHash: 'pin',
        weeklyCompletionStreak: 3,
        bestWeeklyCompletionStreak: 4,
      );
      final missed = _challenge(
        id: 'missed',
        userId: user.id,
        scheduledFor: DateTime(2026, 6, 18, 9),
        status: ChallengeStatus.expired,
      );
      final completed = _challenge(
        id: 'completed',
        userId: user.id,
        scheduledFor: DateTime(2026, 6, 20, 9),
        status: ChallengeStatus.completed,
      );

      StreakService.recordMissedChallenge(user: user);

      expect(user.weeklyCompletionStreak, 0);
      expect(user.bestWeeklyCompletionStreak, 4);
      expect(
        StreakService.getPerfectWeekStatus([
          missed,
          completed,
        ], now: DateTime(2026, 6, 20)),
        PerfectWeekStatus.broken,
      );
    });
  });

  group('missed challenge persistence', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
    });

    test('skip persists and prevents later completion awards', () async {
      final provider = AppProvider();
      await provider.register('Ada', '1234');
      final user = provider.currentUser!;
      final challenge = _challenge(
        id: 'skippable',
        userId: user.id,
        scheduledFor: DateTime.now().subtract(const Duration(hours: 1)),
        status: ChallengeStatus.open,
      )..responseCount = 3;
      await StorageService.saveUserChallenge(challenge);

      await provider.skipChallenge(challenge.id);
      final skipped = provider.getChallenge(challenge.id)!;

      expect(skipped.status, ChallengeStatus.skipped);
      expect(provider.currentUser!.totalChallengesSkipped, 1);
      expect(provider.currentUser!.weeklyCompletionStreak, 0);
      expect(provider.currentUser!.skippedChallengeIds, contains(challenge.id));

      final xp = await provider.markChallengeComplete(challenge.id);

      expect(xp, 0);
      expect(
        provider.getChallenge(challenge.id)!.status,
        ChallengeStatus.skipped,
      );
      expect(provider.currentUser!.totalChallengesCompleted, 0);
    });

    test(
      'expiry persists as expired and breaks weekly completion streak',
      () async {
        final user = UserModel(
          id: 'user-1',
          username: 'Ada',
          pinHash: 'pin',
          xp: 75,
          weeklyCompletionStreak: 2,
        );
        await StorageService.saveUser(user);
        final stale = _challenge(
          id: 'stale',
          userId: user.id,
          scheduledFor: DateTime.now().subtract(const Duration(days: 5)),
          status: ChallengeStatus.pending,
        );
        await StorageService.saveUserChallenge(stale);

        await ScheduleService.processExpiredChallenges(user);

        final storedChallenge = StorageService.getUserChallenges(
          user.id,
        ).single;
        final storedUser = StorageService.getAllUsers().single;
        expect(storedChallenge.status, ChallengeStatus.expired);
        expect(storedUser.totalChallengesSkipped, 1);
        expect(storedUser.weeklyCompletionStreak, 0);
        expect(storedUser.xp, 25);
        expect(storedUser.skippedChallengeIds, contains(stale.id));
      },
    );
  });
}

UserChallenge _challenge({
  required String id,
  required String userId,
  required DateTime scheduledFor,
  required ChallengeStatus status,
}) {
  return UserChallenge(
    id: id,
    challengeId: 'challenge-$id',
    userId: userId,
    scheduledFor: scheduledFor,
    status: status,
  );
}
