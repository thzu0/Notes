import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';

import 'package:notes_app/features/notes/model/model.dart';

class ChecklistCard extends StatelessWidget {
  final Note note;
  const ChecklistCard({super.key, required this.note});

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
        children: <Widget>[
          Text(
            note.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPriamry,
            ),
          ),

          SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
        ],
      ),
    );
  }
}
