
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'ai_study_companion.db',
    );

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            subject TEXT NOT NULL,
            content TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final columns = await db.rawQuery(
            'PRAGMA table_info(notes)',
          );

          final hasCreatedAt = columns.any(
            (column) => column['name'] == 'createdAt',
          );

          if (!hasCreatedAt) {
            await db.execute(
              "ALTER TABLE notes ADD COLUMN "
              "createdAt TEXT NOT NULL DEFAULT ''",
            );
          }
        }
      },
    );
  }

  // Insert a new note.
  Future<int> insertNote(Note note) async {
    final db = await database;

    return await db.insert(
      'notes',
      note.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all notes.
  Future<List<Note>> getNotes() async {
    final db = await database;

    final result = await db.query(
      'notes',
      orderBy: 'id DESC',
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Delete a note.
  Future<int> deleteNote(int id) async {
    final db = await database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Retrieve all distinct subjects.
  Future<List<String>> getSubjects() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT DISTINCT subject FROM notes '
      'ORDER BY subject ASC',
    );

    return result
        .map((row) => row['subject'].toString())
        .toList();
  }
}
