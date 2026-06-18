import 'challenge_model.dart';

enum DebateDifficultyPreference {
  inherit,
  beginner,
  intermediate,
  advanced;

  static DebateDifficultyPreference fromStorage(String? value) {
    return DebateDifficultyPreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => DebateDifficultyPreference.inherit,
    );
  }

  String get label {
    switch (this) {
      case DebateDifficultyPreference.inherit:
        return 'Inherit';
      case DebateDifficultyPreference.beginner:
        return 'Beginner';
      case DebateDifficultyPreference.intermediate:
        return 'Intermediate';
      case DebateDifficultyPreference.advanced:
        return 'Advanced';
    }
  }

  String get description {
    switch (this) {
      case DebateDifficultyPreference.inherit:
        return 'Match the challenge';
      case DebateDifficultyPreference.beginner:
        return 'More scaffolding';
      case DebateDifficultyPreference.intermediate:
        return 'Balanced rigor';
      case DebateDifficultyPreference.advanced:
        return 'Sharper pressure';
    }
  }

  DebateDifficulty? get explicitDifficulty {
    switch (this) {
      case DebateDifficultyPreference.inherit:
        return null;
      case DebateDifficultyPreference.beginner:
        return DebateDifficulty.beginner;
      case DebateDifficultyPreference.intermediate:
        return DebateDifficulty.intermediate;
      case DebateDifficultyPreference.advanced:
        return DebateDifficulty.advanced;
    }
  }
}

enum DebateDifficulty {
  beginner,
  intermediate,
  advanced;

  static DebateDifficulty fromChallenge(Challenge challenge) {
    if (challenge.difficulty <= 2) return DebateDifficulty.beginner;
    if (challenge.difficulty >= 4) return DebateDifficulty.advanced;
    return DebateDifficulty.intermediate;
  }

  static DebateDifficulty resolve({
    required DebateDifficultyPreference preference,
    required Challenge challenge,
  }) {
    return preference.explicitDifficulty ?? DebateDifficulty.fromChallenge(challenge);
  }

  String get label {
    switch (this) {
      case DebateDifficulty.beginner:
        return 'Beginner';
      case DebateDifficulty.intermediate:
        return 'Intermediate';
      case DebateDifficulty.advanced:
        return 'Advanced';
    }
  }

  int get minimumUserResponses {
    switch (this) {
      case DebateDifficulty.beginner:
        return 2;
      case DebateDifficulty.intermediate:
        return 3;
      case DebateDifficulty.advanced:
        return 4;
    }
  }

  String get promptGuidance {
    switch (this) {
      case DebateDifficulty.beginner:
        return 'Debate mode: Beginner. Use plain language, avoid technical terminology unless you define it, and scaffold the user toward clearer reasoning. Keep pressure constructive and ask one concrete follow-up at a time.';
      case DebateDifficulty.intermediate:
        return 'Debate mode: Intermediate. Use moderate philosophical terminology, expect clearer claims and reasons, and press the user to handle at least one serious counterargument.';
      case DebateDifficulty.advanced:
        return 'Debate mode: Advanced. Use precise philosophical terminology, demand explicit counterarguments, test hidden assumptions, and hold the user to rigorous definitions and implications.';
    }
  }

  String get completionExpectation {
    return 'At least $minimumUserResponses substantive user responses are expected before completion in this mode.';
  }
}
