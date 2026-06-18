import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/services/schedule_service.dart';

void main() {
  group('ScheduleService.getCountdownToNextChallenge', () {
    test('returns the soonest pending future challenge from the supplied time',
        () {
      final now = DateTime(2026, 6, 18, 9);
      final challenges = [
        UserChallenge(
          id: 'later',
          challengeId: 'challenge-a',
          userId: 'user-1',
          status: ChallengeStatus.pending,
          scheduledFor: now.add(const Duration(hours: 8)),
        ),
        UserChallenge(
          id: 'next',
          challengeId: 'challenge-b',
          userId: 'user-1',
          status: ChallengeStatus.pending,
          scheduledFor: now.add(const Duration(hours: 2, minutes: 30)),
        ),
        UserChallenge(
          id: 'completed',
          challengeId: 'challenge-c',
          userId: 'user-1',
          status: ChallengeStatus.completed,
          scheduledFor: now.add(const Duration(minutes: 20)),
        ),
      ];

      final countdown = ScheduleService.getCountdownToNextChallenge(
        challenges,
        now: now,
      );

      expect(countdown, const Duration(hours: 2, minutes: 30));
    });

    test('returns null when no pending future challenge remains', () {
      final now = DateTime(2026, 6, 18, 9);
      final challenges = [
        UserChallenge(
          id: 'ready',
          challengeId: 'challenge-a',
          userId: 'user-1',
          status: ChallengeStatus.open,
          scheduledFor: now.subtract(const Duration(hours: 1)),
        ),
        UserChallenge(
          id: 'expired',
          challengeId: 'challenge-b',
          userId: 'user-1',
          status: ChallengeStatus.expired,
          scheduledFor: now.subtract(const Duration(days: 5)),
        ),
      ];

      final countdown = ScheduleService.getCountdownToNextChallenge(
        challenges,
        now: now,
      );

      expect(countdown, isNull);
    });
  });
}
