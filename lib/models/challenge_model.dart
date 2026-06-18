enum ChallengeType {
  philosophy,
  cognitiveBias,
  logic,
  decisionTheory,
  statistics,
  rhetoric,
  mediaLiteracy,
}

enum ChallengeStatus { pending, open, inProgress, completed, skipped }

class ChallengeVariant {
  final String id;
  final String title;
  final String question;

  const ChallengeVariant({
    required this.id,
    required this.title,
    required this.question,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'question': question,
      };
}

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

class Challenge {
  final String id;
  final String title;
  final String question;
  final ChallengeType type;
  final String sourceName;
  final String sourceDescription;
  final List<String> hintTiers; // 3 hints, progressively revealing
  final String category;
  final List<String> tags;
  final int difficulty; // 1-5
  final int estimatedTimeMinutes;
  final List<String> thinkingAngles; // Socratic angles the LLM can explore
  final List<ChallengeVariant> variants;

  Challenge({
    required this.id,
    required this.title,
    required this.question,
    required this.type,
    required this.sourceName,
    required this.sourceDescription,
    required this.hintTiers,
    required this.category,
    List<String>? tags,
    required this.difficulty,
    int? estimatedTimeMinutes,
    required this.thinkingAngles,
    List<ChallengeVariant>? variants,
  })  : tags = tags ?? _defaultTags(category, type),
        estimatedTimeMinutes =
            estimatedTimeMinutes ?? _defaultEstimatedTime(difficulty),
        variants = variants ?? const [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'question': question,
        'type': type.name,
        'sourceName': sourceName,
        'sourceDescription': sourceDescription,
        'hintTiers': hintTiers,
        'category': category,
        'tags': tags,
        'difficulty': difficulty,
        'estimatedTimeMinutes': estimatedTimeMinutes,
        'thinkingAngles': thinkingAngles,
        'variants': variants.map((variant) => variant.toJson()).toList(),
      };

  bool get isPhilosophyStyle =>
      type == ChallengeType.philosophy ||
      type == ChallengeType.logic ||
      type == ChallengeType.decisionTheory;

  bool get isCognitiveBiasStyle => !isPhilosophyStyle;

  List<String> get variantIds => variants.map((variant) => variant.id).toList();

  String get typeLabel {
    switch (type) {
      case ChallengeType.philosophy:
        return 'Philosophy';
      case ChallengeType.cognitiveBias:
        return 'Cognitive Bias';
      case ChallengeType.logic:
        return 'Logic';
      case ChallengeType.decisionTheory:
        return 'Decision Theory';
      case ChallengeType.statistics:
        return 'Statistics';
      case ChallengeType.rhetoric:
        return 'Rhetoric';
      case ChallengeType.mediaLiteracy:
        return 'Media Literacy';
    }
  }

  String get difficultyLabel {
    final normalizedDifficulty = difficulty.clamp(1, 5).toInt();
    switch (normalizedDifficulty) {
      case 1:
        return 'Intro';
      case 2:
        return 'Light';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      default:
        return 'Expert';
    }
  }

  List<String> get metadataLabels => [
        typeLabel,
        difficultyLabel,
        '$estimatedTimeMinutes min',
        ...tags.take(2),
      ];

  static List<String> _defaultTags(String category, ChallengeType type) {
    final normalized = category
        .split(RegExp(r'[^A-Za-z0-9]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part.toLowerCase())
        .toList();
    return normalized.isEmpty ? [type.name] : normalized;
  }

  static int _defaultEstimatedTime(int difficulty) => 8 + (difficulty * 4);
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
    this.responseCount = 0,
    List<ChallengeMessage>? conversation,
    this.selfAssessmentNote,
    this.qualityScore,
  }) : conversation = conversation ?? [];

  bool get isOpen =>
      status == ChallengeStatus.open || status == ChallengeStatus.inProgress;

  bool get isExpired {
    if (status == ChallengeStatus.completed ||
        status == ChallengeStatus.skipped) {
      return false;
    }
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
        responseCount: (json['responseCount'] as int?) ?? 0,
        conversation: ((json['conversation'] as List?) ?? [])
            .map((m) => ChallengeMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        selfAssessmentNote: json['selfAssessmentNote'] as String?,
        qualityScore: json['qualityScore'] as int?,
      );
}
