enum EvaluationSource { ai, fallback }

class DebateEvaluationContract {
  static const currentSchemaVersion = 'mind_gym.ai_debate_evaluation.v1';

  final int reasoningDepth;
  final int clarity;
  final int counterarguments;
  final int selfCorrection;
  final int specificity;
  final int originality;
  final int intellectualHonesty;
  final int completionReadiness;
  final bool completionRecommended;
  final List<String> strengths;
  final List<String> improvementAreas;
  final String completionSummary;
  final EvaluationSource source;

  const DebateEvaluationContract({
    required this.reasoningDepth,
    required this.clarity,
    required this.counterarguments,
    required this.selfCorrection,
    required this.specificity,
    required this.originality,
    required this.intellectualHonesty,
    required this.completionReadiness,
    required this.completionRecommended,
    required this.strengths,
    required this.improvementAreas,
    required this.completionSummary,
    this.source = EvaluationSource.ai,
  });

  int get qualityScore {
    final average = [
          reasoningDepth,
          clarity,
          counterarguments,
          selfCorrection,
          specificity,
          originality,
          intellectualHonesty,
        ].reduce((a, b) => a + b) /
        7;
    final score = ((average / 4) * 4 + 1).round().clamp(1, 5).toInt();
    return source == EvaluationSource.fallback
        ? score.clamp(1, 2).toInt()
        : score;
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': currentSchemaVersion,
        'reasoningDepth': reasoningDepth,
        'clarity': clarity,
        'counterarguments': counterarguments,
        'selfCorrection': selfCorrection,
        'specificity': specificity,
        'originality': originality,
        'intellectualHonesty': intellectualHonesty,
        'completionReadiness': completionReadiness,
        'completionRecommended': completionRecommended,
        'strengths': strengths,
        'improvementAreas': improvementAreas,
        'completionSummary': completionSummary,
      };

  static DebateEvaluationContract? tryParse(Map<String, dynamic> json) {
    if (json['schemaVersion'] != currentSchemaVersion) return null;

    final reasoningDepth = _score(json['reasoningDepth']);
    final clarity = _score(json['clarity']);
    final counterarguments = _score(json['counterarguments']);
    final selfCorrection = _score(json['selfCorrection']);
    final specificity = _score(json['specificity']);
    final originality = _score(json['originality']);
    final intellectualHonesty = _score(json['intellectualHonesty']);
    final completionReadiness = _readiness(json['completionReadiness']);
    final completionRecommended = json['completionRecommended'];
    final strengths = _stringList(json['strengths']);
    final improvementAreas = _stringList(json['improvementAreas']);
    final completionSummary = json['completionSummary'];

    if (reasoningDepth == null ||
        clarity == null ||
        counterarguments == null ||
        selfCorrection == null ||
        specificity == null ||
        originality == null ||
        intellectualHonesty == null ||
        completionReadiness == null ||
        completionRecommended is! bool ||
        strengths == null ||
        improvementAreas == null ||
        completionSummary is! String ||
        completionSummary.trim().isEmpty) {
      return null;
    }

    return DebateEvaluationContract(
      reasoningDepth: reasoningDepth,
      clarity: clarity,
      counterarguments: counterarguments,
      selfCorrection: selfCorrection,
      specificity: specificity,
      originality: originality,
      intellectualHonesty: intellectualHonesty,
      completionReadiness: completionReadiness,
      completionRecommended: completionRecommended,
      strengths: strengths,
      improvementAreas: improvementAreas,
      completionSummary: completionSummary.trim(),
    );
  }

  static DebateEvaluationContract fallback({
    required int responseCount,
    required int hintsUsed,
  }) {
    final readiness = responseCount >= 2 ? 50 : 25;
    final baseScore = responseCount >= 3 ? 1 : 0;
    final score = (baseScore - (hintsUsed >= 3 ? 1 : 0)).clamp(0, 1).toInt();

    return DebateEvaluationContract(
      reasoningDepth: score,
      clarity: score,
      counterarguments: 0,
      selfCorrection: 0,
      specificity: score,
      originality: 0,
      intellectualHonesty: score,
      completionReadiness: readiness,
      completionRecommended: false,
      strengths: const ['Minimum engagement was recorded.'],
      improvementAreas: const [
        'Structured evaluation was unavailable; continue the debate for a more reliable score.',
      ],
      completionSummary:
          'Mind Gym could not read a valid structured evaluation, so this session used a conservative fallback score.',
      source: EvaluationSource.fallback,
    );
  }

  static int? _score(Object? value) {
    if (value is! int || value < 0 || value > 4) return null;
    return value;
  }

  static int? _readiness(Object? value) {
    if (value is! int || value < 0 || value > 100) return null;
    return value;
  }

  static List<String>? _stringList(Object? value) {
    if (value is! List) return null;
    final strings = value
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return strings.length == value.length ? strings : null;
  }
}
