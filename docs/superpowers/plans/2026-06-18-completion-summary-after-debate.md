# Completion Summary After Debate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a persisted, explainable completion summary after debate challenges.

**Architecture:** Store summary data on `UserChallenge` so local persistence keeps the exact summary shown at completion time. Keep scoring factor generation in `ScheduleService`, and keep UI rendering inside `DebateScreen` with simple route pops for Home and Progress navigation.

**Tech Stack:** Flutter, Provider, SharedPreferences JSON persistence, `flutter_test`.

---

### Task 1: Completion Summary Model

**Files:**
- Modify: `lib/models/challenge_model.dart`
- Test: `test/completion_summary_model_test.dart`

- [ ] **Step 1: Write the failing serialization test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';

void main() {
  test('persists completion summary data with a user challenge', () {
    final completedAt = DateTime(2026, 6, 18, 10);
    final uc = UserChallenge(
      id: 'uc-1',
      challengeId: 'challenge-1',
      userId: 'user-1',
      scheduledFor: DateTime(2026, 6, 17, 10),
      completedAt: completedAt,
      status: ChallengeStatus.completed,
      xpEarned: 130,
      completionSummary: CompletionSummary(
        totalXp: 130,
        factors: const [
          XpFactor(label: 'Difficulty', points: 120, detail: 'Hard challenge'),
          XpFactor(label: 'Hints', points: -10, detail: '1 hint used'),
        ],
        feedback: 'You made a clear argument.',
        nextStep: 'Name the strongest objection next time.',
      ),
    );

    final restored = UserChallenge.fromJson(uc.toJson());

    expect(restored.completionSummary?.totalXp, 130);
    expect(restored.completionSummary?.factors, hasLength(2));
    expect(restored.completionSummary?.factors.first.label, 'Difficulty');
    expect(restored.completionSummary?.factors.last.points, -10);
    expect(restored.completionSummary?.feedback, 'You made a clear argument.');
    expect(restored.completionSummary?.nextStep, 'Name the strongest objection next time.');
  });
}
```

- [ ] **Step 2: Run the focused test to verify it fails**

Run: `flutter test test/completion_summary_model_test.dart`

Expected: fail because `CompletionSummary`, `XpFactor`, and `UserChallenge.completionSummary` do not exist.

- [ ] **Step 3: Add model classes and JSON support**

Add immutable `XpFactor` and `CompletionSummary` classes with `toJson`/`fromJson`, then add `CompletionSummary? completionSummary` to `UserChallenge`.

- [ ] **Step 4: Run the focused test**

Run: `flutter test test/completion_summary_model_test.dart`

Expected: pass.

### Task 2: Explainable Scoring Result

**Files:**
- Modify: `lib/services/schedule_service.dart`
- Test: `test/schedule_service_scoring_test.dart`

- [ ] **Step 1: Write the failing scoring test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/services/schedule_service.dart';

void main() {
  test('builds named XP factors that add up to the total reward', () {
    final result = ScheduleService.calculateXpBreakdown(
      hintsUsed: 1,
      responseCount: 3,
      difficulty: 3,
      onTime: true,
    );

    expect(result.totalXp, 125);
    expect(result.factors.map((factor) => factor.label), [
      'Difficulty',
      'Hints',
      'Engagement',
      'Timeliness',
    ]);
    expect(
      result.factors.fold<int>(0, (sum, factor) => sum + factor.points),
      result.totalXp,
    );
  });
}
```

- [ ] **Step 2: Run the focused test to verify it fails**

Run: `flutter test test/schedule_service_scoring_test.dart`

Expected: fail because `calculateXpBreakdown` does not exist.

- [ ] **Step 3: Add `XpBreakdownResult` and factor calculation**

Create a result object that returns `totalXp` and the four named factors. Keep `calculateXpReward` delegating to the new result so existing callers still work.

- [ ] **Step 4: Run the focused test**

Run: `flutter test test/schedule_service_scoring_test.dart`

Expected: pass.

### Task 3: Provider Summary Creation

**Files:**
- Modify: `lib/services/app_provider.dart`

- [ ] **Step 1: Update completion flow**

In `markChallengeComplete`, call `ScheduleService.calculateXpBreakdown`, persist `CompletionSummary`, and return it from the method.

- [ ] **Step 2: Update callers**

Update `DebateScreen._markComplete` to expect a `CompletionSummary?`.

### Task 4: Completion Summary UI

**Files:**
- Modify: `lib/screens/debate_screen.dart`
- Test: `test/completion_summary_dialog_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/screens/debate_screen.dart';

void main() {
  testWidgets('completion summary dialog renders XP factors and navigation', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () {
              DebateCompletionDialog.show(
                context,
                const CompletionSummary(
                  totalXp: 125,
                  factors: [
                    XpFactor(label: 'Difficulty', points: 120, detail: 'Difficulty 3'),
                    XpFactor(label: 'Hints', points: -10, detail: '1 hint used'),
                    XpFactor(label: 'Engagement', points: 15, detail: '3 responses'),
                    XpFactor(label: 'Timeliness', points: 0, detail: 'Completed on time'),
                  ],
                  feedback: 'You built a clear argument.',
                  nextStep: 'Push harder on counterarguments next time.',
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Completion Summary'), findsOneWidget);
    expect(find.text('+125 XP'), findsOneWidget);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('Hints'), findsOneWidget);
    expect(find.text('You built a clear argument.'), findsOneWidget);
    expect(find.text('Push harder on counterarguments next time.'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the focused test to verify it fails**

Run: `flutter test test/completion_summary_dialog_test.dart`

Expected: fail because `DebateCompletionDialog` does not exist.

- [ ] **Step 3: Extract summary dialog widget**

Add `DebateCompletionDialog.show` and render total XP, factors, feedback, next step, Home, and Progress buttons.

- [ ] **Step 4: Run focused and full tests**

Run: `flutter test test/completion_summary_dialog_test.dart test/completion_summary_model_test.dart test/schedule_service_scoring_test.dart`

Run: `flutter test`

Expected: all tests pass when Flutter is available.
