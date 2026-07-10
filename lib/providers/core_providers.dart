import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../database/subject_repository.dart';
import '../database/session_repository.dart';
import '../database/task_repository.dart';
import '../database/checkpoint_repository.dart';
import '../services/settings_service.dart';
import '../services/quote_service.dart';
import '../services/export_service.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository(ref.read(databaseHelperProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.read(databaseHelperProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(databaseHelperProvider));
});

final checkpointRepositoryProvider = Provider<CheckpointRepository>((ref) {
  return CheckpointRepository(ref.read(databaseHelperProvider));
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final quoteServiceProvider = Provider<QuoteService>((ref) {
  return QuoteService();
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});
