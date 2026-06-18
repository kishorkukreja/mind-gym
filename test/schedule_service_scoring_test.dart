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
