import '../models/challenge_model.dart';
import '../models/user_model.dart';
import 'schedule_service.dart';

enum PerfectWeekStatus { notStarted, inProgress, perfect, broken }

class StreakService {
  static void recordCompletion({
    required UserModel user,
    required UserChallenge completedChallenge,
    required List<UserChallenge> weekChallenges,
    DateTime? now,
  }) {
    final completedAt = now ?? DateTime.now();
    _recordActivity(user, completedAt);

    final completedWeekKey = ScheduleService.weekKey(
      completedChallenge.scheduledFor,
    );
    final challengesForWeek = weekChallenges
        .where(
          (uc) => ScheduleService.weekKey(uc.scheduledFor) == completedWeekKey,
        )
        .toList();

    if (challengesForWeek.isEmpty ||
        challengesForWeek.any((uc) => uc.status != ChallengeStatus.completed)) {
      return;
    }

    _recordWeeklyCompletion(
      user: user,
      weekKey: completedWeekKey,
      scheduledFor: completedChallenge.scheduledFor,
    );
  }

  static void recordMissedChallenge({required UserModel user}) {
    user.weeklyCompletionStreak = 0;
  }

  static PerfectWeekStatus getPerfectWeekStatus(
    List<UserChallenge> weekChallenges, {
    DateTime? now,
  }) {
    final currentWeek = ScheduleService.weekKey(now ?? DateTime.now());
    final currentChallenges = weekChallenges
        .where((uc) => ScheduleService.weekKey(uc.scheduledFor) == currentWeek)
        .toList();

    if (currentChallenges.isEmpty) return PerfectWeekStatus.notStarted;
    if (currentChallenges.any(
      (uc) =>
          uc.status == ChallengeStatus.skipped ||
          uc.status == ChallengeStatus.expired,
    )) {
      return PerfectWeekStatus.broken;
    }
    if (currentChallenges.every(
      (uc) => uc.status == ChallengeStatus.completed,
    )) {
      return PerfectWeekStatus.perfect;
    }
    return PerfectWeekStatus.inProgress;
  }

  static String perfectWeekLabel(PerfectWeekStatus status) {
    switch (status) {
      case PerfectWeekStatus.notStarted:
        return 'Not started';
      case PerfectWeekStatus.inProgress:
        return 'In progress';
      case PerfectWeekStatus.perfect:
        return 'Perfect week';
      case PerfectWeekStatus.broken:
        return 'Broken';
    }
  }

  static void _recordActivity(UserModel user, DateTime completedAt) {
    final activityDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    final lastDate = user.lastActivityDate ?? user.lastActiveDate;

    if (lastDate == null) {
      user.activityStreak = 1;
    } else {
      final normalizedLast = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );
      final dayDiff = activityDate.difference(normalizedLast).inDays;
      if (dayDiff == 0) {
        user.activityStreak = user.activityStreak == 0
            ? 1
            : user.activityStreak;
      } else if (dayDiff == 1) {
        user.activityStreak++;
      } else {
        user.activityStreak = 1;
      }
    }

    if (user.activityStreak > user.bestActivityStreak) {
      user.bestActivityStreak = user.activityStreak;
    }

    user.lastActivityDate = activityDate;
    user.lastActiveDate = activityDate;
    user.currentStreak = user.activityStreak;
    user.bestStreak = user.bestActivityStreak;
  }

  static void _recordWeeklyCompletion({
    required UserModel user,
    required String weekKey,
    required DateTime scheduledFor,
  }) {
    if (user.lastCompletedWeekKey == weekKey) return;

    final previousWeekKey = ScheduleService.weekKey(
      scheduledFor.subtract(const Duration(days: 7)),
    );
    if (user.lastCompletedWeekKey == previousWeekKey) {
      user.weeklyCompletionStreak++;
    } else {
      user.weeklyCompletionStreak = 1;
    }

    if (user.weeklyCompletionStreak > user.bestWeeklyCompletionStreak) {
      user.bestWeeklyCompletionStreak = user.weeklyCompletionStreak;
    }
    user.lastCompletedWeekKey = weekKey;
  }
}
