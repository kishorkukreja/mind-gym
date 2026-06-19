import 'challenge_model.dart';
import 'user_model.dart';

class UserProgressSnapshot {
  final UserModel user;
  final List<UserChallenge> challenges;
  final DateTime updatedAt;

  UserProgressSnapshot({
    required this.user,
    required this.challenges,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'userId': user.id,
        'user': _userProgressJson(user),
        'challenges': challenges.map((challenge) => challenge.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory UserProgressSnapshot.fromJson(Map<String, dynamic> json) {
    return UserProgressSnapshot(
      user: _userFromProgressJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
      challenges: ((json['challenges'] as List?) ?? [])
          .map(
            (challenge) => UserChallenge.fromJson(
              Map<String, dynamic>.from(challenge as Map),
            ),
          )
          .toList(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  static Map<String, dynamic> _userProgressJson(UserModel user) => {
        'id': user.id,
        'username': user.username,
        'xp': user.xp,
        'level': user.level,
        'totalChallengesCompleted': user.totalChallengesCompleted,
        'totalChallengesSkipped': user.totalChallengesSkipped,
        'currentStreak': user.currentStreak,
        'bestStreak': user.bestStreak,
        'lastActiveDate': user.lastActiveDate?.toIso8601String(),
        'completedChallengeIds': user.completedChallengeIds,
        'skippedChallengeIds': user.skippedChallengeIds,
        'weeklyStats': user.weeklyStats,
        'createdAt': user.createdAt.toIso8601String(),
        'weekdayHour': user.weekdayHour,
        'weekendHour': user.weekendHour,
        'weekdayChallengeDay': user.weekdayChallengeDay,
        'weekendChallengeDay': user.weekendChallengeDay,
      };

  static UserModel _userFromProgressJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: (json['username'] as String?) ?? '',
      pinHash: (json['pinHash'] as String?) ?? '',
      xp: (json['xp'] as int?) ?? 0,
      level: (json['level'] as int?) ?? 1,
      totalChallengesCompleted: (json['totalChallengesCompleted'] as int?) ?? 0,
      totalChallengesSkipped: (json['totalChallengesSkipped'] as int?) ?? 0,
      currentStreak: (json['currentStreak'] as int?) ?? 0,
      bestStreak: (json['bestStreak'] as int?) ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      completedChallengeIds: List<String>.from(
        (json['completedChallengeIds'] as List?) ?? [],
      ),
      skippedChallengeIds: List<String>.from(
        (json['skippedChallengeIds'] as List?) ?? [],
      ),
      weeklyStats: Map<String, dynamic>.from(
        (json['weeklyStats'] as Map?) ?? {},
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      weekdayHour: (json['weekdayHour'] as int?) ?? 22,
      weekendHour: (json['weekendHour'] as int?) ?? 17,
      weekdayChallengeDay: (json['weekdayChallengeDay'] as int?) ?? 3,
      weekendChallengeDay: (json['weekendChallengeDay'] as int?) ?? 6,
    );
  }
}
