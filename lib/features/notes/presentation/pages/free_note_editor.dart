import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/widgets/format_bottom_sheet.dart';

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

  // یه Key ثابت به‌ازای هر بلاک، جدا از خودِ NoteBlock.
  // چون هر بار toggle/ادیت یه نمونه‌ی جدید از NoteBlock ساخته میشه،
  // بدون این Key ثابت، ویجت چک‌لیست هر بار از نو ساخته میشه و
  // TextField داخلش فوکوس/کرسرش رو از دست می‌ده.
  final List<Key> _blockKeys = [];

  final TextEditingController _textController = TextEditingController();

  // استایل فرمتی که از FormatBottomSheet انتخاب شده و روی متنی که
  // الان داره توی تکست‌فیلد پایین نوشته می‌شه (و بلاک بعدی که ساخته
  // می‌شه) اعمال می‌شه.
  TextFormatStyle _composingStyle = const TextFormatStyle();

  @override
  void initState() {
    super.initState();
    _blocks = List<NoteBlock>.from(widget.initialBlocks);
    _blockKeys.addAll(List<Key>.generate(_blocks.length, (_) => UniqueKey()));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    widget.onChanged(List<NoteBlock>.unmodifiable(_blocks));
  }

  void _addTextBlock() {
    final text = _textController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _blocks.add(
        NoteBlock(
          type: NoteBlockType.text,
          text: text,
          format: _composingStyle,
        ),
      );
      _blockKeys.add(UniqueKey());
    });

    _textController.clear();
    _notifyChanged();
  }

  /// اگه توی تکست‌فیلد پایین (Write something...) متنی نوشته شده باشه
  /// ولی هنوز Enter/Add نزده باشه، این متد اون رو به یه Block تبدیل
  /// می‌کنه. باید قبل از Save توسط CreateNotePage صدا زده بشه، وگرنه
  /// اون متن گم می‌شه.
  void flushPendingText() {
    _addTextBlock();
  }

  void _addChecklistBlock() {
    setState(() {
      _blocks.add(
        const NoteBlock(type: NoteBlockType.checklist, text: '', isDone: false),
      );
      _blockKeys.add(UniqueKey());
    });

    _notifyChanged();
  }

  void _addQuoteBlock() {
    setState(() {
      _blocks.add(
        const NoteBlock(
          type: NoteBlockType.quote,
          text: 'Quote',
          quoteAuthor: '',
        ),
      );
      _blockKeys.add(UniqueKey());
    });

    _notifyChanged();
  }

  void _removeBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
      _blockKeys.removeAt(index);
    });

    _notifyChanged();
  }

  void _toggleChecklist(int index) {
    final block = _blocks[index];

    setState(() {
      _blocks[index] = NoteBlock(
        type: block.type,
        text: block.text,
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
      type: block.type,
      text: text,
      isDone: block.isDone,
      imageUrl: block.imageUrl,
      quoteAuthor: block.quoteAuthor,
    );

    _notifyChanged();
  }

  void _updateQuoteBlock(int index, {String? text, String? quoteAuthor}) {
    final block = _blocks[index];

    _blocks[index] = NoteBlock(
      type: block.type,
      text: text ?? block.text,
      isDone: block.isDone,
      imageUrl: block.imageUrl,
      quoteAuthor: quoteAuthor ?? block.quoteAuthor,
    );

    _notifyChanged();
  }

  // تبدیل TextFormatStyle به TextStyle واقعی فلاتر، هم برای پیش‌نمایش
  // زنده‌ی تکست‌فیلد در حال تایپ و هم برای بلاک متنی نهایی.
  TextStyle _textStyleFor(TextFormatStyle format) {
    double baseFontSize;
    FontWeight baseWeight;

    switch (format.heading) {
      case HeadingType.heading1:
        baseFontSize = 22;
        baseWeight = FontWeight.w700;
        break;
      case HeadingType.heading2:
        baseFontSize = 18;
        baseWeight = FontWeight.w600;
        break;
      case HeadingType.none:
        baseFontSize = 16;
        baseWeight = FontWeight.w400;
        break;
    }

    return TextStyle(
      color: format.textColor,
      backgroundColor: format.highlightColor,
      fontSize: baseFontSize,
      fontWeight: format.isBold ? FontWeight.w700 : baseWeight,
      fontStyle: format.isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: format.isUnderline
          ? TextDecoration.underline
          : TextDecoration.none,
    );
  }

  // برای حالت بولت/شماره‌دار، چون هر بلاک متنی مستقل ذخیره می‌شه،
  // فقط یه پیشوند ساده جلوی متن اضافه می‌کنیم.
  String _listPrefixFor(TextFormatStyle format) {
    if (format.isBulletList) return '•  ';
    if (format.isNumberedList) return '1.  ';
    return '';
  }

  void _openFormatSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FormatBottomSheet(
        initialStyle: _composingStyle,
        onChanged: (style) => setState(() => _composingStyle = style),
      ),
    );
  }

  Widget _buildBlock(NoteBlock block, int index) {
    switch (block.type) {
      case NoteBlockType.text:
        final format = block.format ?? const TextFormatStyle();

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${_listPrefixFor(format)}${block.text ?? ''}',
                  style: _textStyleFor(format),
                ),
              ),
              IconButton(
                onPressed: () => _removeBlock(index),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
        );

      case NoteBlockType.checklist:
        // آیتم چک‌لیست حالا یه ویجت جدا با TextField خودشه
        // تا بشه متنش رو ویرایش کرد. ظاهرش عیناً مثل ReminderCard.
        return _ChecklistBlockItem(
          key: _blockKeys[index],
          initialText: block.text ?? '',
          isDone: block.isDone ?? false,
          onTextChanged: (text) => _updateChecklistText(index, text),
          onToggle: () => _toggleChecklist(index),
          onRemove: () => _removeBlock(index),
        );

      case NoteBlockType.quote:
        // بلاک quote حالا با دو تا TextField (متن + نویسنده)
        // قابل ویرایشه، دقیقاً با همون تکنیک Key ثابت که برای
        // چک‌لیست استفاده کردیم.
        return _QuoteBlockItem(
          key: _blockKeys[index],
          initialText: block.text ?? '',
          initialAuthor: block.quoteAuthor ?? '',
          onTextChanged: (text) => _updateQuoteBlock(index, text: text),
          onAuthorChanged: (author) =>
              _updateQuoteBlock(index, quoteAuthor: author),
          onRemove: () => _removeBlock(index),
        );

      case NoteBlockType.image:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF202126),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, color: Colors.grey, size: 40),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ارتفاع فعلی کیبورد (وقتی بسته‌ست صفره)
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            children: [
              ..._blocks.asMap().entries.map(
                (entry) => _buildBlock(entry.value, entry.key),
              ),

              TextField(
                controller: _textController,
                minLines: 3,
                maxLines: null,
                style: _textStyleFor(_composingStyle),
                decoration: const InputDecoration(
                  hintText: 'Write something...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _addTextBlock(),
              ),
            ],
          ),
        ),

        // نوار پایین دیگه ثابت نیست؛ با AnimatedPadding خودش
        // به‌آرومی بالای کیبورد میره وقتی کیبورد باز میشه
        AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: keyboardHeight > 0
                ? keyboardHeight
                : MediaQuery.of(context).padding.bottom,
          ),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.transparent,
            child: Row(
              children: [
                IconButton(
                  onPressed: _addChecklistBlock,
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.check_box_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                IconButton(
                  onPressed: _addQuoteBlock,
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.format_quote,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    // مرحله بعدی: انتخاب تصویر
                  },
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                IconButton(
                  tooltip: 'more content',
                  onPressed: _addTextBlock,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, color: Colors.white, size: 22),
                ),

                IconButton(
                  onPressed: _openFormatSheet,
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.text_fields_rounded,
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

/// آیتم چک‌لیست با TextField قابل ویرایش.
/// TextEditingController فقط یه‌بار توی initState از initialText
/// مقداردهی میشه؛ به همین خاطر با Key ثابتی که والد پاس می‌ده،
/// این ویجت با toggle/تغییرات بقیه‌ی بلاک‌ها دوباره initState نمی‌شه
/// و متنی که کاربر داره تایپ می‌کنه از دست نمی‌ره.
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

/// بلاک quote با دو TextField قابل ویرایش (متن نقل‌قول + نویسنده).
/// مثل _ChecklistBlockItem، کنترلرها فقط یه‌بار توی initState
/// مقداردهی میشن تا با toggle/تغییر بقیه‌ی بلاک‌ها پاک نشن.
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
