import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_model.dart';
import 'core_providers.dart';

final selectedHistoryDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final sessionsByDateProvider =
    FutureProvider.family<List<SessionModel>, DateTime>((ref, date) async {
  return ref.read(sessionRepositoryProvider).getSessionsByDate(date);
});

final allSessionsProvider = FutureProvider<List<SessionModel>>((ref) async {
  return ref.read(sessionRepositoryProvider).getAllSessions();
});

final sessionsByDateRangeProvider = FutureProvider.family<
    List<SessionModel>,
    ({DateTime start, DateTime end})>((ref, range) async {
  return ref.read(sessionRepositoryProvider).getSessionsByDateRange(
        range.start,
        range.end,
      );
});

class SessionsEditNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  SessionsEditNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateSession(SessionModel session) async {
    state = const AsyncLoading();
    try {
      await _ref.read(sessionRepositoryProvider).updateSession(session);
      _ref.invalidate(allSessionsProvider);
      _ref.invalidate(sessionsByDateProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSession(String id) async {
    state = const AsyncLoading();
    try {
      await _ref.read(sessionRepositoryProvider).deleteSession(id);
      _ref.invalidate(allSessionsProvider);
      _ref.invalidate(sessionsByDateProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final sessionsEditProvider =
    StateNotifierProvider<SessionsEditNotifier, AsyncValue<void>>(
  (ref) => SessionsEditNotifier(ref),
);
