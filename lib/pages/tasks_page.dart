import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_provider.dart';
import '../providers/subjects_provider.dart';
import '../models/task_model.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import '../widgets/surface_card.dart';
import '../widgets/page_transition.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  String _filter = 'all'; // all, pending, completed
  String? _subjectFilter;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? [];

    return FadeSlideIn(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TasksHeader(onAddTask: () => _showAddTaskDialog(context)),
            const SizedBox(height: 20),
            Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  selected: _filter == 'pending',
                  onTap: () => setState(() => _filter = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  selected: _filter == 'completed',
                  onTap: () => setState(() => _filter = 'completed'),
                ),
                const Spacer(),
                if (subjects.isNotEmpty)
                  _SubjectFilter(
                    subjects: subjects,
                    selected: _subjectFilter,
                    onChanged: (v) => setState(() => _subjectFilter = v),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            tasksAsync.when(
              data: (tasks) {
                var filtered = tasks.where((t) {
                  if (_filter == 'pending' && t.isCompleted) return false;
                  if (_filter == 'completed' && !t.isCompleted) return false;
                  if (_subjectFilter != null &&
                      t.subjectId != _subjectFilter) return false;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyTasksState(filter: _filter);
                }

                // Group by status
                final pending = filtered.where((t) => !t.isCompleted).toList();
                final completed = filtered.where((t) => t.isCompleted).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pending.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Pending',
                        count: pending.length,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      ...pending.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TaskCard(task: t),
                          )),
                    ],
                    if (completed.isNotEmpty && _filter != 'pending') ...[
                      const SizedBox(height: 16),
                      _SectionHeader(
                        title: 'Completed',
                        count: completed.length,
                        color: AppColors.green,
                      ),
                      const SizedBox(height: 10),
                      ...completed.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TaskCard(task: t),
                          )),
                    ],
                  ],
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
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _AddTaskDialog(),
    );
  }
}

class _TasksHeader extends StatelessWidget {
  final VoidCallback onAddTask;
  const _TasksHeader({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Track your study tasks',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onAddTask,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Task'),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textMuted,
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SubjectFilter extends StatelessWidget {
  final List<dynamic> subjects;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _SubjectFilter({
    required this.subjects,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButton<String?>(
          value: selected,
          hint: const Text(
            'All Subjects',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          dropdownColor: AppColors.surfaceVariant,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          icon: const Icon(Icons.expand_more_rounded,
              color: AppColors.textMuted, size: 18),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Subjects'),
            ),
            ...subjects.map((s) => DropdownMenuItem<String?>(
                  value: (s as dynamic).id as String,
                  child: Text((s as dynamic).name as String),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
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

class _TaskCard extends ConsumerWidget {
  final TaskModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: task.isCompleted,
              onChanged: (_) =>
                  ref.read(tasksProvider.notifier).toggleTask(task.id),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.isCompleted
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
                if (task.subjectName != null || task.dueDate != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (task.subjectName != null)
                        _Badge(
                          text: task.subjectName!,
                          color: AppColors.primary,
                        ),
                      if (task.subjectName != null && task.dueDate != null)
                        const SizedBox(width: 6),
                      if (task.dueDate != null)
                        _Badge(
                          text: FormatUtils.relativeDate(task.dueDate!),
                          color: task.isOverdue
                              ? AppColors.red
                              : AppColors.textMuted,
                          icon: Icons.calendar_today_rounded,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 16, color: AppColors.textMuted),
            onPressed: () =>
                ref.read(tasksProvider.notifier).deleteTask(task.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _Badge({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: color.withOpacity(0.8)),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksState extends StatelessWidget {
  final String filter;
  const _EmptyTasksState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Text('✅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              filter == 'completed'
                  ? 'No completed tasks'
                  : 'No tasks yet',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add a task using the button above',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTaskDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<_AddTaskDialog> {
  final _titleCtrl = TextEditingController();
  String? _selectedSubjectId;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (date != null) setState(() => _dueDate = date);
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

    ref.read(tasksProvider.notifier).addTask(
          title: title,
          subjectId: subject?.id,
          subjectName: subject?.name,
          dueDate: _dueDate,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? [];

    return AlertDialog(
      title: const Text('New Task'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleCtrl,
              autofocus: true,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Task title',
                hintText: 'e.g. Complete Chapter 5 questions',
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            if (subjects.isNotEmpty)
              DropdownButtonFormField<String?>(
                value: _selectedSubjectId,
                decoration: const InputDecoration(labelText: 'Subject'),
                dropdownColor: AppColors.surfaceVariant,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No subject'),
                  ),
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
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    Text(
                      _dueDate != null
                          ? FormatUtils.formatDate(_dueDate!)
                          : 'No due date',
                      style: TextStyle(
                        color: _dueDate != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () =>
                            setState(() => _dueDate = null),
                        child: const Icon(Icons.close_rounded,
                            size: 14, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}
