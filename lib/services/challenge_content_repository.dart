import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/challenge_model.dart';

abstract class ChallengeContentRepository {
  Future<List<Challenge>> loadChallenges();
}

class AssetChallengeContentRepository implements ChallengeContentRepository {
  static const defaultAssetPath = 'assets/content/challenges.json';

  final AssetBundle bundle;
  final String assetPath;

  AssetChallengeContentRepository({
    AssetBundle? bundle,
    this.assetPath = defaultAssetPath,
  }) : bundle = bundle ?? rootBundle;

  @override
  Future<List<Challenge>> loadChallenges() async {
    try {
      final raw = await bundle.loadString(assetPath);
      return JsonChallengeContentParser.parse(raw, source: assetPath);
    } on ChallengeContentException {
      rethrow;
    } catch (error) {
      throw ChallengeContentException(
        'Failed to load challenge content from $assetPath: $error',
      );
    }
  }
}

class InMemoryChallengeContentRepository implements ChallengeContentRepository {
  final List<Challenge> challenges;

  const InMemoryChallengeContentRepository(this.challenges);

  @override
  Future<List<Challenge>> loadChallenges() async =>
      List<Challenge>.unmodifiable(challenges);
}

class JsonChallengeContentParser {
  const JsonChallengeContentParser._();

  static List<Challenge> parse(String raw, {String source = 'content'}) {
    final decoded = _decode(raw, source);
    final version = decoded['version'];
    if (version == null) {
      throw ChallengeContentException(
        'Challenge content in $source is missing "version".',
      );
    }

    final challengeItems = decoded['challenges'];
    if (challengeItems is! List || challengeItems.isEmpty) {
      throw ChallengeContentException(
        'Challenge content in $source must include a non-empty "challenges" list.',
      );
    }

    final seenIds = <String>{};
    final challenges = <Challenge>[];
    for (var index = 0; index < challengeItems.length; index++) {
      final item = challengeItems[index];
      if (item is! Map<String, dynamic>) {
        throw ChallengeContentException(
          'Challenge entry $index in $source must be an object.',
        );
      }

      final challenge = Challenge.fromJson(item, source: source);
      if (!seenIds.add(challenge.id)) {
        throw ChallengeContentException(
          'Duplicate challenge id "${challenge.id}" in $source.',
        );
      }
      challenges.add(challenge);
    }

    return List<Challenge>.unmodifiable(challenges);
  }

  static Map<String, dynamic> _decode(String raw, String source) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (error) {
      throw ChallengeContentException(
        'Challenge content in $source is not valid JSON: $error',
      );
    }

    throw ChallengeContentException(
      'Challenge content in $source must be a JSON object.',
    );
  }
}
