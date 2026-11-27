
import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/api_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> notes = [];

  bool isLoading = true;
  bool isSaving = false;

  final TextEditingController searchController =
      TextEditingController();

  String selectedSubject = 'All Subjects';

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // GET: Fetch notes from the FastAPI backend.
  Future<void> loadNotes() async {
    try {
      final data = await ApiService.getNotes();

      if (!mounted) return;

      setState(() {
        notes = data;
        isLoading = false;

        if (selectedSubject != 'All Subjects' &&
            !notes.any(
              (note) => note.subject == selectedSubject,
            )) {
          selectedSubject = 'All Subjects';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load notes: $e'),
        ),
      );
    }
  }

  // POST: Add a note through the backend API.
  Future<void> showAddNoteDialog() async {
    if (isSaving) return;

    final Note? newNote = await showDialog<Note>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const _AddNoteDialog();
      },
    );

    if (!mounted || newNote == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.createNote(newNote);

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
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // DELETE: Remove a note through the backend API.
  Future<void> removeNote(Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note?'),
          content: Text('Delete "${note.title}"?'),
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
      await ApiService.deleteNote(note.id!);

      if (!mounted) return;

      await loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note deleted successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Search notes and filter by subject.
  List<Note> get filteredNotes {
    final query = searchController.text.trim().toLowerCase();

    return notes.where((note) {
      final matchesSearch =
          note.title.toLowerCase().contains(query) ||
          note.subject.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);

      final matchesSubject =
          selectedSubject == 'All Subjects' ||
          note.subject == selectedSubject;

      return matchesSearch && matchesSubject;
    }).toList();
  }

  // Generate subject dropdown items.
  List<String> get subjects {
    final result = notes
        .map((note) => note.subject)
        .toSet()
        .toList();

    result.sort();

    return ['All Subjects', ...result];
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
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // SEARCH FIELD
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12, 12, 12, 6,
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // SUBJECT FILTER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedSubject,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Subject',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.filter_list),
                    ),
                    items: subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedSubject = value;
                      });
                    },
                  ),
                ),

                // NOTES LIST
                Expanded(
                  child: displayedNotes.isEmpty
                      ? Center(
                          child: Text(
                            notes.isEmpty
                                ? 'No notes yet.\nTap + to create your first note!'
                                : 'No matching notes found.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: loadNotes,
                          child: ListView.builder(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemCount: displayedNotes.length,
                            itemBuilder: (context, index) {
                              final note =
                                  displayedNotes[index];

                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.indigo,
                                    child: Icon(
                                      Icons.menu_book,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    note.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding:
                                        const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    child: Text(
                                      '${note.subject}\n${note.content}',
                                      maxLines: 3,
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                  ),
                                  isThreeLine: true,
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        removeNote(note),
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
        onPressed: isSaving ? null : showAddNoteDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: isSaving
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}

// Add Note Dialog
class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() =>
      _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void saveNote() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final note = Note(
      title: titleController.text.trim(),
      subject: subjectController.text.trim(),
      content: contentController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Study Note'),

      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Note Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter note title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter subject';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Note Content',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter note content';
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: saveNote,
          child: const Text('Save Note'),
        ),
      ],
    );
  }
}
