import 'package:intl/intl.dart';

class FormatUtils {
  static String formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  static String formatDurationCompact(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  static String formatTimer(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String formatHours(int seconds) {
    final hours = seconds / 3600;
    return '${hours.toStringAsFixed(1)}h';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String formatDateCompact(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String formatDayShort(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static String relativeDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return formatDateShort(date);
  }

  static String formatPercent(double value) {
    return '${value.toStringAsFixed(0)}%';
  }

  static String formatTargetHours(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
