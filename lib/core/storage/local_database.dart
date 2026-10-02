import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/storage_keys.dart';

/// ================================================================
/// LOCAL DATABASE
///
/// SQLite database used for caching downloaded resources.
/// Developer B's download feature will interact with this.
/// Developer A owns this file.
/// ================================================================

class LocalDatabase {
  LocalDatabase._();

  static const String _dbName = 'aastu_freshman.db';
  static const int _dbVersion = 2;

  static Database? _db;

  // ── Initialise ─────────────────────────────────────────────────

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── Schema ─────────────────────────────────────────────────────

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${StorageKeys.cachedResourcesTable} (
        ${StorageKeys.colId}            INTEGER PRIMARY KEY AUTOINCREMENT,
        ${StorageKeys.colResourceId}    TEXT    NOT NULL UNIQUE,
        ${StorageKeys.colFilePath}      TEXT    NOT NULL,
        ${StorageKeys.colChecksum}      TEXT,
        ${StorageKeys.colUpdatedAt}     TEXT,
        ${StorageKeys.colCachedAt}      TEXT    NOT NULL,
        ${StorageKeys.colIsPremium}     INTEGER NOT NULL DEFAULT 0,
        ${StorageKeys.colTitle}         TEXT,
        ${StorageKeys.colCategory}      TEXT,
        ${StorageKeys.colCourseName}    TEXT,
        ${StorageKeys.colFileSizeBytes} INTEGER
      )
    ''');

    await _createCacheTables(db);
  }

  static Future<void> _createCacheTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageKeys.cachedStreamsTable} (
        ${StorageKeys.colId}       INTEGER PRIMARY KEY,
        ${StorageKeys.colTitle}    TEXT NOT NULL,
        ${StorageKeys.colSyncedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageKeys.cachedDepartmentsTable} (
        ${StorageKeys.colId}           INTEGER PRIMARY KEY,
        ${StorageKeys.colStreamId}     INTEGER NOT NULL,
        ${StorageKeys.colTitle}        TEXT NOT NULL,
        ${StorageKeys.colSyncedAt}     TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageKeys.cachedCoursesTable} (
        ${StorageKeys.colId}            INTEGER PRIMARY KEY,
        ${StorageKeys.colDepartmentId}  INTEGER,
        ${StorageKeys.colTitle}         TEXT NOT NULL,
        ${StorageKeys.colAcademicYear}  INTEGER NOT NULL,
        ${StorageKeys.colStreamId}      INTEGER,
        ${StorageKeys.colIconKey}       TEXT,
        ${StorageKeys.colResourceCount} INTEGER DEFAULT 16,
        ${StorageKeys.colSemesterLabel} TEXT,
        ${StorageKeys.colSyncedAt}      TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageKeys.cachedResourceItemsTable} (
        ${StorageKeys.colId}            INTEGER PRIMARY KEY,
        ${StorageKeys.colCourseId}      INTEGER NOT NULL,
        ${StorageKeys.colTitle}         TEXT NOT NULL,
        ${StorageKeys.colDescription}   TEXT,
        ${StorageKeys.colCategory}      TEXT NOT NULL,
        ${StorageKeys.colIsFreeSample}  INTEGER NOT NULL DEFAULT 0,
        ${StorageKeys.colLocked}        INTEGER NOT NULL DEFAULT 0,
        ${StorageKeys.colMessage}       TEXT,
        ${StorageKeys.colFileUrl}       TEXT,
        ${StorageKeys.colFileSizeBytes} INTEGER,
        ${StorageKeys.colChecksum}      TEXT,
        ${StorageKeys.colCourseName}    TEXT,
        ${StorageKeys.colSemesterLabel} TEXT,
        ${StorageKeys.colAcademicYear}  INTEGER,
        ${StorageKeys.colSyncedAt}      TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${StorageKeys.cachedNotificationsTable} (
        ${StorageKeys.colId}         INTEGER PRIMARY KEY,
        ${StorageKeys.colType}       TEXT,
        ${StorageKeys.colMessage}    TEXT NOT NULL,
        ${StorageKeys.colReadStatus} INTEGER NOT NULL DEFAULT 0,
        ${StorageKeys.colCreatedAt}  TEXT,
        ${StorageKeys.colSyncedAt}   TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createCacheTables(db);
      // Migrate cached_resources table if columns missing
      for (final col in [
        '${StorageKeys.colTitle} TEXT',
        '${StorageKeys.colCategory} TEXT',
        '${StorageKeys.colCourseName} TEXT',
        '${StorageKeys.colFileSizeBytes} INTEGER',
      ]) {
        try {
          await db.execute(
            'ALTER TABLE ${StorageKeys.cachedResourcesTable} ADD COLUMN $col',
          );
        } catch (_) {}
      }
    }
  }

  // ── Generic helpers ────────────────────────────────────────────

  static Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final db = await database;
    return db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
  }

  /// High-performance batch insert/replace executing all operations
  /// in a single native SQLite transaction.
  static Future<void> batchInsert(
    String table,
    List<Map<String, dynamic>> items, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    if (items.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(table, item, conflictAlgorithm: conflictAlgorithm);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  static Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
