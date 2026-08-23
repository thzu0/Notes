import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_meta.dart';

/// کارتی که برای نمایش نوت‌های آزاد (بلاک‌محور) توی خونه استفاده میشه.
/// این نوت‌ها همون‌هایی هستن که با FreeNoteEditor ساخته شدن، یعنی
/// همه‌ی type ها بجز reminder (چون reminder ساختار جدای خودش رو داره).
class BlockNoteCard extends StatelessWidget {
  final Note note;

  /// وقتی کاربر روی یه آیتم چک‌لیستِ داخل بلاک‌ها تپ می‌کنه.
  /// blockIndex ایندکسِ اون بلاک توی note.blocks هست.
  final void Function(int blockIndex, bool value)? onChecklistItemChanged;

  const BlockNoteCard({
    super.key,
    required this.note,
    this.onChecklistItemChanged,
  });

  static const int _maxPreviewBlocks = 4;

  Widget _buildBlockPreview(NoteBlock block, int index) {
    switch (block.type) {
      case NoteBlockType.text:
        // فرمتی که از FormatBottomSheet روی این بلاک اعمال شده
        // (heading/bold/italic/underline/list/رنگ‌ها) رو توی
        // پیش‌نمایش کارت هم پیاده می‌کنیم، با سایزهای کوچیک‌تر
        // متناسب با فضای کارت.
        final format = block.format ?? const TextFormatStyle();

        double fontSize;
        FontWeight baseWeight;

        switch (format.heading) {
          case HeadingType.heading1:
            fontSize = 16;
            baseWeight = FontWeight.w700;
            break;
          case HeadingType.heading2:
            fontSize = 14;
            baseWeight = FontWeight.w600;
            break;
          case HeadingType.none:
            fontSize = 13;
            baseWeight = FontWeight.w400;
            break;
        }

        final String prefix = format.isBulletList
            ? '•  '
            : (format.isNumberedList ? '1.  ' : '');

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            '$prefix${block.text ?? ''}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: format.textColor,
              backgroundColor: format.highlightColor,
              fontSize: fontSize,
              fontWeight: format.isBold ? FontWeight.w700 : baseWeight,
              fontStyle: format.isItalic ? FontStyle.italic : FontStyle.normal,
              decoration: format.isUnderline
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        );

      case NoteBlockType.checklist:
        final bool isDone = block.isDone ?? false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(
            onTap: onChecklistItemChanged == null
                ? null
                : () => onChecklistItemChanged!.call(index, !isDone),
            borderRadius: BorderRadius.circular(6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.circle_outlined,
                  size: 15,
                  color: isDone
                      ? AppColors.textPriamry
                      : AppColors.textSecondery,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    block.text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPriamry,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case NoteBlockType.quote:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${block.text ?? ''}"',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPriamry,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),

              if ((block.quoteAuthor ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '— ${block.quoteAuthor}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondery,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        );
      case NoteBlockType.image:
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          height: 70,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF202126),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              color: AppColors.textSecondery,
              size: 26,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewBlocks = note.blocks.take(_maxPreviewBlocks).toList();

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
          if (note.title.isNotEmpty) ...[
            Text(note.title, style: NoteTextStyle.headingTitleCard),
            const SizedBox(height: 10),
          ],

          if (previewBlocks.isEmpty)
            const Text(
              'Empty note',
              style: TextStyle(color: AppColors.textSecondery, fontSize: 12),
            )
          else
            ...previewBlocks.asMap().entries.map(
              (entry) => _buildBlockPreview(entry.value, entry.key),
            ),

          const SizedBox(height: 4),

          NoteMeta(note: note),
        ],
      ),
    );
  }
}
