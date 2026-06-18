enum ChallengeType { philosophy, cognitiveBias }
enum ChallengeStatus { pending, open, inProgress, completed, skipped }

class ChallengeMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  ChallengeMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChallengeMessage.fromJson(Map<String, dynamic> json) =>
      ChallengeMessage(
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class XpFactor {
  final String key;
  final String label;
  final int points;
  final String description;

  const XpFactor({
    required this.key,
    required this.label,
    required this.points,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'points': points,
        'description': description,
      };

  factory XpFactor.fromJson(Map<String, dynamic> json) => XpFactor(
        key: json['key'] as String,
        label: json['label'] as String,
        points: (json['points'] as int?) ?? 0,
        description: json['description'] as String? ?? '',
      );
}

class XpBreakdown {
  final int totalXp;
  final bool antiFarmingTriggered;
  final List<XpFactor> factors;

  const XpBreakdown({
    required this.totalXp,
    required this.antiFarmingTriggered,
    required this.factors,
  });

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'antiFarmingTriggered': antiFarmingTriggered,
        'factors': factors.map((factor) => factor.toJson()).toList(),
      };

  factory XpBreakdown.fromJson(Map<String, dynamic> json) => XpBreakdown(
        totalXp: (json['totalXp'] as int?) ?? 0,
        antiFarmingTriggered: (json['antiFarmingTriggered'] as bool?) ?? false,
        factors: ((json['factors'] as List?) ?? [])
            .map((factor) => XpFactor.fromJson(factor as Map<String, dynamic>))
            .toList(),
      );
}

class Challenge {
  final String id;
  final String title;
  final String question;
  final ChallengeType type;
  final String sourceName;
  final String sourceDescription;
  final List<String> hintTiers; // 3 hints, progressively revealing
  final String category; // e.g. "Trolley Problem", "Confirmation Bias"
  final int difficulty; // 1-5
  final List<String> thinkingAngles; // Socratic angles the LLM can explore

  Challenge({
    required this.id,
    required this.title,
    required this.question,
    required this.type,
    required this.sourceName,
    required this.sourceDescription,
    required this.hintTiers,
    required this.category,
    required this.difficulty,
    required this.thinkingAngles,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'question': question,
        'type': type.name,
        'sourceName': sourceName,
        'sourceDescription': sourceDescription,
        'hintTiers': hintTiers,
        'category': category,
        'difficulty': difficulty,
        'thinkingAngles': thinkingAngles,
      };

  String get typeLabel =>
      type == ChallengeType.philosophy ? '🏛️ Philosophy' : '🧠 Cognitive Bias';
}

class UserChallenge {
  final String id; // unique instance id
  final String challengeId;
  final String userId;
  ChallengeStatus status;
  DateTime scheduledFor;
  DateTime? openedAt;
  DateTime? completedAt;
  int hintsUsed;
  int xpEarned;
  XpBreakdown? xpBreakdown;
  int responseCount; // number of user messages
  List<ChallengeMessage> conversation;
  String? selfAssessmentNote;
  int? qualityScore; // 1-5 based on depth

  UserChallenge({
    required this.id,
    required this.challengeId,
    required this.userId,
    this.status = ChallengeStatus.pending,
    required this.scheduledFor,
    this.openedAt,
    this.completedAt,
    this.hintsUsed = 0,
    this.xpEarned = 0,
    this.xpBreakdown,
    this.responseCount = 0,
    List<ChallengeMessage>? conversation,
    this.selfAssessmentNote,
    this.qualityScore,
  }) : conversation = conversation ?? [];

  bool get isOpen => status == ChallengeStatus.open || status == ChallengeStatus.inProgress;
  bool get isExpired {
    if (status == ChallengeStatus.completed || status == ChallengeStatus.skipped) return false;
    return DateTime.now().isAfter(scheduledFor.add(const Duration(days: 4)));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'challengeId': challengeId,
        'userId': userId,
        'status': status.name,
        'scheduledFor': scheduledFor.toIso8601String(),
        'openedAt': openedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'hintsUsed': hintsUsed,
        'xpEarned': xpEarned,
        'xpBreakdown': xpBreakdown?.toJson(),
        'responseCount': responseCount,
        'conversation': conversation.map((m) => m.toJson()).toList(),
        'selfAssessmentNote': selfAssessmentNote,
        'qualityScore': qualityScore,
      };

  factory UserChallenge.fromJson(Map<String, dynamic> json) => UserChallenge(
        id: json['id'] as String,
        challengeId: json['challengeId'] as String,
        userId: json['userId'] as String,
        status: ChallengeStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ChallengeStatus.pending,
        ),
        scheduledFor: DateTime.parse(json['scheduledFor'] as String),
        openedAt: json['openedAt'] != null
            ? DateTime.parse(json['openedAt'] as String)
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        hintsUsed: (json['hintsUsed'] as int?) ?? 0,
        xpEarned: (json['xpEarned'] as int?) ?? 0,
        xpBreakdown: json['xpBreakdown'] != null
            ? XpBreakdown.fromJson(json['xpBreakdown'] as Map<String, dynamic>)
            : null,
        responseCount: (json['responseCount'] as int?) ?? 0,
        conversation: ((json['conversation'] as List?) ?? [])
            .map((m) => ChallengeMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        selfAssessmentNote: json['selfAssessmentNote'] as String?,
        qualityScore: json['qualityScore'] as int?,
      );
}
