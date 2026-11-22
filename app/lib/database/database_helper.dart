import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('study_notes.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // Insert a new note.
  Future<int> insertNote(Note note) async {
    final db = await database;

    return await db.insert('notes', note.toMap()..remove('id'));
  }

  // Retrieve all notes.
  Future<List<Note>> getNotes() async {
    final db = await database;

    final result = await db.query('notes', orderBy: 'id DESC');

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Delete a note.
  Future<int> deleteNote(int id) async {
    final db = await database;

    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Close the database when required.
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
