import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            server_id INTEGER,
            title TEXT,
            content TEXT,
            is_synced INTEGER
          )
        ''');
      },
    );
  }

  // 🔹 Get notes not yet synced
  Future<List<Map<String, dynamic>>> getUnsyncedNotes() async {
    final db = await database;
    return await db.query('notes', where: 'is_synced = 0');
  }

  // 🔹 Mark note as synced
  Future<void> markAsSynced(int localId, int serverId) async {
    final db = await database;
    await db.update(
      'notes',
      {'is_synced': 1, 'server_id': serverId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // 🔹 Get all server IDs stored locally
  Future<List<int>> getLocalServerIds() async {
    final db = await database;
    final res = await db.query('notes', columns: ['server_id']);

    return res
        .where((e) => e['server_id'] != null)
        .map((e) => e['server_id'] as int)
        .toList();
  }

  // 🔹 Insert note pulled from server
  Future<void> insertServerNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.insert('notes', {
      'server_id': note['id'],
      'title': note['title'],
      'content': note['content'],
      'is_synced': 1,
    });
  }

  Future<int> insertNote(Map<String, dynamic> note) async {
  final db = await database;
  return await db.insert('notes', {
    'title': note['title'],
    'content': note['content'],
    'is_synced': 0,
    'server_id': null,
  });
}

// 🔹 Get all notes (for UI)
Future<List<Map<String, dynamic>>> getNotes() async {
  final db = await database;
  return await db.query(
    'notes',
    orderBy: 'id DESC',
  );
}
  
}
