import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';
import '../providers/subjects_provider.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';

class SubjectBreakdownWidget extends ConsumerWidget {
  const SubjectBreakdownWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(todaySubjectBreakdownProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    // Ignore noise entries under 60 seconds (e.g. an accidental
    // start/stop tap) so they don't clutter the breakdown with
    // confusing near-zero percentages.
    final meaningfulEntries = Map<String, int>.fromEntries(
      breakdown.entries.where((e) => e.value >= 60),
    );

    if (meaningfulEntries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No sessions yet today',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      );
    }

    final subjects = subjectsAsync.valueOrNull ?? [];
    final total = meaningfulEntries.values.fold<int>(0, (a, b) => a + b);
    final entries = meaningfulEntries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((entry) {
        if (subjects.isEmpty) return const SizedBox.shrink();
        final matchList =
            subjects.where((s) => s.id == entry.key).toList();
        final subject = matchList.isNotEmpty ? matchList.first : subjects.first;
        final color = matchList.isNotEmpty ? matchList.first.color : AppColors.primary;

        final fraction = total > 0 ? entry.value / total : 0.0;

        return Padding(
          key: ValueKey(entry.key),
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    subject.icon,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subject.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    FormatUtils.formatDurationCompact(entry.value),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(fraction * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              _SmoothBar(fraction: fraction, color: color),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// A progress bar that smoothly glides to its new width whenever [fraction]
/// changes, using Flutter's implicit animation (no manual AnimationController
/// to accidentally reset). This stays visually calm even when [fraction]
/// updates every second from a running timer.
class _SmoothBar extends StatelessWidget {
  final double fraction;
  final Color color;

  const _SmoothBar({required this.fraction, required this.color});

  @override
  Widget build(BuildContext context) {
    final clamped = fraction.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (_, constraints) => Container(
        height: 4,
        width: constraints.maxWidth,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            width: constraints.maxWidth * clamped,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
