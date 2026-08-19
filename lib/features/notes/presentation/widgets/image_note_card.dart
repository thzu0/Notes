import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';

import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_meta.dart';

class ImageNoteCard extends StatelessWidget {
  final Note note;
  const ImageNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (note.imageUrl != null)
            AspectRatio(
              aspectRatio: 1.35,
              child: Image.network(
                note.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: EdgeInsets.all(14),
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
                const SizedBox(height: 7),

                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textPriamry,
                  ),
                ),
                const SizedBox(height: 6),

                // Type + Date
                NoteMeta(note: note),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
