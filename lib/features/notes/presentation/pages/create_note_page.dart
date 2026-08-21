import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/features/notes/presentation/widgets/format_bottom_sheet.dart';

/// صفحه‌ای که با کلیک روی FAB باز میشه.
/// آیکون‌های بالای اپ‌بار (بازگشت، پین، اشتراک‌گذاری، سه‌نقطه) عمداً خالی گذاشته شدن
/// چون قراره خودت اضافه‌شون کنی.
class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // فقط برای نمایش، بعداً می‌تونی از یه enum/مدل واقعی برای دسته‌بندی استفاده کنی
  String _category = 'reminder';
  final Color _categoryColor = const Color(0xFFF5A623);

  static const Color _hintColor = Color(0xFF6B7280);
  static const Color _textColor = Color(0xFFE5E7EB);
  static const Color _dividerColor = Color(0xFF23252B);

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String get _formattedEditedDate {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    int hour12 = now.hour % 12;
    if (hour12 == 0) hour12 = 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$month-$day $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    // ارتفاع فعلی کیبورد (وقتی بسته‌ست صفره)
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      // چون تو edge-to-edge اندروید 15 رفتار خودکار Scaffold برای جابجایی
      // bottomNavigationBar همیشه درست کار نمی‌کنه، این رو false می‌ذاریم
      // و خودمون دستی با keyboardHeight پایین‌تر مدیریتش می‌کنیم
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.darkCardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkCardBackground,
        elevation: 0,
        toolbarHeight: 56,

        // TODO: آیکون‌های بازگشت / پین / اشتراک‌گذاری / سه‌نقطه رو خودت اینجا اضافه کن
        title: const Text('New Note', style: NoteTextStyle.headingTitleApp),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: Icon(Icons.edit_note)),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        // پایین رو خودمون با AnimatedPadding پایین‌تر مدیریت می‌کنیم
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Edited: $_formattedEditedDate',
                    style: const TextStyle(color: _hintColor, fontSize: 13),
                  ),
                  const Spacer(),
                  _CategoryDropdown(
                    value: _category,
                    dotColor: _categoryColor,
                    items: const [
                      'reminder',
                      'quote',
                      'diary',
                      'target',
                      'text',
                      'image',
                      'checklist',
                    ],
                    onChanged: (newValue) {
                      if (newValue == null) return;
                      setState(() => _category = newValue);
                    },
                  ),
                ],
              ),
            ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: _dividerColor, height: 24, thickness: 1),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(color: _textColor, fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Please enter content here...',
                    hintStyle: TextStyle(color: _hintColor, fontSize: 16),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // نوار پایین دیگه bottomNavigationBar نیست؛ داخل خودِ body ِه
            // AnimatedPadding با تغییر keyboardHeight خودش به‌آرومی بالا/پایین میره
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
                color: AppColors.darkCardBackground,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: _textColor,
                      ),
                      onPressed: () {
                        // TODO: افزودن تصویر
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.text_fields_rounded,
                        color: _textColor,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => const FormatBottomSheet(),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.palette_outlined,
                        color: _textColor,
                      ),
                      onPressed: () {
                        // TODO: انتخاب رنگ/تم یادداشت
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// دراپ‌دان واقعی برای انتخاب دسته‌بندی یادداشت.
/// هر آیتم یک نقطه‌ی رنگی + متن داره (مشابه چیزی که توی تصویر بود).
class _CategoryDropdown extends StatelessWidget {
  final String value;
  final Color dotColor;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.value,
    required this.dotColor,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF1A1B20),
        borderRadius: BorderRadius.circular(10),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF6B7280),
          size: 18,
        ),
        // چیزی که وقتی دراپ‌دان بسته‌ست نشون داده میشه (نقطه رنگی + متن انتخاب‌شده)
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  item,
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
        // آیتم‌های داخل منوی باز شده
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  item,
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
