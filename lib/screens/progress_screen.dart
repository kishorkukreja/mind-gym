import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/schedule_service.dart';
import '../utils/theme.dart';
import '../widgets/brain_logo.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final stats = provider.getWeeklyPerformance();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('YOUR PROGRESS', style: AppTheme.sectionLabelStyle),
              const SizedBox(height: 20),

              // Brain visualization
              Center(
                child: Column(
                  children: [
                    BrainProgress(
                      developmentPercent: user.brainDevelopmentPercent,
                      level: user.level,
                      levelTitle: user.levelTitle,
                    ),
                    const SizedBox(height: 12),
                    Text('Level ${user.level}: ${user.levelTitle}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primary,
                            ),
                        textAlign: TextAlign.center),
                    Text('${(user.brainDevelopmentPercent * 100).toStringAsFixed(0)}% Brain Development',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              _buildXpSection(user, context),
              const SizedBox(height: 20),
              _buildWeeklyReport(stats, context),
              const SizedBox(height: 20),
              _buildAllTimeStats(user, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildXpSection(user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total XP',
                      style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  Text('${user.xp}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 32)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Next Level',
                      style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  Text('${user.xpForNextLevel - user.currentLevelXp} XP away',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: LinearProgressIndicator(
              value: user.xpProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
              '${user.currentLevelXp} / ${user.xpForNextLevel} XP • Level ${user.level} → ${user.level + 1}',
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport(Map<String, dynamic> stats, BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final grade = stats['grade'] as String;
    final brutalComment = ScheduleService.getBrutalComment(
        grade, (stats['thisSkipped'] as int? ?? 0));

    Color gradeColor;
    switch (grade[0]) {
      case 'A':
        gradeColor = AppTheme.successColor;
        break;
      case 'B':
        gradeColor = AppTheme.primary;
        break;
      case 'C':
        gradeColor = AppTheme.warningColor;
        break;
      default:
        gradeColor = AppTheme.errorColor;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('WEEKLY REPORT', style: AppTheme.sectionLabelStyle),
              const Spacer(),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: gradeColor.withValues(alpha: 0.3), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(grade,
                    style: TextStyle(
                        color: gradeColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _weekStat('Done', '${stats['thisCompleted']}', AppTheme.successColor, context),
              _weekStat('Skipped', '${stats['thisSkipped']}', AppTheme.errorColor, context),
              _weekStat('Total', '${stats['thisTotal']}', AppTheme.primary, context),
              _weekStat(
                'vs Last Wk',
                '${((stats['thisRate'] as double) * 100).toStringAsFixed(0)}% vs ${((stats['prevRate'] as double) * 100).toStringAsFixed(0)}%',
                (stats['thisRate'] as double) >= (stats['prevRate'] as double)
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
                context,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Brutal commentary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.rate_review_outlined,
                color: AppTheme.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(brutalComment,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weekStat(String label, String value, Color color, BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.metricStyle.copyWith(color: color, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          Text(label,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildAllTimeStats(user, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ALL TIME', style: AppTheme.sectionLabelStyle),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _allTimeStat('Challenges Done', '${user.totalChallengesCompleted}',
                Icons.check_circle_outline, AppTheme.successColor, context),
            _allTimeStat('Challenges Skipped', '${user.totalChallengesSkipped}',
                Icons.cancel_outlined, AppTheme.errorColor, context),
            _allTimeStat('Current Streak', '${user.currentStreak} weeks',
                Icons.local_fire_department_outlined, AppTheme.warningColor, context),
            _allTimeStat('Best Streak', '${user.bestStreak} weeks',
                Icons.emoji_events_outlined, AppTheme.primary, context),
          ],
        ),
      ],
    );
  }

  Widget _allTimeStat(String label, String value, IconData icon, Color color,
      BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: AppTheme.metricStyle.copyWith(fontSize: 16)),
                Text(label,
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
