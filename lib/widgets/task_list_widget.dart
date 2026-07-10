import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_provider.dart';
import '../providers/subjects_provider.dart';
import '../models/task_model.dart';
import '../theme/app_colors.dart';
import '../utils/format_utils.dart';
import 'surface_card.dart';

class TaskListWidget extends ConsumerStatefulWidget {
  final bool showCompleted;
  final int? maxItems;

  const TaskListWidget({
    super.key,
    this.showCompleted = false,
    this.maxItems,
  });

  @override
  ConsumerState<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends ConsumerState<TaskListWidget> {
  final _controller = TextEditingController();
  String? _selectedSubjectId;
  bool _showInput = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _controller.text.trim();
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
        );

    _controller.clear();
    setState(() {
      _showInput = false;
      _selectedSubjectId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(todayTasksProvider);
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? [];

    final filtered = tasks.where((t) {
      if (!widget.showCompleted && t.isCompleted) return false;
      return true;
    }).toList();

    final displayed = widget.maxItems != null
        ? filtered.take(widget.maxItems!).toList()
        : filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayed.map((task) => _TaskItem(task: task)),
        if (displayed.isEmpty && !_showInput)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No tasks — add one below',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
        if (_showInput) ...[
          const SizedBox(height: 8),
          SurfaceCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Task title...',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _addTask(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          color: AppColors.green, size: 20),
                      onPressed: _addTask,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textMuted, size: 18),
                      onPressed: () =>
                          setState(() => _showInput = false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (subjects.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: subjects.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final s = subjects[i];
                        final selected = _selectedSubjectId == s.id;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedSubjectId =
                                selected ? null : s.id;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? s.color.withOpacity(0.2)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? s.color.withOpacity(0.5)
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              '${s.icon} ${s.name}',
                              style: TextStyle(
                                color: selected
                                    ? s.color
                                    : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() {
            _showInput = !_showInput;
            if (!_showInput) _controller.clear();
          }),
          icon: Icon(
            _showInput
                ? Icons.remove_rounded
                : Icons.add_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          label: Text(
            _showInput ? 'Cancel' : 'Add Task',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

class _TaskItem extends ConsumerWidget {
  final TaskModel task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: task.isCompleted,
              onChanged: (_) =>
                  ref.read(tasksProvider.notifier).toggleTask(task.id),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
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
                    fontSize: 13,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
                if (task.subjectName != null || task.dueDate != null)
                  Row(
                    children: [
                      if (task.subjectName != null)
                        Text(
                          task.subjectName!,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      if (task.subjectName != null && task.dueDate != null)
                        const Text(' · ',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                      if (task.dueDate != null)
                        Text(
                          FormatUtils.relativeDate(task.dueDate!),
                          style: TextStyle(
                            color: task.isOverdue
                                ? AppColors.red
                                : AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 15, color: AppColors.textMuted),
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
