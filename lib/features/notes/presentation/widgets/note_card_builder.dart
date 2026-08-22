import 'package:flutter/material.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/block_note_card.dart';
import 'package:notes_app/features/notes/presentation/widgets/reminder_card.dart';

/// نوع reminder ساختار اختصاصی خودش رو داره (checklistitems + reminderTime)
/// و از ReminderCard نمایش داده میشه.
///
/// بقیه‌ی type ها (cheklist, quote, diary, target, image, text) همه از
/// FreeNoteEditor ساخته میشن و داده‌شون توی note.blocks ذخیره میشه، پس
/// همه‌شون از یه کارت عمومی یعنی BlockNoteCard استفاده می‌کنن.
class NoteCardBuilder extends StatelessWidget {
  final Note note;
  final void Function(int index, bool value)? onReminderItemChanged;
  final void Function(int blockIndex, bool value)? onBlockChecklistChanged;

  const NoteCardBuilder({
    super.key,
    required this.note,
    this.onReminderItemChanged,
    this.onBlockChecklistChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (note.type) {
      case NoteType.reminder:
        return ReminderCard(note: note, onItemChanged: onReminderItemChanged);

      case NoteType.cheklist:
      case NoteType.quote:
      case NoteType.image:
      case NoteType.text:
      case NoteType.target:
      case NoteType.diary:
        return BlockNoteCard(
          note: note,
          onChecklistItemChanged: onBlockChecklistChanged,
        );
    }
  }
}
