import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';

void main() {
  test('UserChallenge persists XP breakdown details', () {
    final challenge = UserChallenge(
      id: 'uc-1',
      challengeId: 'phi_001',
      userId: 'user-1',
      scheduledFor: DateTime(2026, 6, 18, 12),
      xpEarned: 123,
      xpBreakdown: const XpBreakdown(
        totalXp: 123,
        antiFarmingTriggered: false,
        factors: [
          XpFactor(
            key: 'difficulty',
            label: 'Difficulty',
            points: 120,
            description: 'Difficulty 3 base reward.',
          ),
          XpFactor(
            key: 'hints',
            label: 'Hints used',
            points: -15,
            description: 'One hint used.',
          ),
        ],
      ),
    );

    final restored = UserChallenge.fromJson(challenge.toJson());

    expect(restored.xpBreakdown, isNotNull);
    expect(restored.xpBreakdown!.totalXp, 123);
    expect(restored.xpBreakdown!.factors, hasLength(2));
    expect(restored.xpBreakdown!.factors.last.key, 'hints');
    expect(restored.xpBreakdown!.factors.last.points, -15);
  });
}
