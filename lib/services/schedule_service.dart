import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import 'challenge_library.dart';
import 'storage_service.dart';
import 'streak_service.dart';

class ScheduleService {
  static const _uuid = Uuid();

  /// Returns the week key string for a given date (e.g., "2024-W22")
  static String weekKey(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return '${monday.year}-W${_weekNumber(date).toString().padLeft(2, '0')}';
  }

  static int _weekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final days = date.difference(startOfYear).inDays;
    return ((days + startOfYear.weekday - 1) / 7).ceil();
  }

  /// Get or create this week's two challenges for the user
  static List<UserChallenge> getThisWeekChallenges(UserModel user) {
    final now = DateTime.now();
    final wk = weekKey(now);
    final assignments = StorageService.getWeeklyAssignments(user.id);

    if (assignments['week'] == wk && assignments['challenges'] != null) {
      final ids = List<String>.from(assignments['challenges'] as List);
      final allUc = StorageService.getUserChallenges(user.id);
      final result = <UserChallenge>[];
      for (final id in ids) {
        try {
          result.add(allUc.firstWhere((uc) => uc.id == id));
        } catch (_) {}
      }
      if (result.length == 2) return result;
    }

    // Pick new challenges
    final recentIds = List<String>.from(
      assignments['recentChallengeIds'] ?? [],
    );
    final picks = ChallengeLibrary.pickWeeklyChallenges(recentIds);

    // Schedule: weekday challenge on user's chosen weekday at chosen hour
    // Weekend challenge on user's chosen weekend day at chosen hour
    final weekdayDate = _nextOccurrenceOfWeekday(
      now,
      user.weekdayChallengeDay,
      user.weekdayHour,
    );
    final weekendDate = _nextOccurrenceOfWeekday(
      now,
      user.weekendChallengeDay,
      user.weekendHour,
    );

    final uc1 = UserChallenge(
      id: _uuid.v4(),
      challengeId: picks[0].id,
      userId: user.id,
      status: ChallengeStatus.pending,
      scheduledFor: weekdayDate,
    );
    final uc2 = UserChallenge(
      id: _uuid.v4(),
      challengeId: picks[1].id,
      userId: user.id,
      status: ChallengeStatus.pending,
      scheduledFor: weekendDate,
    );

    // Save
    _saveNewWeeklyAssignment(
      user.id,
      wk,
      [uc1.id, uc2.id],
      recentIds,
      picks.map((p) => p.id).toList(),
    );
    StorageService.saveUserChallenge(uc1);
    StorageService.saveUserChallenge(uc2);

    return [uc1, uc2];
  }

  static DateTime _nextOccurrenceOfWeekday(
    DateTime from,
    int weekday,
    int hour,
  ) {
    // weekday: 1=Mon...7=Sun
    var date = DateTime(from.year, from.month, from.day, hour, 0);
    int daysUntil = (weekday - from.weekday) % 7;
    if (daysUntil == 0 && from.hour >= hour) daysUntil = 7;
    return date.add(Duration(days: daysUntil));
  }

  static void _saveNewWeeklyAssignment(
    String userId,
    String wk,
    List<String> ucIds,
    List<String> oldRecentIds,
    List<String> newPickIds,
  ) {
    final updatedRecent = [...oldRecentIds, ...newPickIds];
    // Keep only last 10 to allow rotation
    final trimmed = updatedRecent.length > 10
        ? updatedRecent.sublist(updatedRecent.length - 10)
        : updatedRecent;

    StorageService.saveWeeklyAssignments(userId, {
      'week': wk,
      'challenges': ucIds,
      'recentChallengeIds': trimmed,
    });
  }

  /// Check and mark expired challenges as missed (with XP penalty)
  static Future<void> processExpiredChallenges(UserModel user) async {
    final challenges = StorageService.getUserChallenges(user.id);
    bool changed = false;
    for (final uc in challenges) {
      if (uc.isExpired &&
          uc.status != ChallengeStatus.completed &&
          uc.status != ChallengeStatus.skipped &&
          uc.status != ChallengeStatus.expired) {
        uc.status = ChallengeStatus.expired;
        user.totalChallengesSkipped++;
        if (!user.skippedChallengeIds.contains(uc.id)) {
          user.skippedChallengeIds.add(uc.id);
        }
        // XP penalty: -50 per skip
        user.xp = (user.xp - 50).clamp(0, 999999);
        StreakService.recordMissedChallenge(user: user);
        changed = true;
        await StorageService.saveUserChallenge(uc);
      }
    }
    if (changed) {
      await StorageService.saveUser(user);
    }
  }

  /// Award XP and level up
  static Future<void> awardXp(UserModel user, int xpAmount) async {
    user.xp += xpAmount;
    // Level up check
    while (user.xp >= (user.level * 150 * user.level)) {
      user.level++;
    }
    await StorageService.saveUser(user);
  }

  /// Calculate XP reward for completing a challenge
  static int calculateXpReward({
    required int hintsUsed,
    required int responseCount,
    required int difficulty,
    required bool onTime,
  }) {
    int base = difficulty * 40;
    int hintPenalty = hintsUsed * 10;
    int depthBonus = (responseCount.clamp(1, 6) * 5);
    int timePenalty = onTime ? 0 : -20;
    return (base - hintPenalty + depthBonus + timePenalty).clamp(10, 300);
  }

  /// Get countdown to next challenge
  static Duration? getCountdownToNextChallenge(
    List<UserChallenge> weekChallenges, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final pending = weekChallenges
        .where((uc) =>
            uc.status == ChallengeStatus.pending &&
            uc.scheduledFor.isAfter(currentTime))
        .toList();
    if (pending.isEmpty) return null;
    pending.sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    return pending.first.scheduledFor.difference(currentTime);
  }

  /// Weekly performance stats
  static Map<String, dynamic> getWeeklyPerformance(UserModel user) {
    final allUc = StorageService.getUserChallenges(user.id);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekUc = allUc
        .where(
          (uc) => uc.scheduledFor.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          ),
        )
        .toList();

    final prevWeekStart = weekStart.subtract(const Duration(days: 7));
    final prevWeekUc = allUc
        .where(
          (uc) =>
              uc.scheduledFor.isAfter(
                prevWeekStart.subtract(const Duration(days: 1)),
              ) &&
              uc.scheduledFor.isBefore(weekStart),
        )
        .toList();

    int thisCompleted = thisWeekUc
        .where((uc) => uc.status == ChallengeStatus.completed)
        .length;
    int thisSkipped = thisWeekUc
        .where((uc) =>
            uc.status == ChallengeStatus.skipped ||
            uc.status == ChallengeStatus.expired)
        .length;
    int thisTotal = thisWeekUc.length;

    int prevCompleted = prevWeekUc
        .where((uc) => uc.status == ChallengeStatus.completed)
        .length;
    int prevTotal = prevWeekUc.length;

    double thisRate = thisTotal > 0 ? thisCompleted / thisTotal : 0;
    double prevRate = prevTotal > 0 ? prevCompleted / prevTotal : 0;

    String grade;
    if (thisRate >= 0.9) grade = 'A+';
    else if (thisRate >= 0.8) grade = 'A';
    else if (thisRate >= 0.7) grade = 'B+';
    else if (thisRate >= 0.6) grade = 'B';
    else if (thisRate >= 0.5) grade = 'C';
    else if (thisRate >= 0.3) grade = 'D';
    else grade = 'F';

    return {
      'grade': grade,
      'thisCompleted': thisCompleted,
      'thisSkipped': thisSkipped,
      'thisTotal': thisTotal,
      'thisRate': thisRate,
      'prevCompleted': prevCompleted,
      'prevTotal': prevTotal,
      'prevRate': prevRate,
      'totalXp': user.xp,
      'activityStreak': user.activityStreak,
      'weeklyCompletionStreak': user.weeklyCompletionStreak,
      'perfectWeekStatus': StreakService.perfectWeekLabel(
        StreakService.getPerfectWeekStatus(thisWeekUc, now: now),
      ),
      'streak': user.activityStreak,
      'level': user.level,
    };
  }

  static String getBrutalComment(String grade, int skipped) {
    if (grade == 'F') {
      return "You didn't even try. Your brain is collecting dust. Seriously — a sea slug has more neural activity than you showed this week. Come back when you're ready to actually think.";
    } else if (grade == 'D') {
      return "Barely breathing. $skipped challenge${skipped == 1 ? '' : 's'} skipped — which means $skipped times this week you chose comfort over growth. Mediocrity doesn't announce itself. It just silently wins.";
    } else if (grade == 'C') {
      return "Average. Congratulations on being statistically unremarkable. You did the minimum. Your brain deserves better — and frankly, so do you.";
    } else if (grade == 'B' || grade == 'B+') {
      return "Getting there, but you're still leaving gains on the table. The difference between good and sharp is consistency. Don't celebrate yet.";
    } else if (grade == 'A') {
      return "Solid work this week. Your neurons are firing. Keep this up for a month straight and watch how differently you think. Don't let it slip.";
    } else {
      return "Exceptional. This is what committed minds look like. Now the question is: can you maintain it? Consistency is the only thing that compounds.";
    }
  }
}
