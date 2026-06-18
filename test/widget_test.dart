import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_gym/main.dart';
import 'package:mind_gym/services/app_provider.dart';

void main() {
  testWidgets('Mind Gym smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MindGymApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MindGymApp), findsOneWidget);
  });
}
