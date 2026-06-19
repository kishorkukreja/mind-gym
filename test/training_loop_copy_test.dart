import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'core training-loop source no longer includes common mojibake markers',
    () {
      final mojibakeMarkers = [
        String.fromCharCode(0x00F0),
        String.fromCharCode(0x00E2),
        String.fromCharCode(0x00C2),
      ];
      const paths = [
        'lib/services/app_provider.dart',
        'lib/screens/debate_screen.dart',
        'lib/screens/home_screen.dart',
        'lib/screens/progress_screen.dart',
      ];

      for (final path in paths) {
        final source = File(path).readAsStringSync();

        for (final marker in mojibakeMarkers) {
          expect(source, isNot(contains(marker)), reason: path);
        }
      }
    },
  );
}
