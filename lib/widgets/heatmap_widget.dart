import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';

class HeatmapWidget extends StatelessWidget {
  final Map<DateTime, int> data;
  final int targetSeconds;
  final Color activeColor;

  const HeatmapWidget({
    super.key,
    required this.data,
    required this.targetSeconds,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weeks = 20;
    final days = weeks * 7;

    // Build grid of days (most recent on the right)
    final allDays = List.generate(days, (i) {
      final date = now.subtract(Duration(days: days - 1 - i));
      return DateTime(date.year, date.month, date.day);
    });

    // Group by week columns
    final List<List<DateTime>> columns = [];
    for (int i = 0; i < allDays.length; i += 7) {
      columns.add(allDays.sublist(i, (i + 7).clamp(0, allDays.length)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels
        Row(
          children: [
            const SizedBox(width: 28),
            ...['M', 'W', 'F'].map((d) {
              return Expanded(
                flex: 1,
                child: Text(
                  d,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week day labels on left
            Column(
              children: ['', 'Mon', '', 'Wed', '', 'Fri', ''].map((d) {
                return SizedBox(
                  height: 13,
                  width: 24,
                  child: Text(
                    d,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columns.map((week) {
                  return Expanded(
                    child: Column(
                      children: week.map((date) {
                        final seconds = data[date] ?? 0;
                        return _HeatCell(
                          date: date,
                          seconds: seconds,
                          targetSeconds: targetSeconds,
                          color: activeColor,
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Less',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
            const SizedBox(width: 4),
            ...List.generate(5, (i) {
              final opacity = i == 0 ? 0.1 : (i / 4) * 0.9 + 0.1;
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: i == 0
                      ? AppColors.surfaceVariant
                      : activeColor.withOpacity(opacity),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
            const SizedBox(width: 4),
            const Text(
              'More',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  final DateTime date;
  final int seconds;
  final int targetSeconds;
  final Color color;

  const _HeatCell({
    required this.date,
    required this.seconds,
    required this.targetSeconds,
    required this.color,
  });

  double get _intensity {
    if (seconds <= 0) return 0;
    if (targetSeconds <= 0) return 0.5;
    return (seconds / targetSeconds).clamp(0.1, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isToday = FormatUtils.isToday(date);
    final isFuture = date.isAfter(DateTime.now());

    return Tooltip(
      message: isFuture
          ? ''
          : '${FormatUtils.formatDate(date)}\n${FormatUtils.formatDurationCompact(seconds)}',
      child: Container(
        width: double.infinity,
        height: 11,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isFuture
              ? Colors.transparent
              : seconds <= 0
                  ? AppColors.surfaceVariant
                  : color.withOpacity(_intensity),
          borderRadius: BorderRadius.circular(2),
          border: isToday
              ? Border.all(color: color.withOpacity(0.6), width: 1)
              : null,
        ),
      ),
    );
  }
}
