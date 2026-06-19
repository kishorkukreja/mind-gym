import '../models/challenge_model.dart';
import 'challenge_content_repository.dart';

class ChallengeLibrary {
  static ChallengeContentRepository _repository =
      AssetChallengeContentRepository();
  static List<Challenge>? _allChallenges;

  static Future<void> load({ChallengeContentRepository? repository}) async {
    _allChallenges = null;
    if (repository != null) {
      _repository = repository;
    }
    _allChallenges = await _repository.loadChallenges();
  }

  static bool get isLoaded => _allChallenges != null;

  static List<Challenge> get allChallenges {
    final challenges = _allChallenges;
    if (challenges == null) {
      throw StateError(
        'ChallengeLibrary.load() must be called before reading challenge content.',
      );
    }
    return challenges;
  }

  static void resetForTests() {
    _repository = AssetChallengeContentRepository();
    _allChallenges = null;
  }

  static List<Challenge> getPhilosophyChallenges() =>
      allChallenges.where((c) => c.type == ChallengeType.philosophy).toList();

  static List<Challenge> getCognitiveBiasChallenges() => allChallenges
      .where((c) => c.type == ChallengeType.cognitiveBias)
      .toList();

  static Challenge? getById(String id) {
    for (final challenge in allChallenges) {
      if (challenge.id == id) return challenge;
    }
    return null;
  }

  /// Picks two challenges for the week: one philosophy, one cognitive bias.
  /// Avoids recently used challenges, falling back when a type is exhausted.
  static List<Challenge> pickWeeklyChallenges(List<String> recentIds) {
    var philo = getPhilosophyChallenges()
        .where((c) => !recentIds.contains(c.id))
        .toList();
    var cogn = getCognitiveBiasChallenges()
        .where((c) => !recentIds.contains(c.id))
        .toList();

    if (philo.isEmpty) {
      philo = getPhilosophyChallenges();
    }
    if (cogn.isEmpty) {
      cogn = getCognitiveBiasChallenges();
    }
    if (philo.isEmpty || cogn.isEmpty) {
      throw StateError(
        'Challenge content must include at least one philosophy and one cognitive bias challenge.',
      );
    }

    philo.shuffle();
    cogn.shuffle();

    return [philo.first, cogn.first];
  }
}
