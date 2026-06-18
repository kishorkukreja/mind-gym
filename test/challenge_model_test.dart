import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';

void main() {
  test('stores debate evaluation metadata with a user challenge', () {
    final evaluation = DebateEvaluation(
      reasoningDepth: 4,
      clarity: 5,
      counterargumentHandling: 3,
      selfCorrection: 4,
      specificity: 4,
      originality: 3,
      intellectualHonesty: 5,
      completionReadiness: true,
      summary: 'Clear argument with honest limits.',
    );
    final userChallenge = UserChallenge(
      id: 'uc-1',
      challengeId: 'challenge-1',
      userId: 'user-1',
      scheduledFor: DateTime(2026, 6, 18),
      evaluation: evaluation,
      qualityScore: evaluation.qualityScore,
    );

    final restored = UserChallenge.fromJson(userChallenge.toJson());

    expect(restored.evaluation, isNotNull);
    expect(restored.evaluation!.reasoningDepth, 4);
    expect(restored.evaluation!.completionReadiness, isTrue);
    expect(restored.evaluation!.qualityScore, 4);
    expect(restored.qualityScore, 4);
    expect(restored.canComplete, isTrue);
  });
}
