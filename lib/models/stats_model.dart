class DailyStats {
  final DateTime date;
  final int totalSeconds;
  final Map<String, int> subjectSeconds;
  final int sessionCount;

  const DailyStats({
    required this.date,
    required this.totalSeconds,
    required this.subjectSeconds,
    required this.sessionCount,
  });

  String get formattedTotal {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  double get totalHours => totalSeconds / 3600.0;
}

class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalSeconds;
  final double averageSecondsPerDay;
  final Map<String, int> subjectSeconds;
  final int targetSeconds;
  final int daysHitTarget;
  final int streak;
  final DateTime? bestDay;
  final int bestDaySeconds;
  final DateTime? worstDay;
  final int worstDaySeconds;
  final List<DailyStats> dailyBreakdown;

  const WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    required this.totalSeconds,
    required this.averageSecondsPerDay,
    required this.subjectSeconds,
    required this.targetSeconds,
    required this.daysHitTarget,
    required this.streak,
    this.bestDay,
    required this.bestDaySeconds,
    this.worstDay,
    required this.worstDaySeconds,
    required this.dailyBreakdown,
  });

  double get targetAchievementPercent {
    if (targetSeconds <= 0) return 0;
    final weekTarget = targetSeconds * 7;
    return (totalSeconds / weekTarget * 100).clamp(0, 100);
  }

  String get formattedTotal {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    return '${h}h ${m}m';
  }

  String get formattedAverage {
    final h = averageSecondsPerDay.toInt() ~/ 3600;
    final m = (averageSecondsPerDay.toInt() % 3600) ~/ 60;
    return '${h}h ${m}m';
  }
}

class SubjectStats {
  final String subjectId;
  final String subjectName;
  final int totalSeconds;
  final int sessionCount;
  final int colorValue;

  const SubjectStats({
    required this.subjectId,
    required this.subjectName,
    required this.totalSeconds,
    required this.sessionCount,
    required this.colorValue,
  });

  double get totalHours => totalSeconds / 3600.0;
  String get formattedTotal {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    return '${h}h ${m}m';
  }
}
