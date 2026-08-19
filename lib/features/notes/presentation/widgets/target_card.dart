import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_meta.dart';

class TargetCard extends StatelessWidget {
  final Note note;

  const TargetCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final items = note.checklistitems ?? [];

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
          // Title
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPriamry,
            ),
          ),

          const SizedBox(height: 8),

          // Content
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textPriamry,
            ),
          ),

          const SizedBox(height: 12),

          // Checklist
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.isDone ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: item.isDone
                        ? AppColors.textPriamry
                        : AppColors.textSecondery,
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPriamry,
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
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
