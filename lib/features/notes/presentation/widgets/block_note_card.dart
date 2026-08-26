import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';

import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_meta.dart';

class BlockNoteCard extends StatelessWidget {
  final Note note;

  final void Function(int blockIndex, bool value)? onChecklistItemChanged;

  const BlockNoteCard({
    super.key,
    required this.note,
    this.onChecklistItemChanged,
  });

  static const int _maxPreviewBlocks = 4;

  // ============================================================
  // RICH TEXT PREVIEW
  // ============================================================

  Widget _buildRichTextPreview(NoteBlock block) {
    final jsonString = block.richTextJson;

    if (jsonString == null || jsonString.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          block.text ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textPriamry, fontSize: 13),
        ),
      );
    }

    try {
      final List<dynamic> jsonDocument = jsonDecode(jsonString);

      final document = ParchmentDocument.fromJson(jsonDocument);

      final controller = FleatherController(document: document);

      return Container(
        constraints: const BoxConstraints(maxHeight: 150),
        margin: const EdgeInsets.only(bottom: 6),
        child: IgnorePointer(
          child: FleatherEditor(
            controller: controller,
            readOnly: true,
            scrollable: false,
            showCursor: false,
            enableInteractiveSelection: false,
            autofocus: false,
            padding: EdgeInsets.zero,
            textWidthBasis: TextWidthBasis.parent,
          ),
        ),
      );
    } catch (_) {
      // اگر JSON خراب بود، حداقل plain text نمایش داده شود.
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          block.text ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textPriamry, fontSize: 13),
        ),
      );
    }
  }

  // ============================================================
  // BLOCK PREVIEW
  // ============================================================

  Widget _buildBlockPreview(NoteBlock block, int index) {
    switch (block.type) {
      // ========================================================
      // TEXT
      // ========================================================

      case NoteBlockType.text:
        return _buildRichTextPreview(block);

      // ========================================================
      // CHECKLIST
      // ========================================================

      case NoteBlockType.checklist:
        final bool isDone = block.isDone ?? false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(
            onTap: onChecklistItemChanged == null
                ? null
                : () {
                    onChecklistItemChanged!.call(index, !isDone);
                  },
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

      // ========================================================
      // QUOTE
      // ========================================================

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

      // ========================================================
      // IMAGE
      // ========================================================

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

  // ============================================================
  // BUILD
  // ============================================================

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
          // ======================================================
          // TITLE
          // ======================================================
          if (note.title.isNotEmpty) ...[
            Text(
              note.title,
              style: NoteTextStyle.headingTitleCard,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),
          ],

          // ======================================================
          // BLOCKS
          // ======================================================
          if (previewBlocks.isEmpty)
            const Text(
              'Empty note',
              style: TextStyle(color: AppColors.textSecondery, fontSize: 12),
            )
          else
            ...previewBlocks.asMap().entries.map((entry) {
              return _buildBlockPreview(entry.value, entry.key);
            }),

          const SizedBox(height: 4),

          // ======================================================
          // META
          // ======================================================
          NoteMeta(note: note),
        ],
      ),
    );
  }
}
