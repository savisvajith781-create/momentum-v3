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
    final breakdownAsync = ref.watch(todaySubjectBreakdownProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return breakdownAsync.when(
      data: (breakdown) {
        if (breakdown.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No sessions yet today',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          );
        }

        final subjects = subjectsAsync.valueOrNull ?? [];
        final total = breakdown.values.fold<int>(0, (a, b) => a + b);
        final entries = breakdown.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          children: entries.map((entry) {
            if (subjects.isEmpty) return const SizedBox.shrink();
            final subject = subjects.firstWhere(
              (s) => s.id == entry.key,
              orElse: () => subjects.first,
            );

            final fraction = total > 0 ? entry.value / total : 0.0;
            final matchList = subjects.where((s) => s.id == entry.key).toList();
            final color = matchList.isNotEmpty ? matchList.first.color : AppColors.primary;

            return Padding(
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
                  _AnimatedBar(fraction: fraction, color: color),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _AnimatedBar extends StatefulWidget {
  final double fraction;
  final Color color;

  const _AnimatedBar({required this.fraction, required this.color});

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = Tween<double>(begin: 0, end: widget.fraction).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedBar old) {
    super.didUpdateWidget(old);
    if (old.fraction != widget.fraction) {
      _anim = Tween<double>(begin: _anim.value, end: widget.fraction).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => LayoutBuilder(
        builder: (_, constraints) => Container(
          height: 4,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * _anim.value,
              height: 4,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
