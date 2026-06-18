import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/models/debate_difficulty.dart';
import 'package:mind_gym/models/user_model.dart';
import 'package:mind_gym/services/openrouter_service.dart';

void main() {
  group('debate difficulty persistence', () {
    test('defaults to inherited mode for existing users', () {
      final user = UserModel.fromJson({
        'id': 'user-1',
        'username': 'Ada',
        'pinHash': 'hash',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      });

      expect(
        user.debateDifficultyPreference,
        DebateDifficultyPreference.inherit,
      );
      expect(user.toJson()['debateDifficultyPreference'], 'inherit');
    });

    test('persists explicit advanced debate difficulty preference', () {
      final user = UserModel(
        id: 'user-1',
        username: 'Ada',
        pinHash: 'hash',
        debateDifficultyPreference: DebateDifficultyPreference.advanced,
      );

      final restored = UserModel.fromJson(user.toJson());

      expect(
        restored.debateDifficultyPreference,
        DebateDifficultyPreference.advanced,
      );
    });

    test('falls back to inherit for unknown stored preference values', () {
      final user = UserModel.fromJson({
        'id': 'user-1',
        'username': 'Ada',
        'pinHash': 'hash',
        'debateDifficultyPreference': 'expert',
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
      });

      expect(
        user.debateDifficultyPreference,
        DebateDifficultyPreference.inherit,
      );
    });
  });

  group('debate difficulty inheritance', () {
    test('inherits beginner, intermediate, and advanced from challenge difficulty', () {
      expect(
        DebateDifficulty.resolve(
          preference: DebateDifficultyPreference.inherit,
          challenge: _challenge(difficulty: 2),
        ),
        DebateDifficulty.beginner,
      );
      expect(
        DebateDifficulty.resolve(
          preference: DebateDifficultyPreference.inherit,
          challenge: _challenge(difficulty: 3),
        ),
        DebateDifficulty.intermediate,
      );
      expect(
        DebateDifficulty.resolve(
          preference: DebateDifficultyPreference.inherit,
          challenge: _challenge(difficulty: 4),
        ),
        DebateDifficulty.advanced,
      );
    });

    test('explicit preference overrides challenge difficulty', () {
      expect(
        DebateDifficulty.resolve(
          preference: DebateDifficultyPreference.beginner,
          challenge: _challenge(difficulty: 5),
        ),
        DebateDifficulty.beginner,
      );
    });
  });

  group('debate difficulty completion expectations', () {
    test('uses stricter response thresholds as difficulty rises', () {
      expect(DebateDifficulty.beginner.minimumUserResponses, 2);
      expect(DebateDifficulty.intermediate.minimumUserResponses, 3);
      expect(DebateDifficulty.advanced.minimumUserResponses, 4);
    });
  });

  group('debate difficulty prompt behavior', () {
    test('beginner prompt uses accessible scaffolding and lower completion expectation', () {
      final prompt = OpenRouterService.buildSocraticSystemPrompt(
        _challenge(difficulty: 1),
        hintsUsed: 0,
        userLevel: 1,
        debateDifficulty: DebateDifficulty.beginner,
      );

      expect(prompt, contains('Debate mode: Beginner'));
      expect(prompt, contains('Use plain language'));
      expect(prompt, contains('avoid technical terminology'));
      expect(prompt, contains('At least 2 substantive user responses'));
    });

    test('intermediate prompt balances rigor and accessibility', () {
      final prompt = OpenRouterService.buildSocraticSystemPrompt(
        _challenge(difficulty: 3),
        hintsUsed: 1,
        userLevel: 5,
        debateDifficulty: DebateDifficulty.intermediate,
      );

      expect(prompt, contains('Debate mode: Intermediate'));
      expect(prompt, contains('moderate philosophical terminology'));
      expect(prompt, contains('At least 3 substantive user responses'));
    });

    test('advanced prompt increases rigor and terminology expectations', () {
      final prompt = OpenRouterService.buildSocraticSystemPrompt(
        _challenge(difficulty: 5),
        hintsUsed: 2,
        userLevel: 9,
        debateDifficulty: DebateDifficulty.advanced,
      );

      expect(prompt, contains('Debate mode: Advanced'));
      expect(prompt, contains('Use precise philosophical terminology'));
      expect(prompt, contains('demand explicit counterarguments'));
      expect(prompt, contains('At least 4 substantive user responses'));
    });
  });
}

Challenge _challenge({required int difficulty}) {
  return Challenge(
    id: 'challenge-1',
    title: 'Test Challenge',
    question: 'Should comfort ever outrank truth?',
    type: ChallengeType.philosophy,
    sourceName: 'Test',
    sourceDescription: 'A test challenge',
    hintTiers: const [
      'Consider the first-order tradeoff.',
      'Consider who pays the cost.',
      'Consider whether your rule generalizes.',
    ],
    category: 'Ethics',
    difficulty: difficulty,
    thinkingAngles: const [
      'clarity',
      'counterarguments',
      'generalization',
    ],
  );
}
