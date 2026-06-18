import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/services/openrouter_service.dart';

class FakeAiClient implements AiClient {
  FakeAiClient(this.content);

  final String content;
  List<Map<String, String>>? capturedMessages;

  @override
  Future<String> createChatCompletion({
    required String apiKey,
    required List<Map<String, String>> messages,
    required int maxTokens,
    required double temperature,
  }) async {
    capturedMessages = messages;
    return content;
  }
}

void main() {
  final challenge = Challenge(
    id: 'challenge-1',
    title: 'The Test',
    question: 'What do you think?',
    type: ChallengeType.philosophy,
    sourceName: 'Test',
    sourceDescription: 'Test source',
    hintTiers: const ['Hint 1', 'Hint 2', 'Hint 3'],
    category: 'Testing',
    difficulty: 3,
    thinkingAngles: const ['clarity', 'counterargument'],
  );

  test(
    'parses structured evaluation metadata and strips it from chat text',
    () async {
    final client = FakeAiClient('''Your claim is clearer. Now test it against the strongest objection.

<mind_gym_evaluation>
{
  "reasoningDepth": 4,
  "clarity": 5,
  "counterargumentHandling": 4,
  "selfCorrection": 3,
  "specificity": 4,
  "originality": 3,
  "intellectualHonesty": 5,
  "completionReadiness": true,
  "summary": "Strong clarity with a real counterargument to explore next."
}
</mind_gym_evaluation>''');
    final service = OpenRouterService(client: client);

    final response = await service.getSocraticResponse(
      apiKey: 'test-key',
      challenge: challenge,
      conversation: [
        ChallengeMessage(
          role: 'user',
          content: 'I think fairness depends on the rule people could accept.',
          timestamp: DateTime(2026),
        ),
      ],
      hintsUsed: 0,
      userLevel: 2,
    );

    expect(
      response.message,
      'Your claim is clearer. Now test it against the strongest objection.',
    );
    expect(response.evaluation, isNotNull);
    expect(response.evaluation!.completionReadiness, isTrue);
    expect(response.evaluation!.qualityScore, 4);
    expect(
      response.evaluation!.summary,
      'Strong clarity with a real counterargument to explore next.',
    );
    expect(
      client.capturedMessages!.first['content'],
      contains('<mind_gym_evaluation>'),
    );
  });

  test(
    'invalid evaluation metadata falls back without leaking hidden block',
    () async {
    final client = FakeAiClient('''Keep going. What would make your answer false?

<mind_gym_evaluation>
{"reasoningDepth": 8, "completionReadiness": "yes"}
</mind_gym_evaluation>''');
    final service = OpenRouterService(client: client);

    final response = await service.getSocraticResponse(
      apiKey: 'test-key',
      challenge: challenge,
      conversation: [
        ChallengeMessage(
          role: 'user',
          content: 'I am not sure yet.',
          timestamp: DateTime(2026),
        ),
      ],
      hintsUsed: 1,
      userLevel: 1,
    );

    expect(response.message, 'Keep going. What would make your answer false?');
    expect(response.evaluation, isNull);
  });

  test('metadata-only invalid responses use neutral fallback text', () async {
    final client = FakeAiClient('''<mind_gym_evaluation>
{"reasoningDepth": 8, "completionReadiness": "yes"}
</mind_gym_evaluation>''');
    final service = OpenRouterService(client: client);

    final response = await service.getSocraticResponse(
      apiKey: 'test-key',
      challenge: challenge,
      conversation: [
        ChallengeMessage(
          role: 'user',
          content: 'I need another angle.',
          timestamp: DateTime(2026),
        ),
      ],
      hintsUsed: 1,
      userLevel: 1,
    );

    expect(response.message, 'Keep thinking. What is your next argument?');
    expect(response.evaluation, isNull);
  });
}
