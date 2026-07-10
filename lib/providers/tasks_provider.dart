import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import 'core_providers.dart';

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<TaskModel>> build() async {
    return ref.read(taskRepositoryProvider).getAllTasks();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(taskRepositoryProvider).getAllTasks(),
    );
  }

  Future<void> addTask({
    required String title,
    String? subjectId,
    String? subjectName,
    DateTime? dueDate,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      subjectId: subjectId,
      subjectName: subjectName,
      dueDate: dueDate,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    await ref.read(taskRepositoryProvider).insertTask(task);
    await refresh();
  }

  Future<void> toggleTask(String id) async {
    final tasks = state.valueOrNull ?? [];
    final task = tasks.firstWhere((t) => t.id == id);
    final newCompleted = !task.isCompleted;
    await ref.read(taskRepositoryProvider).toggleTask(id, newCompleted);
    await refresh();
  }

  Future<void> updateTask(TaskModel task) async {
    await ref.read(taskRepositoryProvider).updateTask(task);
    await refresh();
  }

  Future<void> deleteTask(String id) async {
    await ref.read(taskRepositoryProvider).deleteTask(id);
    await refresh();
  }

  List<TaskModel> get pendingTasks {
    return (state.valueOrNull ?? [])
        .where((t) => !t.isCompleted)
        .toList();
  }

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tasks = state.valueOrNull ?? [];
    return tasks.where((t) {
      if (!t.isCompleted) return true;
      if (t.completedAt != null) {
        return DateTime(
          t.completedAt!.year,
          t.completedAt!.month,
          t.completedAt!.day,
        ).isAtSameMomentAs(today);
      }
      return false;
    }).toList();
  }
}

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

final todayTasksProvider = Provider<List<TaskModel>>((ref) {
  final allTasks = ref.watch(tasksProvider).valueOrNull ?? [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return allTasks.where((t) {
    if (!t.isCompleted) return true;
    if (t.completedAt != null) {
      return DateTime(
        t.completedAt!.year,
        t.completedAt!.month,
        t.completedAt!.day,
      ).isAtSameMomentAs(today);
    }
    return false;
  }).toList();
});
