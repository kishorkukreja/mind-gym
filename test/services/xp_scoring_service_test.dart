import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/services/xp_scoring_service.dart';

void main() {
  group('XpScoringService', () {
    test('calculates named XP factors for a substantive on-time debate', () {
      final completedAt = DateTime(2026, 6, 18, 12);
      final scheduledFor = completedAt.subtract(const Duration(hours: 20));

      final breakdown = XpScoringService.calculateBreakdown(
        difficulty: 4,
        hintsUsed: 1,
        scheduledFor: scheduledFor,
        completedAt: completedAt,
        conversation: [
          _user(
            'I think the central issue is whether outcomes or duties matter more here.',
          ),
          _assistant('Push that distinction harder.'),
          _user(
            'If I prioritize outcomes, saving five people outweighs causing one death.',
          ),
          _user(
            'The objection is that directly using someone as a means changes the moral category.',
          ),
          _user(
            'My conclusion is tentative: consequences matter, but intent and agency constrain them.',
          ),
        ],
      );

      expect(breakdown.totalXp, 237);
      expect(breakdown.antiFarmingTriggered, isFalse);
      expect(
        breakdown.factors.map((factor) => factor.key),
        containsAll(<String>[
          'difficulty',
          'hints',
          'timeliness',
          'substantive_engagement',
          'anti_farming',
        ]),
      );
      expect(
        breakdown.factors.firstWhere((factor) => factor.key == 'hints').points,
        isNegative,
      );
    });

    test('caps XP for repeated low-effort messages', () {
      final completedAt = DateTime(2026, 6, 18, 12);

      final breakdown = XpScoringService.calculateBreakdown(
        difficulty: 5,
        hintsUsed: 0,
        scheduledFor: completedAt.subtract(const Duration(minutes: 15)),
        completedAt: completedAt,
        conversation: [
          _user('ok'),
          _assistant('Say more.'),
          _user('ok'),
          _user('ok'),
          _user('ok'),
        ],
      );

      expect(breakdown.totalXp, 40);
      expect(breakdown.antiFarmingTriggered, isTrue);
      expect(
        breakdown.factors
            .firstWhere((factor) => factor.key == 'anti_farming')
            .points,
        isNegative,
      );
    });

    test('keeps anti-farming as a non-positive factor when XP floor applies', () {
      final completedAt = DateTime(2026, 6, 18, 12);

      final breakdown = XpScoringService.calculateBreakdown(
        difficulty: 1,
        hintsUsed: 3,
        scheduledFor: completedAt.subtract(const Duration(days: 5)),
        completedAt: completedAt,
        conversation: [
          _user('ok'),
          _user('ok'),
          _user('ok'),
        ],
      );

      expect(breakdown.totalXp, 10);
      expect(breakdown.antiFarmingTriggered, isTrue);
      expect(
        breakdown.factors
            .firstWhere((factor) => factor.key == 'anti_farming')
            .points,
        lessThanOrEqualTo(0),
      );
      expect(
        breakdown.factors
            .firstWhere((factor) => factor.key == 'minimum_floor')
            .points,
        isPositive,
      );
    });
  });
}

ChallengeMessage _user(String content) => ChallengeMessage(
      role: 'user',
      content: content,
      timestamp: DateTime(2026, 6, 18, 12),
    );

ChallengeMessage _assistant(String content) => ChallengeMessage(
      role: 'assistant',
      content: content,
      timestamp: DateTime(2026, 6, 18, 12),
    );
