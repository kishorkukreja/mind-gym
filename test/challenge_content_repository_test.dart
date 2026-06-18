import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/services/challenge_content_repository.dart';
import 'package:mind_gym/services/challenge_library.dart';

void main() {
  tearDown(ChallengeLibrary.resetForTests);

  test('parses structured challenge content from json', () {
    final challenges = JsonChallengeContentParser.parse(
      jsonEncode({
        'version': 1,
        'challenges': [
          _challengeJson(id: 'phi_001', type: 'philosophy'),
          _challengeJson(id: 'cog_001', type: 'cognitiveBias'),
        ],
      }),
      source: 'test content',
    );

    expect(challenges, hasLength(2));
    expect(challenges.first.id, 'phi_001');
    expect(challenges.first.type, ChallengeType.philosophy);
    expect(challenges.first.hintTiers, hasLength(3));
  });

  test('fails clearly when required content is invalid', () {
    expect(
      () => JsonChallengeContentParser.parse(
        jsonEncode({
          'version': 1,
          'challenges': [
            _challengeJson(id: 'phi_001', type: 'philosophy', difficulty: 9),
          ],
        }),
        source: 'bad content',
      ),
      throwsA(
        isA<ChallengeContentException>().having(
          (error) => error.toString(),
          'message',
          contains('difficulty'),
        ),
      ),
    );
  });

  test('fails clearly when challenge ids are duplicated', () {
    expect(
      () => JsonChallengeContentParser.parse(
        jsonEncode({
          'version': 1,
          'challenges': [
            _challengeJson(id: 'phi_001', type: 'philosophy'),
            _challengeJson(id: 'phi_001', type: 'cognitiveBias'),
          ],
        }),
        source: 'duplicate content',
      ),
      throwsA(
        isA<ChallengeContentException>().having(
          (error) => error.toString(),
          'message',
          contains('Duplicate challenge id'),
        ),
      ),
    );
  });

  test('challenge library loads through repository boundary', () async {
    await ChallengeLibrary.load(
      repository: InMemoryChallengeContentRepository([
        _challenge(id: 'phi_001', type: ChallengeType.philosophy),
        _challenge(id: 'cog_001', type: ChallengeType.cognitiveBias),
      ]),
    );

    expect(ChallengeLibrary.getById('phi_001')?.type, ChallengeType.philosophy);
    expect(ChallengeLibrary.getById('missing'), isNull);
  });

  test('asset repository loads committed local challenge content', () async {
    final challenges = await AssetChallengeContentRepository(
      bundle: _FileBackedAssetBundle(),
    ).loadChallenges();

    expect(challenges.length, greaterThan(1));
    expect(
      challenges.map((challenge) => challenge.type).toSet(),
      containsAll({ChallengeType.philosophy, ChallengeType.cognitiveBias}),
    );
    expect(
      challenges.map((challenge) => challenge.id).toSet(),
      hasLength(challenges.length),
    );
  });

  test('failed library reload clears previously loaded content', () async {
    await ChallengeLibrary.load(
      repository: InMemoryChallengeContentRepository([
        _challenge(id: 'phi_001', type: ChallengeType.philosophy),
        _challenge(id: 'cog_001', type: ChallengeType.cognitiveBias),
      ]),
    );

    expect(ChallengeLibrary.isLoaded, isTrue);

    await expectLater(
      ChallengeLibrary.load(
        repository: const _FailingChallengeContentRepository(),
      ),
      throwsA(isA<ChallengeContentException>()),
    );

    expect(ChallengeLibrary.isLoaded, isFalse);
    expect(() => ChallengeLibrary.allChallenges, throwsStateError);
  });

  test(
    'weekly picks preserve one philosophy and one cognitive bias challenge',
    () async {
      await ChallengeLibrary.load(
        repository: InMemoryChallengeContentRepository([
          _challenge(id: 'phi_001', type: ChallengeType.philosophy),
          _challenge(id: 'phi_002', type: ChallengeType.philosophy),
          _challenge(id: 'cog_001', type: ChallengeType.cognitiveBias),
          _challenge(id: 'cog_002', type: ChallengeType.cognitiveBias),
        ]),
      );

      final picks = ChallengeLibrary.pickWeeklyChallenges([
        'phi_001',
        'cog_001',
      ]);

      expect(picks, hasLength(2));
      expect(picks.map((challenge) => challenge.type), [
        ChallengeType.philosophy,
        ChallengeType.cognitiveBias,
      ]);
      expect(
        picks.map((challenge) => challenge.id),
        isNot(contains('phi_001')),
      );
      expect(
        picks.map((challenge) => challenge.id),
        isNot(contains('cog_001')),
      );
    },
  );

  test(
    'weekly picks fall back when recent ids exhaust a challenge type',
    () async {
      await ChallengeLibrary.load(
        repository: InMemoryChallengeContentRepository([
          _challenge(id: 'phi_001', type: ChallengeType.philosophy),
          _challenge(id: 'cog_001', type: ChallengeType.cognitiveBias),
        ]),
      );

      final picks = ChallengeLibrary.pickWeeklyChallenges([
        'phi_001',
        'cog_001',
      ]);

      expect(picks.map((challenge) => challenge.id), ['phi_001', 'cog_001']);
    },
  );
}

Map<String, Object> _challengeJson({
  required String id,
  required String type,
  int difficulty = 3,
}) =>
    {
      'id': id,
      'title': 'Challenge $id',
      'question': 'What should a careful thinker consider?',
      'type': type,
      'sourceName': 'Test Source',
      'sourceDescription': 'A test challenge source',
      'hintTiers': ['Hint one', 'Hint two', 'Hint three'],
      'category': 'Testing',
      'difficulty': difficulty,
      'thinkingAngles': ['angle one'],
    };

Challenge _challenge({
  required String id,
  required ChallengeType type,
}) =>
    Challenge(
      id: id,
      title: 'Challenge $id',
      question: 'What should a careful thinker consider?',
      type: type,
      sourceName: 'Test Source',
      sourceDescription: 'A test challenge source',
      hintTiers: const ['Hint one', 'Hint two', 'Hint three'],
      category: 'Testing',
      difficulty: 3,
      thinkingAngles: const ['angle one'],
    );

class _FileBackedAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

class _FailingChallengeContentRepository implements ChallengeContentRepository {
  const _FailingChallengeContentRepository();

  @override
  Future<List<Challenge>> loadChallenges() async {
    throw const ChallengeContentException('Invalid test content');
  }
}
