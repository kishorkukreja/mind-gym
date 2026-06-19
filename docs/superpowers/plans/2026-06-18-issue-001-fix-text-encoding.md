# Issue 001 Fix Text Encoding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove mojibake from app-authored text across the complete local-first challenge flow and add a regression test.

**Architecture:** Keep the app architecture unchanged. Make targeted text literal fixes in screens, models, services, and challenge content, then guard the source with a lightweight encoding regression test.

**Tech Stack:** Flutter, Dart, `flutter_test`, Provider, local Hive/shared-preferences storage.

---

### Task 1: Regression Test

**Files:**
- Create: `test/text_encoding_regression_test.dart`

- [ ] **Step 1: Write the failing test**

Create a Flutter test that scans Dart source files under `lib/` and fails if any obvious mojibake marker remains:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/services/challenge_library.dart';

void main() {
  test('app-authored Dart source does not contain obvious mojibake', () {
    final forbiddenPatterns = <RegExp>[
      RegExp('Ã'),
      RegExp('Â'),
      RegExp('â'),
      RegExp('ð'),
      RegExp('�'),
    ];

    final offenders = <String>[];
    for (final file
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final text = file.readAsStringSync();
      for (final pattern in forbiddenPatterns) {
        if (pattern.hasMatch(text)) {
          offenders.add('${file.path}: ${pattern.pattern}');
        }
      }
    }

    expect(offenders, isEmpty);
  });

  test('bundled challenge text and type labels are clean', () {
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

    expect(allText, isNot(contains('Ã')));
    expect(allText, isNot(contains('Â')));
    expect(allText, isNot(contains('â')));
    expect(allText, isNot(contains('ð')));
    expect(allText, isNot(contains('�')));
  });
}
```

- [ ] **Step 2: Verify red**

Run: `flutter test test/text_encoding_regression_test.dart`

Expected in the current broken state: FAIL with offenders in files such as `lib/services/challenge_library.dart`, `lib/services/openrouter_service.dart`, `lib/services/app_provider.dart`, `lib/screens/debate_screen.dart`, `lib/screens/progress_screen.dart`, `lib/screens/settings_screen.dart`, and `lib/models/challenge_model.dart`.

### Task 2: Clean App-Authored Text

**Files:**
- Modify: `lib/models/challenge_model.dart`
- Modify: `lib/services/app_provider.dart`
- Modify: `lib/services/openrouter_service.dart`
- Modify: `lib/services/schedule_service.dart`
- Modify: `lib/services/challenge_library.dart`
- Modify: `lib/screens/home_screen.dart`
- Modify: `lib/screens/debate_screen.dart`
- Modify: `lib/screens/progress_screen.dart`
- Modify: `lib/screens/settings_screen.dart`

- [ ] **Step 1: Replace decorative encoded emoji and symbols**

Use Material icons where already present, or ASCII text where a string value is needed.

Examples:

```dart
// Before
Text('${user.bestStreak}ðŸ”¥')

// After
Text('${user.bestStreak}')
```

```dart
// Before
return type == ChallengeType.philosophy ? 'ðŸ›ï¸ Philosophy' : 'ðŸ§  Cognitive Bias';

// After
return type == ChallengeType.philosophy ? 'Philosophy' : 'Cognitive Bias';
```

- [ ] **Step 2: Replace punctuation mojibake with clean ASCII**

Examples:

```dart
// Before
'${user.currentLevelXp} / ${user.xpForNextLevel} XP Â· Level ${user.level} â†’ ${user.level + 1}'

// After
'${user.currentLevelXp} / ${user.xpForNextLevel} XP - Level ${user.level} -> ${user.level + 1}'
```

```dart
// Before
'"${challenge.title}" â€” Tap to show full question'

// After
'"${challenge.title}" - Tap to show full question'
```

- [ ] **Step 3: Replace AI fallback/error copy**

Examples:

```dart
// Before
return 'âš ï¸ Invalid API key. Please update your OpenRouter key in Settings.';

// After
return 'Invalid API key. Please update your OpenRouter key in Settings.';
```

```dart
// Before
return 'ðŸ’¡ No more hints available. You have all the clues you need â€” now THINK.';

// After
return 'No more hints available. You have all the clues you need - now THINK.';
```

- [ ] **Step 4: Run focused verification**

Run: `flutter test test/text_encoding_regression_test.dart`

Expected: PASS.

### Task 3: Broader Verification And Publishing

**Files:**
- No new code files unless verification reveals a scoped issue.

- [ ] **Step 1: Run broader checks**

Run:

```bash
flutter test
flutter analyze
```

Expected: test and analyzer success, or a documented environment blocker if Flutter is unavailable.

- [ ] **Step 2: Independent review**

Run a second source scan for the forbidden markers and inspect the scoped diff.

- [ ] **Step 3: Commit and open PR**

Stage only files touched for issue #1. Commit with:

```bash
git commit -m "fix text encoding across challenge flow"
```

Push `codex/issue-001-fix-text-encoding`, open a draft PR linked to #1, and comment on the issue with verification status.
