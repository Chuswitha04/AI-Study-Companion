
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/note.dart';

class DatabaseHelper {
  // Singleton instance.
  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  // Get database instance.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // Initialize SQLite database.
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'ai_study_companion.db',
    );

    return await openDatabase(
      path,
      version: 3,

      // Create database tables.
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

        await db.execute('''
          CREATE INDEX idx_notes_subject
          ON notes(subject)
        ''');
      },

      // Upgrade existing database safely.
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final columns =
              await db.rawQuery('PRAGMA table_info(notes)');

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

        if (oldVersion < 3) {
          await db.execute('''
            CREATE INDEX IF NOT EXISTS idx_notes_subject
            ON notes(subject)
          ''');
        }
      },
    );
  }

  // CREATE: Insert a new note.
  Future<int> insertNote(Note note) async {
    final db = await database;

    final noteMap = note.toMap();
    noteMap.remove('id');

    return await db.insert(
      'notes',
      noteMap,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // READ: Retrieve all notes.
  Future<List<Note>> getNotes() async {
    final db = await database;

    final result = await db.query(
      'notes',
      orderBy: 'id DESC',
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // UPDATE: Modify an existing note.
  Future<int> updateNote(Note note) async {
    if (note.id == null) {
      throw ArgumentError('Note ID is required for updating.');
    }

    final db = await database;

    return await db.update(
      'notes',
      note.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // DELETE: Remove a note.
  Future<int> deleteNote(int id) async {
    final db = await database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // SEARCH: Search title, subject and content.
  Future<List<Note>> searchNotes(String query) async {
    final db = await database;

    final searchText = query.trim();

    if (searchText.isEmpty) {
      return getNotes();
    }

    final result = await db.query(
      'notes',
      where: '''
        title LIKE ? OR
        subject LIKE ? OR
        content LIKE ?
      ''',
      whereArgs: [
        '%$searchText%',
        '%$searchText%',
        '%$searchText%',
      ],
      orderBy: 'id DESC',
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // FILTER: Retrieve notes by subject.
  Future<List<Note>> filterNotesBySubject(
    String subject,
  ) async {
    final db = await database;

    final result = await db.query(
      'notes',
      where: 'subject = ?',
      whereArgs: [subject],
      orderBy: 'id DESC',
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Get all unique subjects.
  Future<List<String>> getSubjects() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT DISTINCT subject
      FROM notes
      ORDER BY subject ASC
    ''');

    return result
        .map((row) => row['subject'].toString())
        .toList();
  }

  // Count total notes.
  Future<int> getNotesCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM notes',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database connection.
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
