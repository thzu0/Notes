import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_meta.dart';

class ReminderCard extends StatelessWidget {
  final Note note;
  const ReminderCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(note.title, style: NoteTextStyle.headingTitleCard),
          const SizedBox(height: 10),

          ...note.checklistitems?.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        item.isDone
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 18,
                        color: item.isDone
                            ? AppColors.textPriamry
                            : AppColors.textSecondery,
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textPriamry,
                            decoration: item.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }) ??
              [],
          const SizedBox(height: 4),

          NoteMeta(note: note),
        ],
      ),
    );
  }
}
