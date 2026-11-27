
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  // Android emulator connects to the host computer through 10.0.2.2.
  static const String baseUrl = 'http://10.0.2.2:8000';

  static const Duration timeout = Duration(seconds: 15);

  // GET: Retrieve all notes.
  static Future<List<Note>> getNotes() async {
    final response = await http
        .get(Uri.parse('$baseUrl/notes'))
        .timeout(timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((item) {
        return Note.fromMap(
          Map<String, dynamic>.from(item),
        );
      }).toList();
    }

    throw Exception(
      'Failed to load notes. Status: ${response.statusCode}',
    );
  }

  // POST: Create a new note.
  static Future<void> createNote(Note note) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/notes'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'title': note.title,
            'subject': note.subject,
            'content': note.content,
            'createdAt': note.createdAt,
          }),
        )
        .timeout(timeout);

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to save note: ${response.body}',
      );
    }
  }

  // PUT: Update an existing note.
  static Future<void> updateNote(Note note) async {
    if (note.id == null) {
      throw Exception('Note ID is required.');
    }

    final response = await http
        .put(
          Uri.parse('$baseUrl/notes/${note.id}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'title': note.title,
            'subject': note.subject,
            'content': note.content,
            'createdAt': note.createdAt,
          }),
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update note: ${response.body}',
      );
    }
  }

  // DELETE: Delete a note.
  static Future<void> deleteNote(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/notes/$id'))
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete note: ${response.body}',
      );
    }
  }
}
