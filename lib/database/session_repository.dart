import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';
import '../models/session_model.dart';
import '../models/stats_model.dart';
import 'database_helper.dart';

class SessionRepository {
  final DatabaseHelper _db;

  SessionRepository(this._db);

  Future<List<SessionModel>> getAllSessions() async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableSessions,
      orderBy: 'start_time DESC',
    );
    return maps.map((m) => SessionModel.fromMap(m)).toList();
  }

  Future<List<SessionModel>> getSessionsByDate(DateTime date) async {
    final db = await _db.database;
    final start = DateTime(date.year, date.month, date.day)
        .millisecondsSinceEpoch;
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59)
        .millisecondsSinceEpoch;

    final maps = await db.query(
      AppConstants.tableSessions,
      where: 'start_time >= ? AND start_time <= ?',
      whereArgs: [start, end],
      orderBy: 'start_time ASC',
    );
    return maps.map((m) => SessionModel.fromMap(m)).toList();
  }

  Future<List<SessionModel>> getSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db.database;
    final startMs = DateTime(start.year, start.month, start.day)
        .millisecondsSinceEpoch;
    final endMs = DateTime(end.year, end.month, end.day, 23, 59, 59)
        .millisecondsSinceEpoch;

    final maps = await db.query(
      AppConstants.tableSessions,
      where: 'start_time >= ? AND start_time <= ?',
      whereArgs: [startMs, endMs],
      orderBy: 'start_time DESC',
    );
    return maps.map((m) => SessionModel.fromMap(m)).toList();
  }

  Future<List<SessionModel>> getSessionsBySubject(String subjectId) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableSessions,
      where: 'subject_id = ?',
      whereArgs: [subjectId],
      orderBy: 'start_time DESC',
    );
    return maps.map((m) => SessionModel.fromMap(m)).toList();
  }

  Future<void> insertSession(SessionModel session) async {
    final db = await _db.database;
    await db.insert(
      AppConstants.tableSessions,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSession(SessionModel session) async {
    final db = await _db.database;
    await db.update(
      AppConstants.tableSessions,
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> deleteSession(String id) async {
    final db = await _db.database;
    await db.delete(
      AppConstants.tableSessions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTodayTotalSeconds() async {
    final now = DateTime.now();
    final sessions = await getSessionsByDate(now);
    return sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
  }

  Future<Map<String, int>> getTodaySubjectBreakdown() async {
    final now = DateTime.now();
    final sessions = await getSessionsByDate(now);
    final Map<String, int> breakdown = {};
    for (final s in sessions) {
      breakdown[s.subjectId] = (breakdown[s.subjectId] ?? 0) + s.durationSeconds;
    }
    return breakdown;
  }

  Future<List<DailyStats>> getDailyStats(DateTime start, DateTime end) async {
    final sessions = await getSessionsByDateRange(start, end);
    final Map<String, List<SessionModel>> byDate = {};

    for (final s in sessions) {
      final dateKey =
          '${s.startTime.year}-${s.startTime.month.toString().padLeft(2, '0')}-${s.startTime.day.toString().padLeft(2, '0')}';
      byDate[dateKey] = [...(byDate[dateKey] ?? []), s];
    }

    final List<DailyStats> stats = [];
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      final dateKey =
          '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      final daySessions = byDate[dateKey] ?? [];
      final subjectSeconds = <String, int>{};
      int total = 0;

      for (final s in daySessions) {
        subjectSeconds[s.subjectId] =
            (subjectSeconds[s.subjectId] ?? 0) + s.durationSeconds;
        total += s.durationSeconds;
      }

      stats.add(DailyStats(
        date: current,
        totalSeconds: total,
        subjectSeconds: subjectSeconds,
        sessionCount: daySessions.length,
      ));

      current = current.add(const Duration(days: 1));
    }

    return stats;
  }

  Future<Map<DateTime, int>> getHeatmapData(int months) async {
    final end = DateTime.now();
    final start = DateTime(end.year, end.month - months, 1);
    final sessions = await getSessionsByDateRange(start, end);

    final Map<DateTime, int> heatmap = {};
    for (final s in sessions) {
      final date = DateTime(
        s.startTime.year,
        s.startTime.month,
        s.startTime.day,
      );
      heatmap[date] = (heatmap[date] ?? 0) + s.durationSeconds;
    }
    return heatmap;
  }

  Future<List<SubjectStats>> getSubjectStats(DateTime start, DateTime end) async {
    final db = await _db.database;
    final startMs = DateTime(start.year, start.month, start.day)
        .millisecondsSinceEpoch;
    final endMs = DateTime(end.year, end.month, end.day, 23, 59, 59)
        .millisecondsSinceEpoch;
    const defaultColor = 0xFF4F8CFF;

    final result = await db.rawQuery('''
      SELECT 
        s.subject_id,
        s.subject_name,
        SUM(s.duration_seconds) as total_seconds,
        COUNT(*) as session_count,
        COALESCE(sub.color_value, ?) as color_value
      FROM ${AppConstants.tableSessions} s
      LEFT JOIN ${AppConstants.tableSubjects} sub ON s.subject_id = sub.id
      WHERE s.start_time >= ? AND s.start_time <= ?
      GROUP BY s.subject_id
      ORDER BY total_seconds DESC
    ''', [defaultColor, startMs, endMs]);

    return result
        .map((m) => SubjectStats(
              subjectId: m['subject_id'] as String,
              subjectName: m['subject_name'] as String,
              totalSeconds: (m['total_seconds'] as int?) ?? 0,
              sessionCount: (m['session_count'] as int?) ?? 0,
              colorValue: (m['color_value'] as int?) ?? defaultColor,
            ))
        .toList();
  }

  Future<int> getCurrentStreak(int dailyTargetSeconds) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT 
        date(start_time / 1000, 'unixepoch') as day,
        SUM(duration_seconds) as total
      FROM ${AppConstants.tableSessions}
      GROUP BY day
      ORDER BY day DESC
    ''');

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (final row in result) {
      final dayStr = row['day'] as String;
      final total = (row['total'] as int?) ?? 0;
      final dayDate = DateTime.parse(dayStr);
      final diff = DateTime(checkDate.year, checkDate.month, checkDate.day)
          .difference(DateTime(dayDate.year, dayDate.month, dayDate.day))
          .inDays;

      if (diff > 1) break;
      if (total >= dailyTargetSeconds) {
        streak++;
        checkDate = dayDate;
      } else if (diff == 0) {
        checkDate = dayDate;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<List<SessionModel>> getAllSessionsForExport() async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableSessions,
      orderBy: 'start_time ASC',
    );
    return maps.map((m) => SessionModel.fromMap(m)).toList();
  }
}
