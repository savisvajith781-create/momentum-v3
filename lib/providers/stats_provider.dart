import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stats_model.dart';
import 'core_providers.dart';
import 'settings_provider.dart';
import 'subjects_provider.dart';

enum StatsPeriod { daily, weekly, monthly, yearly }

final statsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.weekly);

final heatmapDataProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  return ref.read(sessionRepositoryProvider).getHeatmapData(6);
});

final weeklyReportProvider = FutureProvider<WeeklyReport>((ref) async {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
  final weekEndDate = weekStartDate.add(const Duration(days: 6));
  final targetSeconds = ref.watch(settingsProvider).dailyTargetSeconds;

  final dailyStats = await ref.read(sessionRepositoryProvider).getDailyStats(
    weekStartDate,
    weekEndDate,
  );

  // Build a subjectId -> name lookup so exported reports show readable labels
  final subjects = await ref.read(subjectRepositoryProvider).getAllSubjects();
  final idToName = {for (final s in subjects) s.id: s.name};

  int totalSeconds = 0;
  int daysHitTarget = 0;
  DateTime? bestDay;
  int bestDaySeconds = 0;
  DateTime? worstDay;
  int worstDaySeconds = 999999;
  final Map<String, int> subjectSeconds = {};

  for (final day in dailyStats) {
    totalSeconds += day.totalSeconds;
    if (day.totalSeconds >= targetSeconds) daysHitTarget++;
    if (day.totalSeconds > bestDaySeconds) {
      bestDaySeconds = day.totalSeconds;
      bestDay = day.date;
    }
    if (day.totalSeconds < worstDaySeconds && day.totalSeconds > 0) {
      worstDaySeconds = day.totalSeconds;
      worstDay = day.date;
    }
    for (final entry in day.subjectSeconds.entries) {
      final label = idToName[entry.key] ?? entry.key;
      subjectSeconds[label] = (subjectSeconds[label] ?? 0) + entry.value;
    }
  }

  final streak = await ref
      .read(sessionRepositoryProvider)
      .getCurrentStreak(targetSeconds);

  return WeeklyReport(
    weekStart: weekStartDate,
    weekEnd: weekEndDate,
    totalSeconds: totalSeconds,
    averageSecondsPerDay:
        dailyStats.isEmpty ? 0 : totalSeconds / dailyStats.length,
    subjectSeconds: subjectSeconds,
    targetSeconds: targetSeconds,
    daysHitTarget: daysHitTarget,
    streak: streak,
    bestDay: bestDay,
    bestDaySeconds: bestDaySeconds,
    worstDay: worstDaySeconds == 999999 ? null : worstDay,
    worstDaySeconds: worstDaySeconds == 999999 ? 0 : worstDaySeconds,
    dailyBreakdown: dailyStats,
  );
});

final subjectStatsProvider = FutureProvider.family<List<SubjectStats>,
    ({DateTime start, DateTime end})>((ref, range) async {
  return ref
      .read(sessionRepositoryProvider)
      .getSubjectStats(range.start, range.end)
      .timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception(
            'Loading subject stats took too long. Try again.'),
      );
});

final dailyStatsRangeProvider = FutureProvider.family<List<DailyStats>,
    ({DateTime start, DateTime end})>((ref, range) async {
  return ref
      .read(sessionRepositoryProvider)
      .getDailyStats(range.start, range.end)
      .timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception(
            'Loading daily stats took too long. Try again.'),
      );
});

final currentStreakProvider = FutureProvider<int>((ref) async {
  final targetSeconds = ref.watch(settingsProvider).dailyTargetSeconds;
  return ref
      .read(sessionRepositoryProvider)
      .getCurrentStreak(targetSeconds);
});
