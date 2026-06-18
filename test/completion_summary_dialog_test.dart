import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/models/challenge_model.dart';
import 'package:mind_gym/screens/debate_screen.dart';

void main() {
  testWidgets('completion summary dialog renders XP factors and navigation',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                DebateCompletionDialog.show(
                  context,
                  const CompletionSummary(
                    totalXp: 125,
                    factors: [
                      XpFactor(
                        label: 'Difficulty',
                        points: 120,
                        detail: 'Difficulty 3',
                      ),
                      XpFactor(
                        label: 'Hints',
                        points: -10,
                        detail: '1 hint used',
                      ),
                      XpFactor(
                        label: 'Engagement',
                        points: 15,
                        detail: '3 responses',
                      ),
                      XpFactor(
                        label: 'Timeliness',
                        points: 0,
                        detail: 'Completed on time',
                      ),
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
      ),
    );

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
