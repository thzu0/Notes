import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController _noteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Note', style: NoteTextStyle.headingTitleApp),
        actions: <Widget>[
          TextButton(
            onPressed: () {},
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: const Text('Save', style: NoteTextStyle.tabInactive),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: DropdownButtonFormField<String>(
              focusColor: AppColors.darkCardBackground,
              decoration: InputDecoration(
                hintText: 'Select a lesson',
                hintStyle: NoteTextStyle.bodyRegular,

                prefixIcon: Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),

                suffixIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 24,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.textMuted.withValues(alpha: 0.25),
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.textMuted.withValues(alpha: 0.25),
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.primaryPurple.withValues(alpha: 0.5),
                  ),
                ),

                filled: true,
                fillColor: AppColors.darkCardBackground,
              ),

              // فلش پیش‌فرض Dropdown رو حذف می‌کنیم
              icon: const SizedBox.shrink(),

              dropdownColor: AppColors.darkCardBackground,

              items: const [
                DropdownMenuItem(
                  value: 'reminder',
                  child: Text('Reminder', style: NoteTextStyle.bodyMedium),
                ),
                DropdownMenuItem(
                  value: 'checkList',
                  child: Text('CheckList', style: NoteTextStyle.bodyMedium),
                ),
                DropdownMenuItem(
                  value: 'quote',
                  child: Text('Quote', style: NoteTextStyle.bodyMedium),
                ),
                DropdownMenuItem(
                  value: 'diary',
                  child: Text('Diary', style: NoteTextStyle.bodyMedium),
                ),
                DropdownMenuItem(
                  value: 'target',
                  child: Text('Target', style: NoteTextStyle.bodyMedium),
                ),
                DropdownMenuItem(
                  value: 'image',
                  child: Text('Image', style: NoteTextStyle.bodyMedium),
                ),
                DropdownMenuItem(
                  value: 'text',
                  child: Text('Text', style: NoteTextStyle.bodyMedium),
                ),
              ],

              onChanged: (value) {
                // selected lesson
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkCardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryPurple),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ۱. نوار ابزار بالا + شمارش‌گر زنده کاراکتر
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'B',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'I',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                fontFamily: 'Serif',
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              '<>',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondery,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.format_list_bulleted,
                              size: 20,
                              color: AppColors.textSecondery,
                            ),
                            SizedBox(width: 16),
                            Text(
                              'H',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // شمارش تعداد کاراکترها بر اساس کنترلر شما
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _noteController,
                          builder: (context, value, child) {
                            return Text(
                              '${value.text.length} chars',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: Colors.transparent),
                  SizedBox(height: 13),

                  // ۲. فیلد متنی اصلی
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _noteController,
                      maxLines:
                          19, // تعداد خطوط فیلد (بسته به نیاز کم یا زیادش کنید)
                      decoration: InputDecoration(
                        hintText:
                            'Write your note here...\n\nTip: Use toolbar for formatting',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          height: 1.4,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Text(
              'Tags',
              style: TextStyle(fontSize: 20, color: AppColors.textPriamry),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 5, 0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a tag',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      // تنظیمات حاشیه (Border) برای حالت عادی
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primaryPurple),
                      ),
                      // تنظیمات حاشیه برای زمانی که روی آن کلیک شده (فوکوس)
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6E62FF),
                        ), // رنگ بنفش دکمه
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 16, 0),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurpleLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: const Icon(
                        Icons.add,
                        color: AppColors.textPriamry,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
