import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subject_model.dart';
import 'core_providers.dart';

class SubjectsNotifier extends AsyncNotifier<List<SubjectModel>> {
  @override
  Future<List<SubjectModel>> build() async {
    return ref.read(subjectRepositoryProvider).getAllSubjects();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(subjectRepositoryProvider).getAllSubjects(),
    );
  }

  Future<void> addSubject(SubjectModel subject) async {
    await ref.read(subjectRepositoryProvider).insertSubject(subject);
    await refresh();
  }

  Future<void> updateSubject(SubjectModel subject) async {
    await ref.read(subjectRepositoryProvider).updateSubject(subject);
    await refresh();
  }

  Future<void> deleteSubject(String id) async {
    await ref.read(subjectRepositoryProvider).deleteSubject(id);
    await refresh();
  }

  List<SubjectModel> get subjects => state.valueOrNull ?? [];
}

final subjectsProvider =
    AsyncNotifierProvider<SubjectsNotifier, List<SubjectModel>>(
  SubjectsNotifier.new,
);

final subjectByIdProvider =
    Provider.family<SubjectModel?, String>((ref, id) {
  final subjects = ref.watch(subjectsProvider).valueOrNull ?? [];
  try {
    return subjects.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});
