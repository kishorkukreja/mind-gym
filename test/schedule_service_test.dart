import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/services/schedule_service.dart';

void main() {
  test('quality score influences XP when evaluation metadata is available', () {
    final fallbackXp = ScheduleService.calculateXpReward(
      hintsUsed: 0,
      responseCount: 2,
      difficulty: 3,
      onTime: true,
    );
    final evaluatedXp = ScheduleService.calculateXpReward(
      hintsUsed: 0,
      responseCount: 2,
      difficulty: 3,
      onTime: true,
      qualityScore: 5,
    );

    expect(evaluatedXp, greaterThan(fallbackXp));
  });
}
