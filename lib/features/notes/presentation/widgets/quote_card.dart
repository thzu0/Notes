import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';

import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_meta.dart';

class QuoteCard extends StatelessWidget {
  final Note note;
  const QuoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(note.title, style: NoteTextStyle.headingTitleCard),
          const SizedBox(height: 6),
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
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
