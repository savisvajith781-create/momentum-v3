import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sessions_provider.dart';
import '../providers/subjects_provider.dart';
import '../providers/stages_provider.dart';
import '../models/session_model.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import '../widgets/surface_card.dart';
import '../widgets/page_transition.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedHistoryDateProvider);

    return FadeSlideIn(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar panel
          SizedBox(
            width: 300,
            child: _CalendarPanel(selectedDate: selectedDate),
          ),
          const SizedBox(width: 20),
          // Sessions panel
          Expanded(
            child: _SessionsPanel(date: selectedDate),
          ),
        ],
      ),
    );
  }
}

class _CalendarPanel extends ConsumerWidget {
  final DateTime selectedDate;
  const _CalendarPanel({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Browse past sessions',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            child: _CustomCalendar(
              selectedDate: selectedDate,
              onDateSelected: (d) {
                ref.read(selectedHistoryDateProvider.notifier).state = d;
              },
            ),
          ),
          const SizedBox(height: 16),
          _DaysSummary(selectedDate: selectedDate),
        ],
      ),
    );
  }
}

class _CustomCalendar extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CustomCalendar({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  ConsumerState<_CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends ConsumerState<_CustomCalendar> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sun=0

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: AppColors.textSecondary),
                onPressed: _prevMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(_displayMonth),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
                onPressed: _nextMonth,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day headers
          Row(
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map((d) => Expanded(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox.shrink();
              final day = index - startWeekday + 1;
              final date = DateTime(_displayMonth.year, _displayMonth.month, day);
              final isSelected = FormatUtils.isSameDay(date, widget.selectedDate);
              final isToday = FormatUtils.isToday(date);
              final isFuture = date.isAfter(DateTime.now());

              return GestureDetector(
                onTap: isFuture ? null : () => widget.onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary.withOpacity(0.12)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isFuture
                                ? AppColors.textDisabled
                                : isToday
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DaysSummary extends ConsumerWidget {
  final DateTime selectedDate;
  const _DaysSummary({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsByDateProvider(selectedDate));

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();
        final total = sessions.fold<int>(0, (s, e) => s + e.durationSeconds);
        return SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                label: 'Sessions',
                value: '${sessions.length}',
                color: AppColors.primary,
              ),
              Container(
                  width: 1, height: 32, color: AppColors.border),
              _SummaryItem(
                label: 'Total',
                value: FormatUtils.formatDurationCompact(total),
                color: AppColors.green,
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

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _SessionsPanel extends ConsumerWidget {
  final DateTime date;
  const _SessionsPanel({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsByDateProvider(date));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 28, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            FormatUtils.isToday(date)
                ? 'Today'
                : FormatUtils.isYesterday(date)
                    ? 'Yesterday'
                    : DateFormat('EEEE, MMMM d').format(date),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 20),
          sessionsAsync.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return _EmptyState(date: date);
              }
              return Column(
                children: sessions
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SessionCard(session: s),
                        ))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final DateTime date;
  const _EmptyState({required this.date});

  @override
  Widget build(BuildContext context) {
    final isFuture = date.isAfter(DateTime.now());
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Text(
              isFuture ? '🔮' : '📭',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              isFuture ? 'Future date' : 'No sessions this day',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isFuture
                  ? 'Select a past date to view sessions'
                  : 'Start a timer to record a session',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends ConsumerStatefulWidget {
  final SessionModel session;
  const _SessionCard({required this.session});

  @override
  ConsumerState<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends ConsumerState<_SessionCard> {
  bool _editing = false;
  late TextEditingController _chapterCtrl;
  late TextEditingController _notesCtrl;
  late String _revisionStage;

  @override
  void initState() {
    super.initState();
    _chapterCtrl = TextEditingController(text: widget.session.chapter);
    _notesCtrl = TextEditingController(text: widget.session.notes ?? '');
    _revisionStage = widget.session.revisionStage;
  }

  @override
  void dispose() {
    _chapterCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveEdit() {
    ref.read(sessionsEditProvider.notifier).updateSession(
          widget.session.copyWith(
            chapter: _chapterCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
            revisionStage: _revisionStage,
          ),
        );
    setState(() => _editing = false);
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text(
            'Delete "${widget.session.chapter}" session? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(sessionsEditProvider.notifier)
                  .deleteSession(widget.session.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final subjects = subjectsAsync.valueOrNull ?? [];
    final subject = subjects.isNotEmpty
        ? subjects.firstWhere(
            (s) => s.id == widget.session.subjectId,
            orElse: () => subjects.first,
          )
        : null;

    final color = subject?.color ?? AppColors.primary;
    final icon = subject?.icon ?? '📚';

    return SurfaceCard(
      borderColor: _editing ? AppColors.primary.withOpacity(0.4) : null,
      child: Column(
        children: [
          // Header bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  widget.session.subjectName,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.session.revisionStage,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  FormatUtils.formatDurationCompact(
                      widget.session.durationSeconds),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: _editing
                ? _EditView(
                    chapterCtrl: _chapterCtrl,
                    notesCtrl: _notesCtrl,
                    revisionStage: _revisionStage,
                    onStageChanged: (v) =>
                        setState(() => _revisionStage = v),
                    onSave: _saveEdit,
                    onCancel: () => setState(() => _editing = false),
                  )
                : _ReadView(
                    session: widget.session,
                    onEdit: () => setState(() => _editing = true),
                    onDelete: _delete,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReadView extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReadView({
    required this.session,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.chapter,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${FormatUtils.formatTime(session.startTime)}'
                '${session.endTime != null ? ' – ${FormatUtils.formatTime(session.endTime!)}' : ''}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              if (session.notes != null && session.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  session.notes!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded,
                  size: 16, color: AppColors.textMuted),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.red),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ],
    );
  }
}

class _EditView extends ConsumerWidget {
  final TextEditingController chapterCtrl;
  final TextEditingController notesCtrl;
  final String revisionStage;
  final ValueChanged<String> onStageChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _EditView({
    required this.chapterCtrl,
    required this.notesCtrl,
    required this.revisionStage,
    required this.onStageChanged,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stages = ref.watch(stagesProvider);
    // Include the session's existing stage even if it's since been renamed
    // or removed from the custom list, so the dropdown never crashes on
    // older data.
    final dropdownOptions = stages.contains(revisionStage)
        ? stages
        : [revisionStage, ...stages];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: chapterCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Chapter / Topic',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 130,
              child: DropdownButtonFormField<String>(
                value: revisionStage,
                decoration: const InputDecoration(
                  labelText: 'Stage',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                dropdownColor: AppColors.surfaceVariant,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                items: dropdownOptions
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => onStageChanged(v ?? revisionStage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: notesCtrl,
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 14),
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: onSave, child: const Text('Save')),
          ],
        ),
      ],
    );
  }
}
