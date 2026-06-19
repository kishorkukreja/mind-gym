import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/models/user_model.dart';

void main() {
  group('ChallengeStatus persistence', () {
    test('round-trips ready and expired challenge states', () {
      final ready = _challengeWith(status: ChallengeStatus.ready);
      final expired = _challengeWith(
        id: 'uc-expired',
        status: ChallengeStatus.expired,
      );

      expect(
        UserChallenge.fromJson(ready.toJson()).status,
        ChallengeStatus.ready,
      );
      expect(
        UserChallenge.fromJson(expired.toJson()).status,
        ChallengeStatus.expired,
      );
    });

    test('restores legacy open status as ready', () {
      final json = _challengeWith(status: ChallengeStatus.ready).toJson()
        ..['status'] = 'open';

      expect(
        UserChallenge.fromJson(json).status,
        ChallengeStatus.ready,
      );
    });

    test('exposes state helpers for debate entry and terminal states', () {
      final pending = _challengeWith(status: ChallengeStatus.pending);
      final ready = _challengeWith(status: ChallengeStatus.ready);
      final inProgress = _challengeWith(status: ChallengeStatus.inProgress);
      final completed = _challengeWith(status: ChallengeStatus.completed);
      final skipped = _challengeWith(status: ChallengeStatus.skipped);
      final expired = _challengeWith(status: ChallengeStatus.expired);

      expect(pending.canEnterDebate, isFalse);
      expect(ready.canEnterDebate, isTrue);
      expect(inProgress.canEnterDebate, isTrue);
      expect(completed.isTerminal, isTrue);
      expect(skipped.isTerminal, isTrue);
      expect(expired.isTerminal, isTrue);
    });
  });

  group('UserModel expired challenge persistence', () {
    test('defaults expired challenge IDs to an empty list', () {
      final user = UserModel(
        id: 'user-1',
        username: 'Ada',
        pinHash: 'hash',
      );

      expect(user.expiredChallengeIds, isEmpty);
      expect(UserModel.fromJson(user.toJson()).expiredChallengeIds, isEmpty);
    });

    test('round-trips expired challenge IDs', () {
      final user = UserModel(
        id: 'user-1',
        username: 'Ada',
        pinHash: 'hash',
        expiredChallengeIds: ['uc-1', 'uc-2'],
      );

      expect(
        UserModel.fromJson(user.toJson()).expiredChallengeIds,
        ['uc-1', 'uc-2'],
      );
    });
  });
}

UserChallenge _challengeWith({
  String id = 'uc-1',
  required ChallengeStatus status,
}) {
  return UserChallenge(
    id: id,
    challengeId: 'phi_001',
    userId: 'user-1',
    status: status,
    scheduledFor: DateTime(2026, 6, 19, 10),
  );
}
