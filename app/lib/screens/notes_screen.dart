import 'package:flutter/material.dart';

import '../models/note.dart';
import '../database/database_helper.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> notes = [];

  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  // Load all saved notes from SQLite.
  Future<void> loadNotes() async {
    try {
      final result = await DatabaseHelper.instance.getNotes();

      if (!mounted) return;

      setState(() {
        notes = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to load notes: $e')));
    }
  }

  // Search notes by title, subject or content.
  List<Note> get filteredNotes {
    if (searchQuery.trim().isEmpty) {
      return notes;
    }

    final query = searchQuery.toLowerCase().trim();

    return notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.subject.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
  }

  // Open the Add Note dialog.
  // The dialog returns a Note object.
  // Database insertion happens AFTER the dialog closes.
  Future<void> showAddNoteDialog() async {
    final Note? newNote = await showDialog<Note>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const AddNoteDialog();
      },
    );

    if (!mounted || newNote == null) return;

    try {
      await DatabaseHelper.instance.insertNote(newNote);

      if (!mounted) return;

      await loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete note after confirmation.
  Future<void> removeNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note?'),
          content: Text('Are you sure you want to delete "${note.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirm != true || note.id == null) {
      return;
    }

    try {
      await DatabaseHelper.instance.deleteNote(note.id!);

      if (!mounted) return;

      await loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedNotes = filteredNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Study Notes'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search field.
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),

                // Notes list.
                Expanded(
                  child: displayedNotes.isEmpty
                      ? Center(
                          child: Text(
                            searchQuery.isEmpty
                                ? 'No notes yet.\nTap + to create your first note!'
                                : 'No matching notes found.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadNotes,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: displayedNotes.length,
                            itemBuilder: (context, index) {
                              final note = displayedNotes[index];

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),

                                  title: Text(
                                    note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),

                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${note.subject}\n\n${note.content}',
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  isThreeLine: true,

                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      removeNote(note);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddNoteDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Separate Add Note dialog.
// Controllers are disposed only when the dialog is disposed.
class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();

  final TextEditingController subjectController = TextEditingController();

  final TextEditingController contentController = TextEditingController();

  bool isSubmitting = false;

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    contentController.dispose();

    super.dispose();
  }

  // Validate and return the Note to the parent screen.
  void saveNote() {
    if (isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final note = Note(
      title: titleController.text.trim(),
      subject: subjectController.text.trim(),
      content: contentController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    setState(() {
      isSubmitting = true;
    });

    // Return the note to NotesScreen.
    // Database insertion is handled there.
    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Study Note'),

      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter note title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: subjectController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: contentController,
                maxLines: 5,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter note content';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: isSubmitting ? null : saveNote,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save Note'),
        ),
      ],
    );
  }
}
