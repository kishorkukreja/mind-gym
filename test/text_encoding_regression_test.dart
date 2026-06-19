import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/services/challenge_library.dart';

void main() {
  test('app-authored Dart source stays ASCII-clean', () {
    final forbiddenPatterns = <RegExp>[
      RegExp('\u00c3'),
      RegExp('\u00c2'),
      RegExp('\u00e2'),
      RegExp('\u00f0'),
      RegExp('\ufffd'),
      RegExp(r'[^\x00-\x7F]'),
    ];

    final offenders = <String>[];
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      final text = file.readAsStringSync();
      for (final pattern in forbiddenPatterns) {
        if (pattern.hasMatch(text)) {
          offenders.add('${file.path}: ${pattern.pattern}');
        }
      }
    }

    expect(offenders, isEmpty);
  });

  test('bundled challenge text and type labels stay ASCII-clean', () {
    final allText = <String>[
      for (final challenge in ChallengeLibrary.allChallenges) ...[
        challenge.title,
        challenge.question,
        challenge.typeLabel,
        challenge.sourceName,
        challenge.sourceDescription,
        challenge.category,
        ...challenge.hintTiers,
        ...challenge.thinkingAngles,
      ],
    ].join('\n');

    expect(allText, isNot(contains('\u00c3')));
    expect(allText, isNot(contains('\u00c2')));
    expect(allText, isNot(contains('\u00e2')));
    expect(allText, isNot(contains('\u00f0')));
    expect(allText, isNot(contains('\ufffd')));
    expect(allText, matches(RegExp(r'^[\x00-\x7F]*$')));
  });
}
