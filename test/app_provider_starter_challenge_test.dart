import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/services/app_provider.dart';
import 'package:mind_gym/services/challenge_library.dart';
import 'package:mind_gym/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('new registration creates one immediately available starter challenge',
      () async {
    final provider = AppProvider();

    final error = await provider.register('newthinker', '1234');

    expect(error, isNull);
    expect(provider.currentUser, isNotNull);

    final starter = provider.weekChallenges.singleWhere(
      (challenge) => challenge.challengeId == ChallengeLibrary.starterChallengeId,
    );
    expect(starter.status, ChallengeStatus.open);
    expect(starter.scheduledFor.isAfter(DateTime.now()), isFalse);

    final persisted =
        StorageService.getUserChallenges(provider.currentUser!.id).singleWhere(
      (challenge) => challenge.challengeId == ChallengeLibrary.starterChallengeId,
    );
    expect(persisted.id, starter.id);
  });

  test('guest session creates a local guest user with starter challenge',
      () async {
    final provider = AppProvider();

    await provider.startGuestSession();

    expect(provider.currentUser, isNotNull);
    expect(provider.currentUser!.username, startsWith('Guest'));
    expect(provider.weekChallenges.first.challengeId,
        ChallengeLibrary.starterChallengeId);
    expect(provider.weekChallenges.first.status, ChallengeStatus.open);
  });

  test('starter challenge can be debated, hinted, and completed offline',
      () async {
    final provider = AppProvider();
    await provider.startGuestSession();
    final starter = provider.weekChallenges.firstWhere(
      (challenge) => challenge.challengeId == ChallengeLibrary.starterChallengeId,
    );

    await provider.openChallenge(starter.id);
    final firstReply = await provider.sendDebateMessage(
      starter.id,
      'I think the strongest belief should be tested against real objections.',
    );
    final hint = await provider.requestHint(starter.id);
    final secondReply = await provider.sendDebateMessage(
      starter.id,
      'A useful test would name what evidence could change my mind.',
    );
    final xp = await provider.markChallengeComplete(starter.id);

    final completed = provider.getChallenge(starter.id)!;
    expect(firstReply, contains('starter coach'));
    expect(secondReply, contains('starter coach'));
    expect(hint, contains('Hint 1'));
    expect(completed.status, ChallengeStatus.completed);
    expect(completed.hintsUsed, 1);
    expect(completed.responseCount, 2);
    expect(completed.xpEarned, xp);
    expect(provider.currentUser!.totalChallengesCompleted, 1);
    expect(provider.currentUser!.xp, xp);
  });
}
