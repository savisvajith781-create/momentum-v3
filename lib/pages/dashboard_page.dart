import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import '../widgets/timer_widget.dart';
import '../widgets/progress_ring.dart';
import '../widgets/quote_card.dart';
import '../widgets/task_list_widget.dart';
import '../widgets/subject_breakdown.dart';
import '../widgets/surface_card.dart';
import '../widgets/page_transition.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: FadeSlideIn(
            child: isWide
                ? _WideLayout()
                : _NarrowLayout(),
          ),
        );
      },
    );
  }
}

class _WideLayout extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _DashboardHeader(),
              const SizedBox(height: 20),
              _ProgressSection(),
              const SizedBox(height: 20),
              _StatsRow(),
              const SizedBox(height: 20),
              _TodayBreakdownCard(),
              const SizedBox(height: 20),
              _WeeklySnapshotCard(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right column
        SizedBox(
          width: 300,
          child: Column(
            children: [
              const SizedBox(height: 72), // align with progress section
              const TimerWidget(),
              const SizedBox(height: 16),
              const QuoteCard(),
              const SizedBox(height: 16),
              _TodayTasksCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _NarrowLayout extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DashboardHeader(),
        const SizedBox(height: 20),
        const TimerWidget(),
        const SizedBox(height: 20),
        _ProgressSection(),
        const SizedBox(height: 20),
        _StatsRow(),
        const SizedBox(height: 20),
        const QuoteCard(),
        const SizedBox(height: 20),
        _TodayTasksCard(),
        const SizedBox(height: 20),
        _TodayBreakdownCard(),
      ],
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final greeting = _greeting(now.hour);
    final streak = ref.watch(currentStreakProvider);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, MMMM d').format(now),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        streak.when(
          data: (s) => s > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '$s day${s == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _ProgressSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final total = ref.watch(todayTotalSecondsProvider);
    final target = settings.dailyTargetSeconds;

    final progress = target > 0 ? (total / target).clamp(0.0, 1.0) : 0.0;
    final remaining = (target - total).clamp(0, target);
    final isComplete = total >= target;

    return SurfaceCard(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surface,
          AppColors.primary.withOpacity(0.05),
        ],
      ),
      child: Row(
        children: [
          ProgressRing(
            progress: progress,
            size: 120,
            strokeWidth: 10,
            color: isComplete ? AppColors.green : AppColors.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color:
                        isComplete ? AppColors.green : AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  'done',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S GOAL",
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  FormatUtils.formatTargetHours(target),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                _ProgressStat(
                  label: 'Completed',
                  value: FormatUtils.formatDurationCompact(total),
                  color: isComplete ? AppColors.green : AppColors.primary,
                ),
                const SizedBox(height: 8),
                _ProgressStat(
                  label: 'Remaining',
                  value: isComplete
                      ? 'Done! 🎉'
                      : FormatUtils.formatDurationCompact(remaining),
                  color: isComplete
                      ? AppColors.green
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProgressStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyReportProvider);

    return weeklyAsync.when(
      data: (report) => Row(
        children: [
          Expanded(
            child: _MiniStat(
              icon: '📚',
              label: 'This Week',
              value: report.formattedTotal,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStat(
              icon: '📈',
              label: 'Daily Avg',
              value: report.formattedAverage,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStat(
              icon: '🎯',
              label: 'Target Hit',
              value: '${report.daysHitTarget}/7',
              color: AppColors.orange,
            ),
          ),
        ],
      ),
      loading: () => const SizedBox(height: 70),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayBreakdownCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S BREAKDOWN",
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          const SubjectBreakdownWidget(),
        ],
      ),
    );
  }
}

class _TodayTasksCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TASKS",
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const TaskListWidget(maxItems: 5),
        ],
      ),
    );
  }
}

class _WeeklySnapshotCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyReportProvider);

    return weeklyAsync.when(
      data: (report) {
        return SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "THIS WEEK",
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: report.dailyBreakdown.map((day) {
                  final targetSecs = ref.read(settingsProvider).dailyTargetSeconds;
                  final progress = targetSecs > 0
                      ? (day.totalSeconds / targetSecs).clamp(0.0, 1.0)
                      : 0.0;
                  final isToday = FormatUtils.isToday(day.date);
                  final color = progress >= 1.0
                      ? AppColors.green
                      : progress > 0
                          ? AppColors.primary
                          : AppColors.surfaceVariant;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutCubic,
                                  height: 60 * progress,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('E').format(day.date)[0],
                            style: TextStyle(
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
