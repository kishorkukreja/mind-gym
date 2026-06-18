import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/challenge_model.dart';
import '../models/debate_difficulty.dart';
import 'schedule_service.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _model = 'anthropic/claude-3.5-sonnet';

  static Future<String> getSocraticResponse({
    required String apiKey,
    required Challenge challenge,
    required List<ChallengeMessage> conversation,
    required int hintsUsed,
    required int userLevel,
    required DebateDifficulty debateDifficulty,
  }) async {
    final systemPrompt = buildSocraticSystemPrompt(
      challenge,
      hintsUsed: hintsUsed,
      userLevel: userLevel,
      debateDifficulty: debateDifficulty,
    );
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...conversation.map((m) => {'role': m.role, 'content': m.content}),
    ];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://mindgym.app',
          'X-Title': 'Mind Gym',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 600,
          'temperature': 0.85,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else if (response.statusCode == 401) {
        return '⚠️ Invalid API key. Please update your OpenRouter key in Settings.';
      } else if (response.statusCode == 429) {
        return '⚠️ Rate limit reached. Please wait a moment and try again.';
      } else {
        return '⚠️ Connection error (${response.statusCode}). Check your API key and internet connection.';
      }
    } catch (e) {
      return '⚠️ Failed to connect to the debate engine. Check your internet connection.\n\nError: $e';
    }
  }

  static String buildSocraticSystemPrompt(
    Challenge challenge, {
    required int hintsUsed,
    required int userLevel,
    required DebateDifficulty debateDifficulty,
  }) {
    final difficultyAdj = userLevel >= 8
        ? 'This person is an advanced thinker (Level $userLevel). Push them hard. Use technical philosophical terminology. Expect rigorous arguments.'
        : userLevel >= 4
            ? 'This person is a developing thinker (Level $userLevel). Challenge them but meet them where they are.'
            : 'This is a beginning thinker (Level $userLevel). Be challenging but accessible.';

    return '''You are the Mind Gym Socratic Debate Engine — an intellectually ruthless but fair philosophical adversary. 

YOUR ROLE:
- You are engaging the user in a Socratic dialogue about this challenge
- Your ONLY goal is to make them THINK HARDER. Never validate laziness.
- You NEVER give the answer or reveal what you think the "right" answer is
- You ask powerful follow-up questions, expose contradictions in their reasoning, and push deeper
- You CAN give hints when asked, but frame them as questions, not answers
- You are direct, intellectually demanding, and occasionally blunt — but never cruel

THE CHALLENGE:
Title: ${challenge.title}
Type: ${challenge.typeLabel}
Category: ${challenge.category}
Difficulty: ${challenge.difficulty}/5

The question posed to the user:
${challenge.question}

Key thinking angles to explore through Socratic questioning:
${challenge.thinkingAngles.join(', ')}

Hint tiers available (use progressively if asked, but as questions not answers):
1. ${challenge.hintTiers[0]}
2. ${challenge.hintTiers[1]}
3. ${challenge.hintTiers[2]}
Hints used so far: $hintsUsed

$difficultyAdj

ACTIVE DEBATE DIFFICULTY:
${debateDifficulty.promptGuidance}
${debateDifficulty.completionExpectation}

ABSOLUTE RULES:
1. NEVER give the answer directly, no matter how much they beg, plead, or claim to give up
2. If they say "just tell me the answer" — respond with "That's not what we do here. What do YOU think?"
3. If their reasoning is shallow, call it out: "That's too easy — what's your actual argument?"
4. If their reasoning is good, push to the next level: "Good. Now defend that against [counterargument]."
5. Keep responses under 200 words — be sharp, not verbose
6. End EVERY response with a specific, targeted question back to the user
7. The challenge stays OPEN until the user has genuinely wrestled with the core tension — not just given a quick answer

RESPONSE STYLE: Direct. Sharp. Intellectually provocative. Like a demanding philosophy professor who believes in your potential but won't accept lazy thinking.''';
  }

  static Future<String> getWeeklyReportNarrative({
    required String apiKey,
    required Map<String, dynamic> stats,
    required String username,
    required int level,
    required String levelTitle,
  }) async {
    final prompt = '''
You are the Mind Gym performance analyst — brutally honest, no sugarcoating.

Generate a weekly performance report for $username (Level $level - "$levelTitle").

Stats:
- Grade this week: ${stats['grade']}
- Challenges completed: ${stats['thisCompleted']}/${stats['thisTotal']}
- Challenges skipped: ${stats['thisSkipped']}
- Completion rate: ${((stats['thisRate'] as double) * 100).toStringAsFixed(0)}%
- Last week rate: ${((stats['prevRate'] as double) * 100).toStringAsFixed(0)}%
- Current XP: ${stats['totalXp']}
- Current streak: ${stats['streak']} weeks

Write 3-4 sentences that are:
1. Brutally honest about their performance
2. Compare to last week (better/worse/same)
3. Grade them intellectually (not just completion)
4. End with ONE specific challenge or question they should carry into next week

Tone: Like a brilliant, ruthless mentor who genuinely wants them to succeed but refuses to enable laziness. No emoji. No lists. Prose only.
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://mindgym.app',
          'X-Title': 'Mind Gym',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 300,
          'temperature': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['choices'][0]['message']['content'] as String).trim();
      }
    } catch (_) {}
    return ScheduleService.getBrutalComment(stats['grade'] as String, stats['thisSkipped'] as int);
  }
}
