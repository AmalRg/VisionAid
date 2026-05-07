import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/history_item.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'visionaid.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type INTEGER NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            translated_content TEXT,
            detected_language TEXT,
            target_language TEXT,
            timestamp INTEGER NOT NULL,
            image_path TEXT,
            object_count INTEGER DEFAULT 0,
            confidence REAL
          )
        ''');
      },
    );
  }

  Future<List<HistoryItem>> getAllItems() async {
    final rows = await _db!.query('history', orderBy: 'timestamp DESC');
    return rows.map(HistoryItem.fromMap).toList();
  }

  Future<void> insertItem(HistoryItem item) async {
    await _db!.insert('history', item.toMap());
  }

  Future<void> deleteItem(int id) async {
    await _db!.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    await _db!.delete('history');
  }
}
