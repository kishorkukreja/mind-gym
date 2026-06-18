import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/main.dart';

void main() {
  testWidgets('Mind Gym smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MindGymApp());
    await tester.pump();
    expect(find.byType(MindGymApp), findsOneWidget);
  });
}
