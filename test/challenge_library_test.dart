import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/services/challenge_library.dart';

void main() {
  group('ChallengeLibrary metadata', () {
    test('every challenge exposes complete product metadata', () {
      for (final challenge in ChallengeLibrary.allChallenges) {
        expect(challenge.category.trim(), isNotEmpty,
            reason: '${challenge.id} must have a category');
        expect(challenge.tags, isNotEmpty,
            reason: '${challenge.id} must have tags');
        expect(challenge.difficulty, inInclusiveRange(1, 5),
            reason: '${challenge.id} must have a 1-5 difficulty');
        expect(challenge.estimatedTimeMinutes, greaterThan(0),
            reason: '${challenge.id} must estimate session time');
        expect(challenge.typeLabel, isNotEmpty,
            reason: '${challenge.id} must have a type label');
        expect(challenge.difficultyLabel, isNotEmpty,
            reason: '${challenge.id} must have a difficulty label');
        expect(challenge.hintTiers.length, 3,
            reason: '${challenge.id} should keep three progressive hints');

        for (final variant in challenge.variants) {
          expect(variant.id, isNot(challenge.id),
              reason: '${challenge.id} variant IDs must be distinct');
          expect(variant.title.trim(), isNotEmpty);
          expect(variant.question.trim(), isNotEmpty);
        }
      }
    });

    test('bank covers all issue 11 content domains', () {
      final representedTypes =
          ChallengeLibrary.allChallenges.map((challenge) => challenge.type).toSet();

      expect(
        representedTypes,
        containsAll(<ChallengeType>{
          ChallengeType.philosophy,
          ChallengeType.cognitiveBias,
          ChallengeType.logic,
          ChallengeType.decisionTheory,
          ChallengeType.statistics,
          ChallengeType.rhetoric,
          ChallengeType.mediaLiteracy,
        }),
      );
    });

    test('bank includes prompt variants for repeated concepts', () {
      final challengesWithVariants =
          ChallengeLibrary.allChallenges.where((challenge) => challenge.variants.isNotEmpty);

      expect(challengesWithVariants, isNotEmpty);
      expect(
        challengesWithVariants.expand((challenge) => challenge.variants).length,
        greaterThanOrEqualTo(3),
      );
    });
  });

  group('weekly selection', () {
    test('returns one philosophy-style and one cognitive-bias-style challenge', () {
      final picks = ChallengeLibrary.pickWeeklyChallenges(const []);

      expect(picks, hasLength(2));
      expect(picks.any((challenge) => challenge.isPhilosophyStyle), isTrue);
      expect(picks.any((challenge) => challenge.isCognitiveBiasStyle), isTrue);
    });

    test('avoids recent challenge and variant IDs when eligible alternatives exist', () {
      final recentIds = <String>[
        ...ChallengeLibrary.getPhilosophyStyleChallenges().take(2).map((c) => c.id),
        ...ChallengeLibrary.getCognitiveBiasStyleChallenges().take(2).map((c) => c.id),
        ...ChallengeLibrary.allChallenges
            .where((challenge) => challenge.variants.isNotEmpty)
            .expand((challenge) => challenge.variants)
            .take(2)
            .map((variant) => variant.id),
      ];

      final picks = ChallengeLibrary.pickWeeklyChallenges(recentIds);

      expect(picks.any((challenge) => recentIds.contains(challenge.id)), isFalse);
      expect(
        picks.any(
          (challenge) => challenge.variantIds.any(recentIds.contains),
        ),
        isFalse,
      );
    });

    test('falls back to balanced lanes when all known IDs are recent', () {
      final allIds = ChallengeLibrary.allChallenges
          .expand((challenge) => <String>[challenge.id, ...challenge.variantIds])
          .toList();

      final picks = ChallengeLibrary.pickWeeklyChallenges(allIds);

      expect(picks, hasLength(2));
      expect(picks.any((challenge) => challenge.isPhilosophyStyle), isTrue);
      expect(picks.any((challenge) => challenge.isCognitiveBiasStyle), isTrue);
    });
  });
}
