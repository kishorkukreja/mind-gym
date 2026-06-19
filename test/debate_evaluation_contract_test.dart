import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/debate_evaluation_contract.dart';

void main() {
  group('DebateEvaluationContract', () {
    test('parses a complete v1 evaluation payload', () {
      final evaluation = DebateEvaluationContract.tryParse({
        'schemaVersion': DebateEvaluationContract.currentSchemaVersion,
        'reasoningDepth': 3,
        'clarity': 4,
        'counterarguments': 3,
        'selfCorrection': 2,
        'specificity': 4,
        'originality': 3,
        'intellectualHonesty': 4,
        'completionReadiness': 82,
        'completionRecommended': true,
        'strengths': ['Clear claim', 'Concrete example'],
        'improvementAreas': ['Address the strongest objection'],
        'completionSummary': 'Strong reasoning with one counterargument gap.',
      });

      expect(evaluation, isNotNull);
      expect(evaluation!.qualityScore, 4);
      expect(evaluation.source, EvaluationSource.ai);
      expect(evaluation.completionRecommended, isTrue);
    });

    test('rejects missing or out-of-range required scores', () {
      expect(
        DebateEvaluationContract.tryParse({
          'schemaVersion': DebateEvaluationContract.currentSchemaVersion,
          'reasoningDepth': 5,
          'clarity': 4,
          'counterarguments': 3,
          'selfCorrection': 2,
          'specificity': 4,
          'originality': 3,
          'intellectualHonesty': 4,
          'completionReadiness': 82,
          'completionRecommended': true,
          'strengths': ['Clear claim'],
          'improvementAreas': ['Address objections'],
          'completionSummary': 'Out-of-range reasoning depth is invalid.',
        }),
        isNull,
      );

      expect(
        DebateEvaluationContract.tryParse({
          'schemaVersion': DebateEvaluationContract.currentSchemaVersion,
          'reasoningDepth': 3,
          'counterarguments': 3,
          'selfCorrection': 2,
          'specificity': 4,
          'originality': 3,
          'intellectualHonesty': 4,
          'completionReadiness': 82,
          'completionRecommended': true,
          'strengths': ['Clear claim'],
          'improvementAreas': ['Address objections'],
          'completionSummary': 'Missing clarity is invalid.',
        }),
        isNull,
      );
    });

    test('creates a conservative fallback evaluation', () {
      final evaluation = DebateEvaluationContract.fallback(
        responseCount: 3,
        hintsUsed: 1,
      );

      expect(evaluation.source, EvaluationSource.fallback);
      expect(evaluation.completionReadiness, 50);
      expect(evaluation.completionRecommended, isFalse);
      expect(evaluation.qualityScore, 2);
      expect(evaluation.completionSummary, contains('structured evaluation'));
    });
  });
}
