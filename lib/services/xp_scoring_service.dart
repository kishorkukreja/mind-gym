import '../models/challenge_model.dart';

class XpScoringService {
  static const int _minimumXp = 10;
  static const int _maximumXp = 300;
  static const int _antiFarmingCap = 40;
  static const int _onTimeWindowDays = 2;

  static XpBreakdown calculateBreakdown({
    required int difficulty,
    required int hintsUsed,
    required DateTime scheduledFor,
    required DateTime completedAt,
    required List<ChallengeMessage> conversation,
  }) {
    final normalizedDifficulty = difficulty.clamp(1, 5).toInt();
    final difficultyPoints = normalizedDifficulty * 40;
    final hintPenalty = -(hintsUsed.clamp(0, 99).toInt() * 15);
    final onTime = !completedAt.isAfter(
      scheduledFor.add(const Duration(days: _onTimeWindowDays)),
    );
    final timelinessPoints = onTime ? 20 : -20;

    final userMessages = conversation
        .where((message) => message.role == 'user')
        .map((message) => message.content)
        .toList();
    final substantiveMessages = _substantiveMessages(userMessages);
    final engagementPoints =
        substantiveMessages.length.clamp(0, 4).toInt() * 18;

    final factors = <XpFactor>[
      XpFactor(
        key: 'difficulty',
        label: 'Difficulty',
        points: difficultyPoints,
        description: 'Difficulty $normalizedDifficulty challenge base reward.',
      ),
      XpFactor(
        key: 'hints',
        label: 'Hints used',
        points: hintPenalty,
        description: hintsUsed == 0
            ? 'No hints used.'
            : '$hintsUsed hint${hintsUsed == 1 ? '' : 's'} used.',
      ),
      XpFactor(
        key: 'timeliness',
        label: 'Timeliness',
        points: timelinessPoints,
        description: onTime
            ? 'Completed within the on-time window.'
            : 'Completed after the on-time window.',
      ),
      XpFactor(
        key: 'substantive_engagement',
        label: 'Substantive engagement',
        points: engagementPoints,
        description:
            '${substantiveMessages.length} substantive response${substantiveMessages.length == 1 ? '' : 's'} counted.',
      ),
    ];

    final preliminaryTotal = factors.fold<int>(
      0,
      (total, factor) => total + factor.points,
    );
    final antiFarmingTriggered = _isFarming(userMessages, substantiveMessages);
    final cappedBeforeFloor =
        antiFarmingTriggered && preliminaryTotal > _antiFarmingCap
            ? _antiFarmingCap
            : !antiFarmingTriggered && preliminaryTotal > _maximumXp
                ? _maximumXp
                : preliminaryTotal;
    final antiFarmingAdjustment = cappedBeforeFloor - preliminaryTotal;
    final cappedTotal = cappedBeforeFloor.clamp(_minimumXp, _maximumXp).toInt();
    final minimumFloorAdjustment = cappedTotal - cappedBeforeFloor;

    factors.add(
      XpFactor(
        key: 'anti_farming',
        label: 'Anti-farming',
        points: antiFarmingAdjustment,
        description: antiFarmingTriggered
            ? 'Low-effort or repeated messages capped the reward.'
            : 'No low-effort farming pattern detected.',
      ),
    );
    if (minimumFloorAdjustment > 0) {
      factors.add(
        XpFactor(
          key: 'minimum_floor',
          label: 'Minimum completion XP',
          points: minimumFloorAdjustment,
          description: 'Completed challenges earn at least $_minimumXp XP.',
        ),
      );
    }

    return XpBreakdown(
      totalXp: cappedTotal,
      antiFarmingTriggered: antiFarmingTriggered,
      factors: factors,
    );
  }

  static List<String> _substantiveMessages(List<String> messages) {
    final seen = <String>{};
    final substantive = <String>[];

    for (final message in messages) {
      final normalized = _normalize(message);
      if (normalized.isEmpty || seen.contains(normalized)) continue;

      final wordCount =
          normalized.split(' ').where((word) => word.isNotEmpty).length;
      final longEnough = wordCount >= 10 || normalized.length >= 80;
      if (longEnough) {
        seen.add(normalized);
        substantive.add(normalized);
      }
    }

    return substantive;
  }

  static bool _isFarming(
    List<String> userMessages,
    List<String> substantiveMessages,
  ) {
    if (userMessages.isEmpty) return true;
    if (substantiveMessages.length < 2) return true;

    final normalized = userMessages
        .map(_normalize)
        .where((message) => message.isNotEmpty);
    final uniqueMessages = normalized.toSet().length;
    return userMessages.length >= 3 && uniqueMessages <= 1;
  }

  static String _normalize(String message) {
    return message
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
