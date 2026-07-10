import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';
import '../providers/subjects_provider.dart';
import '../providers/stages_provider.dart';
import '../models/timer_state.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import 'surface_card.dart';

class TimerWidget extends ConsumerWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);

    if (timer.isIdle) {
      return const _StartTimerCard();
    }

    return _ActiveTimerCard(timer: timer);
  }
}

class _StartTimerCard extends ConsumerStatefulWidget {
  const _StartTimerCard();

  @override
  ConsumerState<_StartTimerCard> createState() => _StartTimerCardState();
}

class _StartTimerCardState extends ConsumerState<_StartTimerCard> {
  String? _selectedSubjectId;
  String _chapter = '';
  String? _selectedStage;
  String? _notes;
  final _chapterController = TextEditingController();

  @override
  void dispose() {
    _chapterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final stages = ref.watch(stagesProvider);

    return subjectsAsync.when(
      data: (subjects) {
        if (subjects.isNotEmpty && _selectedSubjectId == null) {
          _selectedSubjectId = subjects.first.id;
        }
        if (stages.isNotEmpty &&
            (_selectedStage == null || !stages.contains(_selectedStage))) {
          _selectedStage = stages.first;
        }

        final selectedSubject = _selectedSubjectId != null
            ? subjects.firstWhere(
                (s) => s.id == _selectedSubjectId,
                orElse: () => subjects.first,
              )
            : null;

        return SurfaceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Start Session',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Subject selector
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  value: _selectedSubjectId,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  dropdownColor: AppColors.surfaceVariant,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  items: subjects
                      .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Row(
                              children: [
                                Text(s.icon, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(s.name),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSubjectId = v),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chapterController,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Chapter / Topic',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onChanged: (v) => _chapter = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 130,
                    child: DropdownButtonFormField<String>(
                      value: _selectedStage,
                      decoration: const InputDecoration(
                        labelText: 'Stage',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      dropdownColor: AppColors.surfaceVariant,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      items: stages
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedStage = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: subjects.isEmpty
                      ? null
                      : () {
                          if (selectedSubject == null) return;
                          final notifier = ref.read(timerProvider.notifier);
                          notifier.configure(
                            subject: selectedSubject,
                            chapter: _chapter.isEmpty
                                ? selectedSubject.name
                                : _chapter,
                            revisionStage: _selectedStage ??
                                (stages.isNotEmpty ? stages.first : 'Session'),
                            notes: _notes,
                          );
                          notifier.start();
                        },
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Start Timer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _ActiveTimerCard extends ConsumerWidget {
  final TimerState timer;

  const _ActiveTimerCard({required this.timer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = timer.subject;
    final color = subject?.color ?? AppColors.primary;

    return SurfaceCard(
      borderColor: color.withOpacity(0.3),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: timer.isRunning ? AppColors.green : AppColors.orange,
                    shape: BoxShape.circle,
                    boxShadow: timer.isRunning
                        ? [
                            BoxShadow(
                              color: AppColors.green.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timer.isRunning ? 'IN SESSION' : 'PAUSED',
                  style: TextStyle(
                    color: timer.isRunning ? AppColors.green : AppColors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                if (subject != null) ...[
                  Text(
                    subject.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    subject.name,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Timer display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Text(
                  FormatUtils.formatTimer(timer.elapsedSeconds),
                  style: TextStyle(
                    color: color,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timer.chapter.isNotEmpty ? timer.chapter : 'No chapter',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  timer.revisionStage,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Stop
                    _ControlButton(
                      icon: Icons.stop_rounded,
                      color: AppColors.red,
                      label: 'Stop',
                      onTap: () => ref.read(timerProvider.notifier).stop(),
                    ),
                    const SizedBox(width: 12),
                    // Play/Pause
                    if (timer.isRunning)
                      _ControlButton(
                        icon: Icons.pause_rounded,
                        color: AppColors.orange,
                        label: 'Pause',
                        isPrimary: true,
                        onTap: () => ref.read(timerProvider.notifier).pause(),
                      )
                    else
                      _ControlButton(
                        icon: Icons.play_arrow_rounded,
                        color: AppColors.green,
                        label: 'Resume',
                        isPrimary: true,
                        onTap: () => ref.read(timerProvider.notifier).resume(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPrimary ? 24 : 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: isPrimary ? 22 : 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
