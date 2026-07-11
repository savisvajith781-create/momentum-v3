import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_model.dart';
import 'core_providers.dart';
import 'timer_provider.dart';
import 'stats_provider.dart';

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

final sessionsByDateRangeProvider = FutureProvider.family
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

  void _invalidateEverything() {
    _ref.invalidate(allSessionsProvider);
    _ref.invalidate(sessionsByDateProvider);
    _ref.invalidate(sessionsByDateRangeProvider);
    _ref.invalidate(todaySessionsProvider);
    _ref.invalidate(todayTotalSecondsProvider);
    _ref.invalidate(todaySubjectBreakdownProvider);
    _ref.invalidate(weeklyReportProvider);
    _ref.invalidate(heatmapDataProvider);
    _ref.invalidate(currentStreakProvider);
    _ref.invalidate(subjectStatsProvider);
    _ref.invalidate(dailyStatsRangeProvider);
  }

  Future<void> updateSession(SessionModel session) async {
    state = const AsyncLoading();
    try {
      await _ref.read(sessionRepositoryProvider).updateSession(session);
      _invalidateEverything();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSession(String id) async {
    state = const AsyncLoading();
    try {
      await _ref.read(sessionRepositoryProvider).deleteSession(id);
      _invalidateEverything();
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
