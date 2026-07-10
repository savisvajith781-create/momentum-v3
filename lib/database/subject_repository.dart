import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';
import '../models/subject_model.dart';
import 'database_helper.dart';

class SubjectRepository {
  final DatabaseHelper _db;

  SubjectRepository(this._db);

  Future<List<SubjectModel>> getAllSubjects() async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableSubjects,
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return maps.map((m) => SubjectModel.fromMap(m)).toList();
  }

  Future<SubjectModel?> getSubjectById(String id) async {
    final db = await _db.database;
    final maps = await db.query(
      AppConstants.tableSubjects,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return SubjectModel.fromMap(maps.first);
  }

  Future<void> insertSubject(SubjectModel subject) async {
    final db = await _db.database;
    await db.insert(
      AppConstants.tableSubjects,
      subject.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSubject(SubjectModel subject) async {
    final db = await _db.database;
    await db.update(
      AppConstants.tableSubjects,
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<void> deleteSubject(String id) async {
    final db = await _db.database;
    await db.delete(
      AppConstants.tableSubjects,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reorderSubjects(List<String> orderedIds) async {
    final db = await _db.database;
    final batch = db.batch();
    for (int i = 0; i < orderedIds.length; i++) {
      batch.update(
        AppConstants.tableSubjects,
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [orderedIds[i]],
      );
    }
    await batch.commit(noResult: true);
  }
}
