import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/models/user_model.dart';
import 'package:mind_gym/services/app_provider.dart';
import 'package:mind_gym/services/schedule_service.dart';
import 'package:mind_gym/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('openChallenge persists ready challenge as in progress', () async {
    final now = DateTime.now();
    final challenge = await _seedProviderChallenge(
      status: ChallengeStatus.ready,
      scheduledFor: now.subtract(const Duration(hours: 1)),
    );
    final provider = AppProvider();
    await provider.init();

    final didOpen = await provider.openChallenge(challenge.id);

    final stored = StorageService.getUserChallenges(
      'user-1',
    ).firstWhere((storedChallenge) => storedChallenge.id == challenge.id);
    expect(didOpen, isTrue);
    expect(stored.status, ChallengeStatus.inProgress);
    expect(stored.openedAt, isNotNull);
  });

  test('openChallenge blocks pending and terminal states', () async {
    final now = DateTime.now();
    final pending = await _seedProviderChallenge(
      id: 'uc-pending',
      status: ChallengeStatus.pending,
      scheduledFor: now.add(const Duration(hours: 1)),
      second: _challenge(
        id: 'uc-expired',
        status: ChallengeStatus.expired,
        scheduledFor: now.subtract(const Duration(days: 5)),
      ),
    );
    final provider = AppProvider();
    await provider.init();

    final openedPending = await provider.openChallenge(pending.id);
    final openedExpired = await provider.openChallenge('uc-expired');

    final stored = StorageService.getUserChallenges('user-1');
    expect(openedPending, isFalse);
    expect(openedExpired, isFalse);
    expect(
      stored.firstWhere((challenge) => challenge.id == pending.id).status,
      ChallengeStatus.pending,
    );
    expect(
      stored.firstWhere((challenge) => challenge.id == 'uc-expired').status,
      ChallengeStatus.expired,
    );
  });

  test(
    'message, hint, and complete actions do not mutate expired challenge',
    () async {
      final now = DateTime.now();
      final challenge = await _seedProviderChallenge(
        status: ChallengeStatus.expired,
        scheduledFor: now.subtract(const Duration(days: 5)),
      );
      final provider = AppProvider();
      await provider.init();

      expect(
        await provider.sendDebateMessage(challenge.id, 'My argument'),
        'Challenge is expired.',
      );
      expect(await provider.requestHint(challenge.id), 'Challenge is expired.');
      expect(await provider.markChallengeComplete(challenge.id), 0);

      final stored = StorageService.getUserChallenges(
        'user-1',
      ).firstWhere((storedChallenge) => storedChallenge.id == challenge.id);
      expect(stored.status, ChallengeStatus.expired);
      expect(stored.conversation, isEmpty);
      expect(stored.responseCount, 0);
    },
  );
}

Future<UserChallenge> _seedProviderChallenge({
  String id = 'uc-1',
  required ChallengeStatus status,
  required DateTime scheduledFor,
  UserChallenge? second,
}) async {
  final user = UserModel(
    id: 'user-1',
    username: 'Ada',
    pinHash: 'hash',
    openRouterApiKey: 'test-key',
  );
  final challenge = _challenge(
    id: id,
    status: status,
    scheduledFor: scheduledFor,
  );
  final other =
      second ??
      _challenge(
        id: 'uc-other',
        status: ChallengeStatus.pending,
        scheduledFor: DateTime.now().add(const Duration(days: 1)),
      );

  await StorageService.saveUser(user);
  await StorageService.setCurrentUser(user.id);
  await StorageService.saveUserChallenge(challenge);
  await StorageService.saveUserChallenge(other);
  await StorageService.saveWeeklyAssignments(user.id, {
    'week': ScheduleService.weekKey(DateTime.now()),
    'challenges': [challenge.id, other.id],
    'recentChallengeIds': ['phi_001', 'cog_001'],
  });
  return challenge;
}

UserChallenge _challenge({
  required String id,
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
