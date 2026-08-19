import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/features/notes/model/model.dart';

class NoteMeta extends StatelessWidget {
  final Note note;

  const NoteMeta({super.key, required this.note});

  String get noteType {
    switch (note.type) {
      case NoteType.reminder:
        return 'Reminder';

      case NoteType.cheklist:
        return 'Checklist';

      case NoteType.target:
        return 'Target';

      case NoteType.quote:
        return 'Quote';

      case NoteType.image:
        return 'Image';

      case NoteType.text:
        return 'Text';
      case NoteType.diary:
        return 'Diary';
    }
  }

  String get noteDate {
    return DateFormat('MMMM  d').format(note.createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          noteDate,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondery),
        ),
        Text(
          noteType,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondery),
        ),
      ],
    );
  }
}
