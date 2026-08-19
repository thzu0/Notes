import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';

import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_meta.dart';

class TextNoteCard extends StatelessWidget {
  final Note note;
  const TextNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            note.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPriamry,
            ),
          ),
          SizedBox(height: 9),
          Text(
            note.content,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textPriamry,
            ),
          ),
          const SizedBox(height: 6),

          // Type + Date
          NoteMeta(note: note),
        ],
      ),
    );
  }
}
