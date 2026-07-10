import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/checkpoints_provider.dart';
import '../providers/subjects_provider.dart';
import '../models/checkpoint_model.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import '../widgets/surface_card.dart';
import '../widgets/page_transition.dart';

class CheckpointsPage extends ConsumerWidget {
  const CheckpointsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkpointsAsync = ref.watch(checkpointsProvider);

    return FadeSlideIn(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CheckpointsHeader(
              onAdd: () => _showAddDialog(context, ref),
            ),
            const SizedBox(height: 24),
            checkpointsAsync.when(
              data: (checkpoints) {
                if (checkpoints.isEmpty) {
                  return _EmptyCheckpoints(
                    onAdd: () => _showAddDialog(context, ref),
                  );
                }

                final active = checkpoints
                    .where((c) => !c.isOverdue || c.progressPercent < 100)
                    .toList();
                final overdue = checkpoints
                    .where((c) => c.isOverdue && c.progressPercent < 100)
                    .toList();
                final done = checkpoints
                    .where((c) => c.progressPercent == 100)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (active.isNotEmpty) ...[
                      _SectionLabel(
                        title: 'Active',
                        count: active.length,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _CheckpointsGrid(checkpoints: active),
                    ],
                    if (overdue.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(
                        title: 'Overdue',
                        count: overdue.length,
                        color: AppColors.red,
                      ),
                      const SizedBox(height: 12),
                      _CheckpointsGrid(checkpoints: overdue),
                    ],
                    if (done.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _SectionLabel(
                        title: 'Completed',
                        count: done.length,
                        color: AppColors.green,
                      ),
                      const SizedBox(height: 12),
                      _CheckpointsGrid(checkpoints: done),
                    ],
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddCheckpointDialog(),
    );
  }
}

class _CheckpointsHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _CheckpointsHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkpoints',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Track milestones for your CA prep',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Checkpoint'),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionLabel({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckpointsGrid extends StatelessWidget {
  final List<CheckpointModel> checkpoints;

  const _CheckpointsGrid({required this.checkpoints});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 800 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.8,
          ),
          itemCount: checkpoints.length,
          itemBuilder: (_, i) => _CheckpointCard(checkpoint: checkpoints[i]),
        );
      },
    );
  }
}

class _CheckpointCard extends ConsumerWidget {
  final CheckpointModel checkpoint;
  const _CheckpointCard({required this.checkpoint});

  Color _statusColor() {
    switch (checkpoint.status) {
      case CheckpointStatus.green:
        return AppColors.green;
      case CheckpointStatus.yellow:
        return AppColors.orange;
      case CheckpointStatus.red:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColor();
    final isDone = checkpoint.progressPercent == 100;

    return SurfaceCard(
      borderColor: statusColor.withOpacity(0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditDialog(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      checkpoint.title,
                      style: TextStyle(
                        color: isDone
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _statusLabel(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (checkpoint.subjectName != null) ...[
                const SizedBox(height: 4),
                Text(
                  checkpoint.subjectName!,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(),
              // Progress bar
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${checkpoint.progressPercent}%',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _daysLabel(),
                        style: TextStyle(
                          color: checkpoint.isOverdue
                              ? AppColors.red
                              : AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: checkpoint.progressPercent / 100,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (checkpoint.status) {
      case CheckpointStatus.green:
        return 'ON TRACK';
      case CheckpointStatus.yellow:
        return 'AT RISK';
      case CheckpointStatus.red:
        return 'BEHIND';
    }
  }

  String _daysLabel() {
    if (checkpoint.isOverdue) {
      return '${checkpoint.daysRemaining.abs()}d overdue';
    }
    if (checkpoint.isDueToday) return 'Due today';
    return '${checkpoint.daysRemaining}d left';
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _EditCheckpointDialog(checkpoint: checkpoint),
    );
  }
}

class _EmptyCheckpoints extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyCheckpoints({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Text('🏁', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            const Text(
              'No checkpoints yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create milestones like "AFM R1", "FR R2" to\ntrack your CA Final prep progress',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create First Checkpoint'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCheckpointDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddCheckpointDialog> createState() =>
      _AddCheckpointDialogState();
}

class _AddCheckpointDialogState
    extends ConsumerState<_AddCheckpointDialog> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _selectedSubjectId;
  DateTime _targetDate =
      DateTime.now().add(const Duration(days: 30));
  int _progress = 0;
  CheckpointStatus _status = CheckpointStatus.yellow;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _targetDate = date);
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final subjects = ref.read(subjectsProvider).valueOrNull ?? [];
    final subject = _selectedSubjectId != null
        ? subjects.firstWhere(
            (s) => s.id == _selectedSubjectId,
            orElse: () => subjects.first,
          )
        : null;

    ref.read(checkpointsProvider.notifier).addCheckpoint(
          title: title,
          subjectId: subject?.id,
          subjectName: subject?.name,
          targetDate: _targetDate,
          progressPercent: _progress,
          status: _status,
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? [];

    return AlertDialog(
      title: const Text('New Checkpoint'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                autofocus: true,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Chapter 5, Midterm Prep',
                ),
              ),
              const SizedBox(height: 12),
              if (subjects.isNotEmpty)
                DropdownButtonFormField<String?>(
                  value: _selectedSubjectId,
                  decoration:
                      const InputDecoration(labelText: 'Subject (optional)'),
                  dropdownColor: AppColors.surfaceVariant,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('None')),
                    ...subjects.map((s) => DropdownMenuItem<String?>(
                          value: s.id,
                          child: Text('${s.icon} ${s.name}'),
                        )),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedSubjectId = v),
                ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 10),
                      Text(
                        'Target: ${FormatUtils.formatDate(_targetDate)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$_progress%',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _progress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (v) =>
                        setState(() => _progress = v.round()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ...CheckpointStatus.values.map((s) {
                    final selected = _status == s;
                    final color = s == CheckpointStatus.green
                        ? AppColors.green
                        : s == CheckpointStatus.yellow
                            ? AppColors.orange
                            : AppColors.red;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _status = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? color.withOpacity(0.5)
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            s == CheckpointStatus.green
                                ? '🟢'
                                : s == CheckpointStatus.yellow
                                    ? '🟡'
                                    : '🔴',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _EditCheckpointDialog extends ConsumerStatefulWidget {
  final CheckpointModel checkpoint;
  const _EditCheckpointDialog({required this.checkpoint});

  @override
  ConsumerState<_EditCheckpointDialog> createState() =>
      _EditCheckpointDialogState();
}

class _EditCheckpointDialogState
    extends ConsumerState<_EditCheckpointDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late String? _selectedSubjectId;
  late DateTime _targetDate;
  late int _progress;
  late CheckpointStatus _status;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.checkpoint.title);
    _notesCtrl =
        TextEditingController(text: widget.checkpoint.notes ?? '');
    _selectedSubjectId = widget.checkpoint.subjectId;
    _targetDate = widget.checkpoint.targetDate;
    _progress = widget.checkpoint.progressPercent;
    _status = widget.checkpoint.status;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _targetDate = date);
  }

  void _save() {
    final subjects = ref.read(subjectsProvider).valueOrNull ?? [];
    final subject = _selectedSubjectId != null
        ? subjects.firstWhere(
            (s) => s.id == _selectedSubjectId,
            orElse: () => subjects.first,
          )
        : null;

    ref.read(checkpointsProvider.notifier).updateCheckpoint(
          widget.checkpoint.copyWith(
            title: _titleCtrl.text.trim(),
            subjectId: subject?.id,
            subjectName: subject?.name,
            targetDate: _targetDate,
            progressPercent: _progress,
            status: _status,
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          ),
        );
    Navigator.pop(context);
  }

  void _delete() {
    Navigator.pop(context);
    ref
        .read(checkpointsProvider.notifier)
        .deleteCheckpoint(widget.checkpoint.id);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? [];

    return AlertDialog(
      title: Row(
        children: [
          const Text('Edit Checkpoint'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.red, size: 20),
            onPressed: _delete,
            tooltip: 'Delete',
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration:
                    const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              if (subjects.isNotEmpty)
                DropdownButtonFormField<String?>(
                  value: _selectedSubjectId,
                  decoration:
                      const InputDecoration(labelText: 'Subject'),
                  dropdownColor: AppColors.surfaceVariant,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('None')),
                    ...subjects.map((s) => DropdownMenuItem<String?>(
                          value: s.id,
                          child: Text('${s.icon} ${s.name}'),
                        )),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedSubjectId = v),
                ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 10),
                      Text(
                        FormatUtils.formatDate(_targetDate),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Progress',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13)),
                      const Spacer(),
                      Text('$_progress%',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Slider(
                    value: _progress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (v) =>
                        setState(() => _progress = v.round()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Status',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(width: 12),
                  ...CheckpointStatus.values.map((s) {
                    final selected = _status == s;
                    final color = s == CheckpointStatus.green
                        ? AppColors.green
                        : s == CheckpointStatus.yellow
                            ? AppColors.orange
                            : AppColors.red;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _status = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? color.withOpacity(0.5)
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            s == CheckpointStatus.green
                                ? '🟢'
                                : s == CheckpointStatus.yellow
                                    ? '🟡'
                                    : '🔴',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Notes (optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
