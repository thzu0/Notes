import 'dart:convert';
import 'dart:io';

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
  // IMAGE NOTE CARD
  // ============================================================

  Widget _buildImageNoteCard(NoteBlock imageBlock) {
    final imagePath = imageBlock.imageUrl;

    NoteBlock? textBlock;

    for (final block in note.blocks) {
      if (block.type == NoteBlockType.text) {
        textBlock = block;
        break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ======================================================
          // IMAGE
          // ======================================================
          AspectRatio(
            aspectRatio: 1.55,
            child: imagePath != null && imagePath.isNotEmpty
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF202126),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textSecondery,
                            size: 38,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: const Color(0xFF202126),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondery,
                        size: 38,
                      ),
                    ),
                  ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.title.isNotEmpty)
                      Expanded(
                        child: Text(
                          note.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: NoteTextStyle.headingTitleCard,
                        ),
                      )
                    else
                      const Spacer(),

                    if (note.isPinned) ...[
                      if (note.title.isNotEmpty) const SizedBox(width: 8),
                      const Icon(
                        Icons.push_pin,
                        size: 17,
                        color: Color(0xFFF5C65D),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                if (textBlock != null) _buildRichTextPreview(textBlock),

                const SizedBox(height: 4),

                NoteMeta(note: note),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
  // LOCKED NOTE
  // ============================================================

  Widget _buildLockedCard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkCardBackground,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Title + Pin
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            note.title.isNotEmpty ? note.title : 'Locked Note',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: NoteTextStyle.headingTitleCard.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (note.isPinned) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.push_pin_rounded,
                            size: 18,
                            color: Color(0xFFF5C65D),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Lock وسط کارت
                  const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 50,
                      color: AppColors.textSecondery,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // اطلاعات پایین کارت
            NoteMeta(note: note),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // LOCKED NOTE
    // ==========================================================

    if (note.isLocked) {
      return _buildLockedCard();
    }

    // ==========================================================
    // PREVIEW BLOCKS
    // ==========================================================

    final previewBlocks = note.blocks.take(_maxPreviewBlocks).toList();

    // ==========================================================
    // FIND IMAGE BLOCK
    // ==========================================================

    final imageBlock = note.blocks.cast<NoteBlock?>().firstWhere(
      (block) => block?.type == NoteBlockType.image,
      orElse: () => null,
    );

    // ==========================================================
    // IMAGE NOTE
    // ==========================================================

    if (note.type == NoteType.image && imageBlock != null) {
      return _buildImageNoteCard(imageBlock);
    }

    // ==========================================================
    // NORMAL NOTE
    // ==========================================================

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ======================================================
          // TITLE
          // ======================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty)
                Expanded(
                  child: Text(
                    note.title,
                    style: NoteTextStyle.headingTitleCard,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),

              if (note.isPinned) ...[
                if (note.title.isNotEmpty) const SizedBox(width: 8),

                const Icon(Icons.push_pin, size: 17, color: Color(0xFFF5C65D)),
              ],
            ],
          ),

          const SizedBox(height: 10),

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
