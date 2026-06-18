import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../models/challenge_model.dart';
import '../services/challenge_library.dart';
import '../utils/theme.dart';
import '../widgets/brain_logo.dart';
import 'debate_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().refreshChallenges();
    });
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
        context.read<AppProvider>().refreshChallenges();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;
    final challenges = provider.weekChallenges;
    final countdown = provider.getCountdownToNextChallenge();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.refreshChallenges(),
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user, context),
                const SizedBox(height: 20),
                _buildXpCard(user, context),
                const SizedBox(height: 20),
                _buildStreakLoopCard(user, provider, context),
                const SizedBox(height: 20),
                if (countdown != null) _buildCountdown(countdown),
                if (countdown != null) const SizedBox(height: 20),
                Text('THIS WEEK\'S CHALLENGES',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        )),
                const SizedBox(height: 12),
                if (challenges.isEmpty)
                  _buildNoChallenges()
                else
                  ...challenges.map((uc) => _buildChallengeCard(uc, context, provider)),
                const SizedBox(height: 20),
                _buildQuickStats(user, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(user, BuildContext context) {
    return Row(
      children: [
        BrainLogo(size: 44, developmentPercent: user.brainDevelopmentPercent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, ${user.username}',
                  style: Theme.of(context).textTheme.titleLarge),
              Text(user.levelTitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (user.activityStreak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('${user.activityStreak}',
                    style: TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildXpCard(user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level ${user.level}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${user.xp} XP',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(user.levelTitle,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, letterSpacing: 0.5)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: user.xpProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
              '${user.currentLevelXp} / ${user.xpForNextLevel} XP to Level ${user.level + 1}',
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStreakLoopCard(user, AppProvider provider, BuildContext context) {
    final isAtRisk = provider.isWeeklyStreakAtRisk;
    final label = provider.perfectWeekLabel;
    final statusColor = label == 'Perfect week'
        ? AppTheme.successColor
        : label == 'Broken'
            ? AppTheme.errorColor
            : isAtRisk
                ? AppTheme.warningColor
                : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAtRisk
              ? AppTheme.warningColor.withValues(alpha: 0.35)
              : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Streak Loop',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              const Spacer(),
              Text(label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniStreakStat(
                'Activity',
                '${user.activityStreak}d',
                Icons.local_fire_department_outlined,
                AppTheme.warningColor,
                context,
              ),
              const SizedBox(width: 10),
              _miniStreakStat(
                'Weekly',
                '${user.weeklyCompletionStreak}w',
                Icons.calendar_view_week_outlined,
                AppTheme.primary,
                context,
              ),
              const SizedBox(width: 10),
              _miniStreakStat(
                'Best week',
                '${user.bestWeeklyCompletionStreak}w',
                Icons.emoji_events_outlined,
                AppTheme.successColor,
                context,
              ),
            ],
          ),
          if (isAtRisk) ...[
            const SizedBox(height: 12),
            Text(
              'A ready challenge is waiting. Finish it before it expires to protect the weekly streak.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningColor,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniStreakStat(
    String label,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      )),
                  Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown(Duration countdown) {
    final hours = countdown.inHours;
    final minutes = countdown.inMinutes % 60;
    final days = countdown.inDays;

    String label;
    if (days > 0) {
      label = '${days}d ${hours % 24}h until next challenge';
    } else if (hours > 0) {
      label = '${hours}h ${minutes}m until next challenge';
    } else {
      label = '${minutes}m until next challenge';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_outlined, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(UserChallenge uc, BuildContext context, AppProvider provider) {
    final challenge = ChallengeLibrary.getById(uc.challengeId);
    if (challenge == null) return const SizedBox.shrink();

    final isAvailable = DateTime.now().isAfter(uc.scheduledFor) ||
        uc.status == ChallengeStatus.inProgress ||
        uc.status == ChallengeStatus.open;
    final isCompleted = uc.status == ChallengeStatus.completed;
    final isSkipped = uc.status == ChallengeStatus.skipped;
    final isExpired = uc.status == ChallengeStatus.expired;
    final isTerminal = isCompleted || isSkipped || isExpired;
    final isPhilo = challenge.type == ChallengeType.philosophy;
    final typeColor = isPhilo ? AppTheme.philosophyColor : AppTheme.biasColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAvailable && !isTerminal
              ? typeColor.withValues(alpha: 0.4)
              : AppTheme.border,
          width: isAvailable && !isTerminal ? 1.5 : 1,
        ),
        boxShadow: isAvailable && !isTerminal
            ? [
                BoxShadow(
                    color: typeColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isTerminal
              ? null
              : () {
                  if (isAvailable) {
                    provider.openChallenge(uc.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DebateScreen(ucId: uc.id)),
                    );
                  } else {
                    _showLockedDialog(context, uc);
                  }
                },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(challenge.typeLabel,
                          style: TextStyle(
                              color: typeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    _difficultyDots(challenge.difficulty, typeColor),
                    const Spacer(),
                    _statusBadge(uc.status, isAvailable),
                  ],
                ),
                const SizedBox(height: 12),
                Text(challenge.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSkipped || isExpired
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          decoration: isSkipped || isExpired
                              ? TextDecoration.lineThrough
                              : null,
                        )),
                const SizedBox(height: 6),
                Text(
                  challenge.question.length > 120
                      ? '${challenge.question.substring(0, 120)}...'
                      : challenge.question,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(_formatSchedule(uc.scheduledFor),
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                    const Spacer(),
                    if (!isTerminal)
                      Row(
                        children: [
                          if (isAvailable)
                            TextButton.icon(
                              onPressed: () => provider.skipChallenge(uc.id),
                              icon: const Icon(Icons.close, size: 14),
                              label: const Text('Skip'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.errorColor,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          if (isAvailable)
                            Text('Tap to debate',
                                style: TextStyle(
                                    color: typeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600))
                          else
                            Text('Opens ${_timeUntil(uc.scheduledFor)}',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                          const SizedBox(width: 4),
                          Icon(
                            isAvailable ? Icons.arrow_forward : Icons.lock_outline,
                            size: 14,
                            color: isAvailable ? typeColor : AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    if (isCompleted)
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
                          const SizedBox(width: 4),
                          Text('+${uc.xpEarned} XP',
                              style: TextStyle(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                    if (isExpired)
                      Row(
                        children: [
                          Icon(Icons.timer_off_outlined,
                              color: AppTheme.errorColor, size: 16),
                          const SizedBox(width: 4),
                          Text('Expired',
                              style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _difficultyDots(int difficulty, Color color) {
    return Row(
      children: List.generate(5, (i) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < difficulty
                ? color
                : color.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }

  Widget _statusBadge(ChallengeStatus status, bool isAvailable) {
    switch (status) {
      case ChallengeStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Done',
              style: TextStyle(
                  color: AppTheme.successColor, fontSize: 11, fontWeight: FontWeight.w700)),
        );
      case ChallengeStatus.skipped:
      case ChallengeStatus.expired:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status == ChallengeStatus.expired ? 'Expired' : 'Skipped',
              style: TextStyle(
                  color: AppTheme.errorColor, fontSize: 11, fontWeight: FontWeight.w700)),
        );
      case ChallengeStatus.inProgress:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('Open',
              style: TextStyle(
                  color: AppTheme.warningColor, fontSize: 11, fontWeight: FontWeight.w700)),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isAvailable
                ? AppTheme.primary.withValues(alpha: 0.1)
                : AppTheme.border,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(isAvailable ? 'Ready' : 'Upcoming',
              style: TextStyle(
                  color: isAvailable ? AppTheme.primary : AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        );
    }
  }

  Widget _buildNoChallenges() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const BrainLogo(size: 50),
          const SizedBox(height: 12),
          Text('Loading this week\'s challenges...',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Pull to refresh',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildQuickStats(user, BuildContext context) {
    return Row(
      children: [
        _statCard('Completed', '${user.totalChallengesCompleted}',
            Icons.check_circle_outline, AppTheme.successColor, context),
        const SizedBox(width: 10),
        _statCard('Skipped', '${user.totalChallengesSkipped}',
            Icons.cancel_outlined, AppTheme.errorColor, context),
        const SizedBox(width: 10),
        _statCard('Best Activity', '${user.bestActivityStreak}d',
            Icons.local_fire_department_outlined, AppTheme.warningColor, context),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color,
      BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
            Text(label,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context, UserChallenge uc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Challenge Locked'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'This challenge opens on ${_formatSchedule(uc.scheduledFor)}.'),
            const SizedBox(height: 8),
            Text('Opens in: ${_timeUntil(uc.scheduledFor)}',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _formatSchedule(DateTime dt) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final hour = dt.hour;
    final ampm = hour >= 12 ? 'pm' : 'am';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day} at $h:00$ampm';
  }

  String _timeUntil(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m';
  }
}
