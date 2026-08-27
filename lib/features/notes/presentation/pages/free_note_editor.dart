import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:image_picker/image_picker.dart';

import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/color_picker_bottom_sheet.dart';
import '../widgets/format_bottom_sheet.dart';

class FreeNoteEditor extends StatefulWidget {
  final List<NoteBlock> initialBlocks;
  final ValueChanged<List<NoteBlock>> onChanged;

  const FreeNoteEditor({
    super.key,
    this.initialBlocks = const [],
    required this.onChanged,
  });

  @override
  State<FreeNoteEditor> createState() => FreeNoteEditorState();
}

class FreeNoteEditorState extends State<FreeNoteEditor> {
  late List<NoteBlock> _blocks;

  final List<Key> _blockKeys = [];

  late FleatherController _fleatherController;

  final GlobalKey<EditorState> _fleatherEditorKey = GlobalKey<EditorState>();

  final FocusNode _fleatherFocusNode = FocusNode();

  bool _isPickingImage = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _blocks = List<NoteBlock>.from(widget.initialBlocks);

    _blockKeys.addAll(List<Key>.generate(_blocks.length, (_) => UniqueKey()));

    _fleatherController = _createControllerFromBlocks();

    _fleatherController.addListener(_onFleatherChanged);
  }

  // ============================================================
  // CREATE FLEATHER CONTROLLER
  // ============================================================

  FleatherController _createControllerFromBlocks() {
    final textBlock = _blocks.firstWhere(
      (block) => block.type == NoteBlockType.text,
      orElse: () => const NoteBlock(type: NoteBlockType.text),
    );

    if (textBlock.richTextJson != null &&
        textBlock.richTextJson!.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(textBlock.richTextJson!);

        if (decoded is List) {
          final document = ParchmentDocument.fromJson(decoded);

          return FleatherController(document: document);
        }
      } catch (_) {
        // If old/corrupted rich text exists,
        // start with an empty document.
      }
    }

    return FleatherController();
  }

  // ============================================================
  // FLEATHER CHANGED
  // ============================================================

  void _onFleatherChanged() {
    _saveFleatherDocument(notifyEditor: false);
  }

  // ============================================================
  // SAVE FLEATHER
  // ============================================================

  void _saveFleatherDocument({bool notifyEditor = true}) {
    final document = _fleatherController.document;

    final dynamic json = document.toJson();

    final String jsonString = jsonEncode(json);

    final String plainText = document.toPlainText().trim();

    final int existingTextIndex = _blocks.indexWhere(
      (block) => block.type == NoteBlockType.text,
    );

    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    if (plainText.isEmpty) {
      if (existingTextIndex != -1) {
        setState(() {
          _blocks.removeAt(existingTextIndex);

          _blockKeys.removeAt(existingTextIndex);
        });
      }

      if (notifyEditor) {
        _notifyChanged();
      }

      return;
    }

    // ----------------------------------------------------------
    // TEXT BLOCK
    // ----------------------------------------------------------

    final textBlock = NoteBlock(
      type: NoteBlockType.text,
      text: plainText,
      richTextJson: jsonString,
    );

    if (existingTextIndex == -1) {
      setState(() {
        _blocks.insert(0, textBlock);

        _blockKeys.insert(0, UniqueKey());
      });
    } else {
      setState(() {
        _blocks[existingTextIndex] = textBlock;
      });
    }

    if (notifyEditor) {
      _notifyChanged();
    }
  }

  // ============================================================
  // FLUSH
  // ============================================================

  void flushPendingText() {
    _saveFleatherDocument();
  }

  // ============================================================
  // FORMAT BOTTOM SHEET
  // ============================================================

  void _openFormatBottomSheet() {
    // مهم:
    // اینجا selection را تغییر نمی‌دهیم.
    //
    // FleatherController خودش selection فعلی را نگه می‌دارد.
    // فقط اجازه نمی‌دهیم BottomSheet برای خودش focus بگیرد.

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      requestFocus: false,
      builder: (_) {
        return FormatBottomSheet(
          controller: _fleatherController,
          onFormatChanged: () {
            // بعد از format دوباره editor را focus می‌کنیم.
            //
            // خود selection داخل controller حفظ شده.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              _fleatherFocusNode.requestFocus();
            });
          },
        );
      },
    );
  }

  // ============================================================
  // COLOR PICKER
  // ============================================================

  void _openColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      requestFocus: false,
      builder: (_) {
        return ColorPickerBottomSheet(
          controller: _fleatherController,
          onColorChanged: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              _fleatherFocusNode.requestFocus();
            });
          },
        );
      },
    );
  }

  // ============================================================
  // CHECKLIST
  // ============================================================

  void _addChecklistBlock() {
    _saveFleatherDocument();

    setState(() {
      _blocks.add(
        const NoteBlock(type: NoteBlockType.checklist, text: '', isDone: false),
      );

      _blockKeys.add(UniqueKey());
    });

    _notifyChanged();
  }

  void _toggleChecklist(int index) {
    final block = _blocks[index];

    setState(() {
      _blocks[index] = NoteBlock(
        type: NoteBlockType.checklist,
        text: block.text,
        richTextJson: block.richTextJson,
        isDone: !(block.isDone ?? false),
        imageUrl: block.imageUrl,
        quoteAuthor: block.quoteAuthor,
      );
    });

    _notifyChanged();
  }

  void _updateChecklistText(int index, String text) {
    final block = _blocks[index];

    _blocks[index] = NoteBlock(
      type: NoteBlockType.checklist,
      text: text,
      richTextJson: block.richTextJson,
      isDone: block.isDone,
      imageUrl: block.imageUrl,
      quoteAuthor: block.quoteAuthor,
    );

    _notifyChanged();
  }

  // ============================================================
  // QUOTE
  // ============================================================

  void _addQuoteBlock() {
    _saveFleatherDocument();

    setState(() {
      _blocks.add(
        const NoteBlock(type: NoteBlockType.quote, text: '', quoteAuthor: ''),
      );

      _blockKeys.add(UniqueKey());
    });

    _notifyChanged();
  }

  void _updateQuoteBlock(int index, {String? text, String? quoteAuthor}) {
    final block = _blocks[index];

    _blocks[index] = NoteBlock(
      type: NoteBlockType.quote,
      text: text ?? block.text,
      richTextJson: block.richTextJson,
      isDone: block.isDone,
      imageUrl: block.imageUrl,
      quoteAuthor: quoteAuthor ?? block.quoteAuthor,
    );

    _notifyChanged();
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Future<void> _addImageBlock() async {
    if (_isPickingImage) return;

    _isPickingImage = true;

    try {
      _saveFleatherDocument();

      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted || image == null) {
        return;
      }

      setState(() {
        _blocks.add(NoteBlock(type: NoteBlockType.image, imageUrl: image.path));

        _blockKeys.add(UniqueKey());
      });

      _notifyChanged();
    } catch (e) {
      debugPrint('Image picker error: $e');
    } finally {
      _isPickingImage = false;
    }
  }
  // ============================================================
  // REMOVE
  // ============================================================

  void _removeBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
      _blockKeys.removeAt(index);
    });

    _notifyChanged();
  }

  // ============================================================
  // NOTIFY
  // ============================================================

  void _notifyChanged() {
    widget.onChanged(List<NoteBlock>.unmodifiable(_blocks));
  }

  // ============================================================
  // TEXT BLOCK
  // ============================================================

  Widget _buildTextBlock(NoteBlock block, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF202126),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                block.text ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            IconButton(
              onPressed: () => _removeBlock(index),
              icon: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHECKLIST UI
  // ============================================================

  Widget _buildChecklistBlock(NoteBlock block, int index) {
    return _ChecklistBlockItem(
      key: _blockKeys[index],
      initialText: block.text ?? '',
      isDone: block.isDone ?? false,
      onTextChanged: (text) {
        _updateChecklistText(index, text);
      },
      onToggle: () {
        _toggleChecklist(index);
      },
      onRemove: () {
        _removeBlock(index);
      },
    );
  }

  // ============================================================
  // QUOTE UI
  // ============================================================

  Widget _buildQuoteBlock(NoteBlock block, int index) {
    return _QuoteBlockItem(
      key: _blockKeys[index],
      initialText: block.text ?? '',
      initialAuthor: block.quoteAuthor ?? '',
      onTextChanged: (text) {
        _updateQuoteBlock(index, text: text);
      },
      onAuthorChanged: (author) {
        _updateQuoteBlock(index, quoteAuthor: author);
      },
      onRemove: () {
        _removeBlock(index);
      },
    );
  }

  // ============================================================
  // IMAGE UI
  // ============================================================

  Widget _buildImageBlock(NoteBlock block, int index) {
    final imagePath = block.imageUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 200,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF202126),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null && imagePath.isNotEmpty)
              Image.file(File(imagePath), fit: BoxFit.cover)
            else
              const Center(
                child: Icon(Icons.image_outlined, color: Colors.grey, size: 40),
              ),

            Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                onPressed: () => _removeBlock(index),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BLOCK BUILDER
  // ============================================================

  Widget _buildBlock(NoteBlock block, int index) {
    switch (block.type) {
      case NoteBlockType.text:
        return _buildTextBlock(block, index);

      case NoteBlockType.checklist:
        return _buildChecklistBlock(block, index);

      case NoteBlockType.quote:
        return _buildQuoteBlock(block, index);

      case NoteBlockType.image:
        return _buildImageBlock(block, index);
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _fleatherController.removeListener(_onFleatherChanged);

    _fleatherController.dispose();

    _fleatherFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      children: [
        // ========================================================
        // EDITOR
        // ========================================================
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            children: [
              ..._blocks
                  .asMap()
                  .entries
                  .where((entry) => entry.value.type != NoteBlockType.text)
                  .map((entry) => _buildBlock(entry.value, entry.key)),

              // ==================================================
              // FLEATHER
              // ==================================================
              Container(
                constraints: const BoxConstraints(minHeight: 180),
                width: double.infinity,
                child: Stack(
                  children: [
                    if (_fleatherController.document
                        .toPlainText()
                        .trim()
                        .isEmpty)
                      const Positioned(
                        top: 8,
                        left: 0,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Write content here ...',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    FleatherEditor(
                      controller: _fleatherController,
                      focusNode: _fleatherFocusNode,
                      editorKey: _fleatherEditorKey,
                      autofocus: false,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ========================================================
        // TOOLBAR
        // ========================================================
        AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: keyboardHeight > 0
                ? keyboardHeight
                : MediaQuery.of(context).padding.bottom,
          ),
          child: Container(
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.darkCardBackground,
              border: Border(top: BorderSide(color: Color(0xFF2A2D35))),
            ),
            child: Row(
              children: [
                // =================================================
                // CHECKLIST
                // =================================================
                IconButton(
                  onPressed: _addChecklistBlock,
                  icon: const Icon(
                    Icons.check_box_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                // =================================================
                // QUOTE
                // =================================================
                IconButton(
                  onPressed: _addQuoteBlock,
                  icon: const Icon(
                    Icons.format_quote,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                // =================================================
                // IMAGE
                // =================================================
                IconButton(
                  onPressed: _addImageBlock,
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                // =================================================
                // COLOR
                // =================================================
                IconButton(
                  onPressed: _openColorPicker,
                  icon: const Icon(
                    Icons.palette_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                const Spacer(),

                // =================================================
                // FORMAT
                // =================================================
                IconButton(
                  onPressed: _openFormatBottomSheet,
                  icon: const Icon(
                    Icons.text_fields,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// CHECKLIST ITEM
// ==================================================================

class _ChecklistBlockItem extends StatefulWidget {
  final String initialText;
  final bool isDone;

  final ValueChanged<String> onTextChanged;

  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const _ChecklistBlockItem({
    super.key,
    required this.initialText,
    required this.isDone,
    required this.onTextChanged,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  State<_ChecklistBlockItem> createState() => _ChecklistBlockItemState();
}

class _ChecklistBlockItemState extends State<_ChecklistBlockItem> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: widget.onToggle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              widget.isDone ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: widget.isDone
                  ? AppColors.textPriamry
                  : AppColors.textSecondery,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onTextChanged,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPriamry,
                decoration: widget.isDone ? TextDecoration.lineThrough : null,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Add Item ...',
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondery,
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: widget.onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondery,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// QUOTE ITEM
// ==================================================================

class _QuoteBlockItem extends StatefulWidget {
  final String initialText;
  final String initialAuthor;

  final ValueChanged<String> onTextChanged;

  final ValueChanged<String> onAuthorChanged;

  final VoidCallback onRemove;

  const _QuoteBlockItem({
    super.key,
    required this.initialText,
    required this.initialAuthor,
    required this.onTextChanged,
    required this.onAuthorChanged,
    required this.onRemove,
  });

  @override
  State<_QuoteBlockItem> createState() => _QuoteBlockItemState();
}

class _QuoteBlockItemState extends State<_QuoteBlockItem> {
  late final TextEditingController _textController;

  late final TextEditingController _authorController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: widget.initialText);

    _authorController = TextEditingController(text: widget.initialAuthor);
  }

  @override
  void dispose() {
    _textController.dispose();
    _authorController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              onChanged: widget.onTextChanged,
              minLines: 1,
              maxLines: null,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Quote...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _authorController,
              onChanged: widget.onAuthorChanged,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                prefixText: '— ',
                prefixStyle: TextStyle(color: Colors.grey, fontSize: 13),
                hintText: 'Author...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
