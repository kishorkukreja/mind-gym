import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';

void main() {
  test('persists completion summary data with a user challenge', () {
    final completedAt = DateTime(2026, 6, 18, 10);
    final uc = UserChallenge(
      id: 'uc-1',
      challengeId: 'challenge-1',
      userId: 'user-1',
      scheduledFor: DateTime(2026, 6, 17, 10),
      completedAt: completedAt,
      status: ChallengeStatus.completed,
      xpEarned: 130,
      completionSummary: const CompletionSummary(
        totalXp: 130,
        factors: [
          XpFactor(label: 'Difficulty', points: 120, detail: 'Hard challenge'),
          XpFactor(label: 'Hints', points: -10, detail: '1 hint used'),
        ],
        feedback: 'You made a clear argument.',
        nextStep: 'Name the strongest objection next time.',
      ),
    );

    final restored = UserChallenge.fromJson(uc.toJson());

    expect(restored.completionSummary?.totalXp, 130);
    expect(restored.completionSummary?.factors, hasLength(2));
    expect(restored.completionSummary?.factors.first.label, 'Difficulty');
    expect(restored.completionSummary?.factors.last.points, -10);
    expect(restored.completionSummary?.feedback, 'You made a clear argument.');
    expect(
      restored.completionSummary?.nextStep,
      'Name the strongest objection next time.',
    );
  });
}
