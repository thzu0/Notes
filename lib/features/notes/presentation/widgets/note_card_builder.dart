import 'package:flutter/material.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/chekboxlist_card.dart';
import 'package:notes_app/features/notes/presentation/widgets/diary_card.dart';
import 'package:notes_app/features/notes/presentation/widgets/image_note_card.dart';
import 'package:notes_app/features/notes/presentation/widgets/quote_card.dart';
import 'package:notes_app/features/notes/presentation/widgets/reminder_card.dart';
import 'package:notes_app/features/notes/presentation/widgets/target_card.dart';
import 'package:notes_app/features/notes/presentation/widgets/text_note_card.dart';

class NoteCardBuilder extends StatelessWidget {
  final Note note;
  const NoteCardBuilder({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    switch (note.type) {
      case NoteType.reminder:
        return ReminderCard(note: note);

      case NoteType.cheklist:
        return ChecklistCard(note: note);

      case NoteType.quote:
        return QuoteCard(note: note);

      case NoteType.image:
        return ImageNoteCard(note: note);

      case NoteType.text:
        return TextNoteCard(note: note);

      case NoteType.target:
        return TargetCard(note: note);

      case NoteType.diary:
        return DiaryCard(note: note);
    }
  }
}
