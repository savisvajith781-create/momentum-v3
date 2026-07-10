import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    final databaseFactory = databaseFactoryFfi;

    final appDir = Platform.environment['LOCALAPPDATA'] ?? '.';
    final dbDir = join(appDir, 'Momentum');
    await Directory(dbDir).create(recursive: true);

    final dbPath = join(dbDir, 'momentum.db');

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSubjects} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        icon TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableSessions} (
        id TEXT PRIMARY KEY,
        subject_id TEXT NOT NULL,
        subject_name TEXT NOT NULL,
        chapter TEXT NOT NULL,
        revision_stage TEXT NOT NULL,
        notes TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (subject_id) REFERENCES ${AppConstants.tableSubjects}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableTasks} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subject_id TEXT,
        subject_name TEXT,
        due_date INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        completed_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableCheckpoints} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subject_id TEXT,
        subject_name TEXT,
        target_date INTEGER NOT NULL,
        progress_percent INTEGER NOT NULL DEFAULT 0,
        status INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableSettings} (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_sessions_start_time ON ${AppConstants.tableSessions}(start_time)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_subject_id ON ${AppConstants.tableSessions}(subject_id)',
    );
    await db.execute(
      'CREATE INDEX idx_tasks_created ON ${AppConstants.tableTasks}(created_at)',
    );

    // Insert default subjects
    await _insertDefaultSubjects(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here
  }

  Future<void> _insertDefaultSubjects(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final defaults = [
      {
        'id': 'subj_afm',
        'name': 'AFM',
        'color_value': 0xFF4F8CFF,
        'icon': '📊',
        'is_default': 1,
        'sort_order': 0,
        'created_at': now,
      },
      {
        'id': 'subj_fr',
        'name': 'FR',
        'color_value': 0xFF42D392,
        'icon': '📖',
        'is_default': 1,
        'sort_order': 1,
        'created_at': now,
      },
      {
        'id': 'subj_audit',
        'name': 'Audit',
        'color_value': 0xFFFFB84D,
        'icon': '🔍',
        'is_default': 1,
        'sort_order': 2,
        'created_at': now,
      },
      {
        'id': 'subj_gym',
        'name': 'Gym',
        'color_value': 0xFFFF6B6B,
        'icon': '💪',
        'is_default': 1,
        'sort_order': 3,
        'created_at': now,
      },
      {
        'id': 'subj_break',
        'name': 'Break',
        'color_value': 0xFF9B8FFF,
        'icon': '☕',
        'is_default': 1,
        'sort_order': 4,
        'created_at': now,
      },
    ];

    final batch = db.batch();
    for (final subject in defaults) {
      batch.insert(AppConstants.tableSubjects, subject);
    }
    await batch.commit();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final db = await database;
    final path = db.path;
    await db.close();
    _database = null;
    await File(path).delete();
  }
}
