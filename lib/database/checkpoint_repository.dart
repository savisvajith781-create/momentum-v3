import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';
import '../models/checkpoint_model.dart';
import 'database_helper.dart';

class CheckpointRepository {
  final DatabaseHelper _db;

  CheckpointRepository(this._db);

  Future<List<CheckpointModel>> getAllCheckpoints() async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableCheckpoints,
      orderBy: 'target_date ASC',
    );
    return maps.map((m) => CheckpointModel.fromMap(m)).toList();
  }

  Future<CheckpointModel?> getCheckpointById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableCheckpoints,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CheckpointModel.fromMap(maps.first);
  }

  Future<void> insertCheckpoint(CheckpointModel checkpoint) async {
    final db = await _db.database;
    await db.insert(
      AppConstants.tableCheckpoints,
      checkpoint.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCheckpoint(CheckpointModel checkpoint) async {
    final db = await _db.database;
    await db.update(
      AppConstants.tableCheckpoints,
      checkpoint.toMap(),
      where: 'id = ?',
      whereArgs: [checkpoint.id],
    );
  }

  Future<void> deleteCheckpoint(String id) async {
    final db = await _db.database;
    await db.delete(
      AppConstants.tableCheckpoints,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateProgress(String id, int progress, CheckpointStatus status) async {
    final db = await _db.database;
    await db.update(
      AppConstants.tableCheckpoints,
      {
        'progress_percent': progress,
        'status': status.index,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
