import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_meta.dart';

class ReminderCard extends StatelessWidget {
  final Note note;
  final void Function(int index, bool value)? onItemChanged;
  const ReminderCard({super.key, required this.note, this.onItemChanged});

  Widget _buildReminderTime(BuildContext context) {
    if (note.reminderTime == null) {
      return const SizedBox.shrink();
    }

    final time = TimeOfDay.fromDateTime(note.reminderTime!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_none_outlined,
            size: 17,
            color: AppColors.textSecondery,
          ),
          const SizedBox(width: 6),
          Text(
            'Reminder • ${time.format(context)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondery,
            ),
          ),
        ],
      ),
    );
  }

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

          _buildReminderTime(context),

          ...(note.checklistitems ?? []).asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  onItemChanged?.call(index, !item.isDone);
                },
                borderRadius: BorderRadius.circular(8),
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
              ),
            );
          }),
          const SizedBox(height: 4),

          NoteMeta(note: note),
        ],
      ),
    );
  }
}
