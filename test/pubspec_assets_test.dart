import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('declared Flutter asset paths exist', () {
    final declaredAssets = _declaredFlutterAssets(File('pubspec.yaml'));

    expect(declaredAssets, isNotEmpty);

    for (final assetPath in declaredAssets) {
      final exists = Directory(assetPath).existsSync() ||
          File(assetPath).existsSync();
      expect(
        exists,
        isTrue,
        reason: 'Declared Flutter asset path "$assetPath" does not exist.',
      );
    }
  });
}

List<String> _declaredFlutterAssets(File pubspec) {
  final assets = <String>[];
  var inFlutterSection = false;
  var inAssetsSection = false;

  for (final line in pubspec.readAsLinesSync()) {
    if (line.trim().isEmpty) {
      continue;
    }

    if (!line.startsWith(' ')) {
      inFlutterSection = line.trim() == 'flutter:';
      inAssetsSection = false;
      continue;
    }

    if (!inFlutterSection) {
      continue;
    }

    if (line.startsWith('  ') && !line.startsWith('    ')) {
      inAssetsSection = line.trim() == 'assets:';
      continue;
    }

    if (!inAssetsSection) {
      continue;
    }

    final match = RegExp(r'^\s+-\s+(.+)$').firstMatch(line);
    if (match != null) {
      assets.add(match.group(1)!.trim());
    }
  }

  return assets;
}
