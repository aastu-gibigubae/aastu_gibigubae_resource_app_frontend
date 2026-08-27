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
  static const int _dbVersion = 1;

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
        ${StorageKeys.colId}         INTEGER PRIMARY KEY AUTOINCREMENT,
        ${StorageKeys.colResourceId} TEXT    NOT NULL UNIQUE,
        ${StorageKeys.colFilePath}   TEXT    NOT NULL,
        ${StorageKeys.colChecksum}   TEXT,
        ${StorageKeys.colUpdatedAt}  TEXT,
        ${StorageKeys.colCachedAt}   TEXT    NOT NULL,
        ${StorageKeys.colIsPremium}  INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle future migrations here.
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
