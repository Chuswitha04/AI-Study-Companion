
class Note {
  final int? id;
  final String title;
  final String subject;
  final String content;
  final String createdAt;

  const Note({
    this.id,
    required this.title,
    required this.subject,
    required this.content,
    required this.createdAt,
  });

  // Convert Note object into a database map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'content': content,
      'createdAt': createdAt,
    };
  }

  // Convert database map into a Note object.
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  // Create an updated copy of an existing note.
  Note copyWith({
    int? id,
    String? title,
    String? subject,
    String? content,
    String? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
