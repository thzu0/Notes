import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_meta.dart';

class DiaryCard extends StatelessWidget {
  final Note note;

  const DiaryCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(note.title, style: NoteTextStyle.headingTitleCard),

          const SizedBox(height: 20),

          Center(child: Icon(Icons.lock_outline, size: 100)),

          const SizedBox(height: 20),

          NoteMeta(note: note),
        ],
      ),
    );
  }
}
