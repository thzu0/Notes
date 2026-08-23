import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/pages/free_note_editor.dart';
import 'package:notes_app/features/notes/presentation/widgets/format_bottom_sheet.dart';

/// صفحه ساخت / ویرایش Note.
///
/// اگر existingNote پاس داده بشه، صفحه در حالت ویرایش باز می‌شه:
/// همه فیلدها از روی نوت موجود پر می‌شن و در Save همون id حفظ می‌شه.
///
/// Reminder ساختار اختصاصی خودش را دارد:
/// - Task
/// - Reminder Time
///
/// بقیه Tagها از FreeNoteEditor استفاده می‌کنند و می‌توانند
/// چند نوع Block مختلف مثل Text / Checklist / Quote / Image داشته باشند.
class CreateNotePage extends StatefulWidget {
  final Note? existingNote;

  const CreateNotePage({super.key, this.existingNote});

  bool get isEditing => existingNote != null;

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  NoteType selectedType = NoteType.text;

  // -----------------------------
  // Reminder
  // -----------------------------

  final List<ChecklistItem> _reminderItems = [];
  final TextEditingController _reminderController = TextEditingController();

  DateTime? _reminderTime;

  // -----------------------------
  // Free Note Editor
  // -----------------------------

  List<NoteBlock> _noteBlocks = [];
  final GlobalKey<FreeNoteEditorState> _editorKey =
      GlobalKey<FreeNoteEditorState>();

  // -----------------------------
  // UI
  // -----------------------------

  final Color _categoryColor = const Color(0xFFF5A623);

  static const Color _hintColor = Color(0xFF6B7280);
  static const Color _textColor = Color(0xFFE5E7EB);
  static const Color _dividerColor = Color(0xFF23252B);

  @override
  void initState() {
    super.initState();

    final existing = widget.existingNote;

    if (existing != null) {
      _titleController.text = existing.title;
      _contentController.text = existing.content;
      selectedType = existing.type;

      if (existing.checklistitems != null) {
        _reminderItems.addAll(existing.checklistitems!);
      }

      _reminderTime = existing.reminderTime;
      _noteBlocks = List<NoteBlock>.from(existing.blocks);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  String get _formattedEditedDate {
    final now = DateTime.now();

    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    int hour12 = now.hour % 12;

    if (hour12 == 0) {
      hour12 = 12;
    }

    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    return '$month-$day $hour12:$minute $period';
  }

  // ============================================================
  // REMINDER
  // ============================================================

  Widget _buildReminderEditor(double keyboardHeight) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _reminderItems.length,
            itemBuilder: (context, index) {
              final item = _reminderItems[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: <Widget>[
                    Icon(
                      item.isDone ? Icons.check_circle : Icons.circle_outlined,
                      color: _textColor,
                      size: 22,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(color: _textColor, fontSize: 16),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        setState(() {
                          _reminderItems.removeAt(index);
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: _hintColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // ردیف افزودن آیتم؛ چون resizeToAvoidBottomInset روی این
        // Scaffold غیرفعاله، با AnimatedPadding دستی این ردیف رو
        // بالای کیبورد نگه می‌داریم تا زیرش قایم نشه.
        AnimatedPadding(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: keyboardHeight > 0
                ? keyboardHeight
                : MediaQuery.of(context).padding.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _reminderController,
                    style: const TextStyle(color: _textColor, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Add Item...',
                      hintStyle: TextStyle(color: _hintColor),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addReminderItem(),
                  ),
                ),

                IconButton(
                  onPressed: _addReminderItem,
                  icon: const Icon(Icons.add_circle_outline, color: _textColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addReminderItem() {
    final text = _reminderController.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      _reminderItems.add(ChecklistItem(title: text, isDone: false));
    });

    _reminderController.clear();
  }

  Future<void> _pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null
          ? TimeOfDay.fromDateTime(_reminderTime!)
          : TimeOfDay.now(),
    );

    if (time == null) {
      return;
    }

    final now = DateTime.now();

    setState(() {
      _reminderTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
    });
  }

  Widget _buildReminderTimePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.notifications_none_outlined,
            color: _textColor,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              _reminderTime == null
                  ? 'Set reminder time'
                  : 'Reminder at ${TimeOfDay.fromDateTime(_reminderTime!).format(context)}',
              style: const TextStyle(color: _textColor, fontSize: 15),
            ),
          ),

          TextButton(
            onPressed: _pickReminderTime,
            child: Text(
              _reminderTime == null ? 'Set' : 'Change',
              style: const TextStyle(color: Color(0xFFF5C65D)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  void _saveNote() {
    // اگه کاربر توی تکست‌فیلد آزاد چیزی نوشته ولی هنوز Enter نزده،
    // اول اون رو تبدیل به Block می‌کنیم تا موقع Save گم نشه.
    if (selectedType != NoteType.reminder) {
      _editorKey.currentState?.flushPendingText();
    }

    final existing = widget.existingNote;

    final note = Note(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),

      title: _titleController.text.trim(),

      // Reminder فعلاً از content استفاده می‌کند
      // و بقیه Noteها از blocks.
      content: _contentController.text.trim(),

      type: selectedType,

      folderld: existing?.folderld,

      createdAt: existing?.createdAt ?? DateTime.now(),

      imageUrl: existing?.imageUrl,

      // فقط Reminder
      checklistitems: selectedType == NoteType.reminder
          ? List<ChecklistItem>.from(_reminderItems)
          : null,

      // فقط Reminder
      reminderTime: selectedType == NoteType.reminder ? _reminderTime : null,

      // فقط Noteهای آزاد
      blocks: selectedType == NoteType.reminder
          ? const []
          : List<NoteBlock>.from(_noteBlocks),
    );

    Navigator.pop(context, note);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.darkCardBackground,

      appBar: AppBar(
        backgroundColor: AppColors.darkCardBackground,
        elevation: 0,
        toolbarHeight: 56,

        actions: <Widget>[
          TextButton(
            onPressed: _saveNote,

            child: const Text(
              'Save',
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ],
      ),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // -----------------------------------------------
            // Date + Category
            // -----------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),

              child: Row(
                children: <Widget>[
                  Text(
                    'Edited: $_formattedEditedDate',
                    style: const TextStyle(color: _hintColor, fontSize: 13),
                  ),

                  const Spacer(),

                  _CategoryDropdown(
                    value: selectedType,
                    dotColor: _categoryColor,
                    items: NoteType.values,

                    onChanged: (newValue) {
                      if (newValue == null) {
                        return;
                      }

                      setState(() {
                        selectedType = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),

            // -----------------------------------------------
            // Title
            // -----------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

              child: TextField(
                controller: _titleController,

                style: const TextStyle(
                  color: _textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),

                decoration: const InputDecoration(
                  hintText: 'Title',

                  hintStyle: TextStyle(color: _hintColor, fontSize: 22),

                  border: InputBorder.none,
                ),
              ),
            ),

            // -----------------------------------------------
            // Reminder Time
            // -----------------------------------------------
            if (selectedType == NoteType.reminder) _buildReminderTimePicker(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: _dividerColor, height: 24, thickness: 1),
            ),

            // -----------------------------------------------
            // Main Editor
            // -----------------------------------------------
            Expanded(
              child: selectedType == NoteType.reminder
                  ? _buildReminderEditor(keyboardHeight)
                  : FreeNoteEditor(
                      key: _editorKey,
                      initialBlocks: _noteBlocks,

                      onChanged: (blocks) {
                        setState(() {
                          _noteBlocks = List<NoteBlock>.from(blocks);
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORY DROPDOWN
// ============================================================

class _CategoryDropdown extends StatelessWidget {
  final NoteType value;
  final Color dotColor;
  final List<NoteType> items;
  final ValueChanged<NoteType?> onChanged;

  const _CategoryDropdown({
    required this.value,
    required this.dotColor,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<NoteType>(
        value: value,
        onChanged: onChanged,

        dropdownColor: const Color(0xFF1A1B20),

        borderRadius: BorderRadius.circular(10),

        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF6B7280),
          size: 18,
        ),

        selectedItemBuilder: (context) {
          return items.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,

                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  item.name,

                  style: const TextStyle(
                    color: Color(0xFFE5E7EB),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList();
        },

        items: items.map((item) {
          return DropdownMenuItem<NoteType>(
            value: item,

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 8,
                  height: 8,

                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  item.name,

                  style: const TextStyle(
                    color: Color(0xFFE5E7EB),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
