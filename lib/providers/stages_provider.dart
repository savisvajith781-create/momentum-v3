import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
import 'core_providers.dart';

class StagesNotifier extends StateNotifier<List<String>> {
  final SettingsService _service;

  StagesNotifier(this._service) : super(_service.studyStages);

  Future<void> addStage(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || state.contains(trimmed)) return;
    final updated = [...state, trimmed];
    state = updated;
    await _service.setStudyStages(updated);
  }

  Future<void> renameStage(String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final updated = state.map((s) => s == oldName ? trimmed : s).toList();
    state = updated;
    await _service.setStudyStages(updated);
  }

  Future<void> deleteStage(String name) async {
    if (state.length <= 1) return; // always keep at least one stage
    final updated = state.where((s) => s != name).toList();
    state = updated;
    await _service.setStudyStages(updated);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final updated = [...state];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = updated;
    await _service.setStudyStages(updated);
  }
}

final stagesProvider = StateNotifierProvider<StagesNotifier, List<String>>((ref) {
  return StagesNotifier(ref.read(settingsServiceProvider));
});
