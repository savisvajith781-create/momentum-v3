import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/checkpoint_model.dart';
import 'core_providers.dart';

class CheckpointsNotifier extends AsyncNotifier<List<CheckpointModel>> {
  final Uuid _uuid = const Uuid();

  @override
  Future<List<CheckpointModel>> build() async {
    return ref.read(checkpointRepositoryProvider).getAllCheckpoints();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(checkpointRepositoryProvider).getAllCheckpoints(),
    );
  }

  Future<void> addCheckpoint({
    required String title,
    String? subjectId,
    String? subjectName,
    required DateTime targetDate,
    int progressPercent = 0,
    CheckpointStatus status = CheckpointStatus.yellow,
    String? notes,
  }) async {
    final checkpoint = CheckpointModel(
      id: _uuid.v4(),
      title: title,
      subjectId: subjectId,
      subjectName: subjectName,
      targetDate: targetDate,
      progressPercent: progressPercent,
      status: status,
      notes: notes,
      createdAt: DateTime.now(),
    );
    await ref.read(checkpointRepositoryProvider).insertCheckpoint(checkpoint);
    await refresh();
  }

  Future<void> updateCheckpoint(CheckpointModel checkpoint) async {
    await ref.read(checkpointRepositoryProvider).updateCheckpoint(checkpoint);
    await refresh();
  }

  Future<void> deleteCheckpoint(String id) async {
    await ref.read(checkpointRepositoryProvider).deleteCheckpoint(id);
    await refresh();
  }

  Future<void> updateProgress(
    String id,
    int progress,
    CheckpointStatus status,
  ) async {
    await ref
        .read(checkpointRepositoryProvider)
        .updateProgress(id, progress, status);
    await refresh();
  }
}

final checkpointsProvider =
    AsyncNotifierProvider<CheckpointsNotifier, List<CheckpointModel>>(
  CheckpointsNotifier.new,
);
