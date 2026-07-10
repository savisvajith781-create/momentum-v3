import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';
import '../providers/settings_provider.dart';
import '../models/stats_model.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import '../widgets/surface_card.dart';
import '../widgets/heatmap_widget.dart';
import '../widgets/page_transition.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);

    return FadeSlideIn(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatisticsHeader(period: period),
            const SizedBox(height: 24),
            _PeriodSelector(current: period),
            const SizedBox(height: 24),
            _WeeklySummaryCards(),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _DailyBarChart(period: period)),
                const SizedBox(width: 20),
                Expanded(child: _SubjectPieChart(period: period)),
              ],
            ),
            const SizedBox(height: 20),
            _HeatmapSection(),
            const SizedBox(height: 20),
            _SubjectTableSection(period: period),
          ],
        ),
      ),
    );
  }
}

class _StatisticsHeader extends StatelessWidget {
  final StatsPeriod period;
  const _StatisticsHeader({required this.period});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Track your progress over time',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _PeriodSelector extends ConsumerWidget {
  final StatsPeriod current;
  const _PeriodSelector({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurfaceCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: StatsPeriod.values.map((p) {
          final isSelected = p == current;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(statsPeriodProvider.notifier).state = p,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  p.name[0].toUpperCase() + p.name.substring(1),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WeeklySummaryCards extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(weeklyReportProvider);
    final streakAsync = ref.watch(currentStreakProvider);

    return reportAsync.when(
      data: (report) => Row(
        children: [
          Expanded(
            child: _BigStatCard(
              emoji: '⏱️',
              label: 'This Week',
              value: report.formattedTotal,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BigStatCard(
              emoji: '📊',
              label: 'Daily Avg',
              value: report.formattedAverage,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: streakAsync.when(
              data: (streak) => _BigStatCard(
                emoji: '🔥',
                label: 'Streak',
                value: '$streak days',
                color: AppColors.orange,
              ),
              loading: () => const SizedBox(height: 80),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BigStatCard(
              emoji: '🎯',
              label: 'Target Hit',
              value: '${report.daysHitTarget}/7',
              color: AppColors.purple,
            ),
          ),
        ],
      ),
      loading: () => const SizedBox(height: 80),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _BigStatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyBarChart extends ConsumerWidget {
  final StatsPeriod period;
  const _DailyBarChart({required this.period});

  ({DateTime start, DateTime end}) _getRange() {
    final now = DateTime.now();
    switch (period) {
      case StatsPeriod.daily:
        return (
          start: DateTime(now.year, now.month, now.day - 6),
          end: now
        );
      case StatsPeriod.weekly:
        return (
          start: DateTime(now.year, now.month, now.day - 27),
          end: now
        );
      case StatsPeriod.monthly:
        return (start: DateTime(now.year, now.month - 5, 1), end: now);
      case StatsPeriod.yearly:
        return (start: DateTime(now.year - 1, now.month, 1), end: now);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = _getRange();
    final statsAsync =
        ref.watch(dailyStatsRangeProvider((start: range.start, end: range.end)));
    final targetSeconds = ref.watch(settingsProvider).dailyTargetSeconds;

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Hours',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          statsAsync.when(
            data: (stats) {
              if (stats.isEmpty) {
                return const SizedBox(
                  height: 180,
                  child: Center(
                    child: Text(
                      'No data yet',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                );
              }

              final maxVal = stats.isEmpty
                  ? 1.0
                  : stats
                          .map((s) => s.totalHours)
                          .reduce((a, b) => a > b ? a : b)
                          .clamp(0.1, double.infinity) *
                      1.2;

              return SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: AppColors.surfaceElevated,
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final day = stats[groupIndex];
                          return BarTooltipItem(
                            '${FormatUtils.formatDateShort(day.date)}\n',
                            const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            children: [
                              TextSpan(
                                text: FormatUtils.formatDurationCompact(
                                    day.totalSeconds),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: stats.length > 14
                              ? (stats.length / 7).ceil().toDouble()
                              : 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= stats.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                FormatUtils.formatDayShort(
                                    stats[index].date),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              '${value.toStringAsFixed(0)}h',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxVal / 4,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: AppColors.border,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    extraLinesData: targetSeconds > 0
                        ? ExtraLinesData(
                            horizontalLines: [
                              HorizontalLine(
                                y: targetSeconds / 3600,
                                color: AppColors.primary.withOpacity(0.4),
                                strokeWidth: 1.5,
                                dashArray: [4, 4],
                                label: HorizontalLineLabel(
                                  show: true,
                                  alignment: Alignment.topRight,
                                  padding: const EdgeInsets.only(right: 4),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                  ),
                                  labelResolver: (_) => 'target',
                                ),
                              ),
                            ],
                          )
                        : null,
                    barGroups: stats.asMap().entries.map((e) {
                      final hours = e.value.totalHours;
                      final hitTarget = targetSeconds > 0 &&
                          e.value.totalSeconds >= targetSeconds;
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: hours,
                            color: hours == 0
                                ? AppColors.surfaceVariant
                                : hitTarget
                                    ? AppColors.green
                                    : AppColors.primary,
                            width: stats.length > 20 ? 6 : 12,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}

class _SubjectPieChart extends ConsumerWidget {
  final StatsPeriod period;
  const _SubjectPieChart({required this.period});

  ({DateTime start, DateTime end}) _getRange() {
    final now = DateTime.now();
    switch (period) {
      case StatsPeriod.daily:
        return (start: DateTime(now.year, now.month, now.day), end: now);
      case StatsPeriod.weekly:
        return (
          start: DateTime(now.year, now.month, now.day - 6),
          end: now
        );
      case StatsPeriod.monthly:
        return (start: DateTime(now.year, now.month, 1), end: now);
      case StatsPeriod.yearly:
        return (start: DateTime(now.year, 1, 1), end: now);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = _getRange();
    final statsAsync = ref.watch(
        subjectStatsProvider((start: range.start, end: range.end)));

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'By Subject',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) {
              if (stats.isEmpty) {
                return const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'No data yet',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                );
              }

              final total = stats.fold<int>(0, (s, e) => s + e.totalSeconds);

              return Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        sections: stats.take(6).map((s) {
                          final pct = total > 0
                              ? s.totalSeconds / total
                              : 0.0;
                          return PieChartSectionData(
                            value: s.totalSeconds.toDouble(),
                            color: Color(s.colorValue),
                            radius: 60,
                            showTitle: pct > 0.08,
                            title:
                                '${(pct * 100).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                        centerSpaceRadius: 36,
                        sectionsSpace: 2,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...stats.take(5).map((s) {
                    final pct = total > 0
                        ? (s.totalSeconds / total * 100)
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(s.colorValue),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.subjectName,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Color(s.colorValue),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}

class _HeatmapSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(heatmapDataProvider);
    final targetSeconds = ref.watch(settingsProvider).dailyTargetSeconds;

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Heatmap',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Last 20 weeks',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          heatmapAsync.when(
            data: (data) => HeatmapWidget(
              data: data,
              targetSeconds: targetSeconds,
            ),
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}

class _SubjectTableSection extends ConsumerWidget {
  final StatsPeriod period;
  const _SubjectTableSection({required this.period});

  ({DateTime start, DateTime end}) _getRange() {
    final now = DateTime.now();
    switch (period) {
      case StatsPeriod.daily:
        return (start: DateTime(now.year, now.month, now.day), end: now);
      case StatsPeriod.weekly:
        return (
          start: DateTime(now.year, now.month, now.day - 6),
          end: now
        );
      case StatsPeriod.monthly:
        return (start: DateTime(now.year, now.month, 1), end: now);
      case StatsPeriod.yearly:
        return (start: DateTime(now.year, 1, 1), end: now);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = _getRange();
    final statsAsync = ref.watch(
        subjectStatsProvider((start: range.start, end: range.end)));

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subject Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) {
              if (stats.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No data for this period',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                );
              }

              final total =
                  stats.fold<int>(0, (s, e) => s + e.totalSeconds);

              return Column(
                children: [
                  // Table header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Subject',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Sessions',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Time',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Share',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 8),
                  ...stats.map((s) {
                    final pct = total > 0
                        ? (s.totalSeconds / total * 100)
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Color(s.colorValue),
                                    borderRadius:
                                        BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  s.subjectName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${s.sessionCount}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s.formattedTotal,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Color(s.colorValue),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(color: AppColors.border, height: 16),
                  Row(
                    children: [
                      const Expanded(
                        flex: 3,
                        child: Text(
                          'Total',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          stats
                              .fold<int>(0, (s, e) => s + e.sessionCount)
                              .toString(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          FormatUtils.formatDurationCompact(total),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          '100%',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}
