enum AuthProvider { local, google }

class UserModel {
  final String id;
  final String username;
  final String pinHash;
  final AuthProvider authProvider;
  final String? email;
  final String? photoUrl;
  int xp;
  int level;
  int totalChallengesCompleted;
  int totalChallengesSkipped;
  int currentStreak;
  int bestStreak;
  DateTime? lastActiveDate;
  List<String> completedChallengeIds;
  List<String> skippedChallengeIds;
  Map<String, dynamic> weeklyStats;
  DateTime createdAt;
  String? openRouterApiKey;
  // Schedule settings
  int weekdayHour; // 22 = 10pm
  int weekendHour; // 17 = 5pm
  int weekdayChallengeDay; // 1=Mon,2=Tue,...5=Fri (default: Wednesday=3)
  int weekendChallengeDay; // 6=Sat, 7=Sun (default: Saturday=6)

  UserModel({
    required this.id,
    required this.username,
    required this.pinHash,
    this.authProvider = AuthProvider.local,
    this.email,
    this.photoUrl,
    this.xp = 0,
    this.level = 1,
    this.totalChallengesCompleted = 0,
    this.totalChallengesSkipped = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastActiveDate,
    List<String>? completedChallengeIds,
    List<String>? skippedChallengeIds,
    Map<String, dynamic>? weeklyStats,
    DateTime? createdAt,
    this.openRouterApiKey,
    this.weekdayHour = 22,
    this.weekendHour = 17,
    this.weekdayChallengeDay = 3,
    this.weekendChallengeDay = 6,
  })  : completedChallengeIds = completedChallengeIds ?? [],
        skippedChallengeIds = skippedChallengeIds ?? [],
        weeklyStats = weeklyStats ?? {},
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'pinHash': pinHash,
        'authProvider': authProvider.name,
        'email': email,
        'photoUrl': photoUrl,
        'xp': xp,
        'level': level,
        'totalChallengesCompleted': totalChallengesCompleted,
        'totalChallengesSkipped': totalChallengesSkipped,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'completedChallengeIds': completedChallengeIds,
        'skippedChallengeIds': skippedChallengeIds,
        'weeklyStats': weeklyStats,
        'createdAt': createdAt.toIso8601String(),
        'openRouterApiKey': openRouterApiKey,
        'weekdayHour': weekdayHour,
        'weekendHour': weekendHour,
        'weekdayChallengeDay': weekdayChallengeDay,
        'weekendChallengeDay': weekendChallengeDay,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        username: json['username'] as String,
        pinHash: json['pinHash'] as String,
        authProvider: AuthProvider.values.firstWhere(
          (provider) => provider.name == json['authProvider'],
          orElse: () => AuthProvider.local,
        ),
        email: json['email'] as String?,
        photoUrl: json['photoUrl'] as String?,
        xp: (json['xp'] as int?) ?? 0,
        level: (json['level'] as int?) ?? 1,
        totalChallengesCompleted:
            (json['totalChallengesCompleted'] as int?) ?? 0,
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
        openRouterApiKey: json['openRouterApiKey'] as String?,
        weekdayHour: (json['weekdayHour'] as int?) ?? 22,
        weekendHour: (json['weekendHour'] as int?) ?? 17,
        weekdayChallengeDay: (json['weekdayChallengeDay'] as int?) ?? 3,
        weekendChallengeDay: (json['weekendChallengeDay'] as int?) ?? 6,
      );

  String get levelTitle {
    if (level <= 2) return 'Sleeping Mind';
    if (level <= 4) return 'Awakening Thinker';
    if (level <= 6) return 'Curious Philosopher';
    if (level <= 8) return 'Sharp Reasoner';
    if (level <= 10) return 'Critical Analyst';
    if (level <= 13) return 'Cognitive Athlete';
    if (level <= 16) return 'Dialectic Master';
    if (level <= 20) return 'Grand Sophist';
    return 'Enlightened Mind';
  }

  int get xpForNextLevel => level * 150;
  double get xpProgress =>
      xpForNextLevel > 0 ? (xp % xpForNextLevel) / xpForNextLevel : 0.0;
  int get currentLevelXp => xp % xpForNextLevel;

  double get brainDevelopmentPercent {
    const maxLevel = 25;
    return (level / maxLevel).clamp(0.0, 1.0);
  }
}
