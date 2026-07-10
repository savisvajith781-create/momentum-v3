import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';
import '../models/task_model.dart';
import 'database_helper.dart';

class TaskRepository {
  final DatabaseHelper _db;

  TaskRepository(this._db);

  Future<List<TaskModel>> getAllTasks() async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableTasks,
      orderBy: 'is_completed ASC, created_at DESC',
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getTodayTasks() async {
    final db = await _db.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

    final maps = await db.query(
      AppConstants.tableTasks,
      where: '''
        is_completed = 0 
        OR (is_completed = 1 AND completed_at >= ?)
        OR (due_date IS NOT NULL AND due_date >= ? AND due_date <= ?)
      ''',
      whereArgs: [startOfDay, startOfDay, endOfDay],
      orderBy: 'is_completed ASC, due_date ASC, created_at DESC',
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<List<TaskModel>> getIncompleteTasks() async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableTasks,
      where: 'is_completed = 0',
      orderBy: 'due_date ASC, created_at DESC',
    );
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<void> insertTask(TaskModel task) async {
    final db = await _db.database;
    await db.insert(
      AppConstants.tableTasks,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await _db.database;
    await db.update(
      AppConstants.tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await _db.database;
    await db.delete(
      AppConstants.tableTasks,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleTask(String id, bool completed) async {
    final db = await _db.database;
    await db.update(
      AppConstants.tableTasks,
      {
        'is_completed': completed ? 1 : 0,
        'completed_at': completed ? DateTime.now().millisecondsSinceEpoch : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TaskModel>> getAllTasksForExport() async {
    return getAllTasks();
  }
}
