import 'package:flutter/material.dart';

enum NoteType { reminder, cheklist, quote, diary, target, image, text }

class Note {
  final String id;
  final String title;
  final String content;
  final NoteType type;
  final String? folderld;
  final DateTime createdAt;
  final String? imageUrl;
  final List<ChecklistItem>? checklistitems;
  final DateTime? reminderTime;
  final List<NoteBlock> blocks;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.folderld,
    required this.createdAt,
    required this.imageUrl,

    this.checklistitems,
    this.reminderTime,
    this.blocks = const [],
  });
}

class ChecklistItem {
  final String title;
  final bool isDone;

  const ChecklistItem({required this.title, this.isDone = false});
}

enum NoteBlockType { text, checklist, image, quote }

/// نوع هدینگ برای بلاک‌های متنی. none یعنی همون متن عادی (TXT).
enum HeadingType { heading1, heading2, none }

/// تنظیمات فرمت‌بندی که از FormatBottomSheet انتخاب می‌شه و
/// روی یه بلاک متنی اعمال می‌شه.
class TextFormatStyle {
  final HeadingType heading;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isBulletList;
  final bool isNumberedList;
  final Color textColor;
  final Color? highlightColor;

  const TextFormatStyle({
    this.heading = HeadingType.none,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isBulletList = false,
    this.isNumberedList = false,
    this.textColor = Colors.white,
    this.highlightColor,
  });

  TextFormatStyle copyWith({
    HeadingType? heading,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    bool? isBulletList,
    bool? isNumberedList,
    Color? textColor,
    Color? highlightColor,
    bool clearHighlight = false,
  }) {
    return TextFormatStyle(
      heading: heading ?? this.heading,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      isBulletList: isBulletList ?? this.isBulletList,
      isNumberedList: isNumberedList ?? this.isNumberedList,
      textColor: textColor ?? this.textColor,
      highlightColor: clearHighlight
          ? null
          : (highlightColor ?? this.highlightColor),
    );
  }
}

class NoteBlock {
  final NoteBlockType type;

  final String? text;
  final bool? isDone;
  final String? imageUrl;
  final String? quoteAuthor;
  final TextFormatStyle? format;

  const NoteBlock({
    required this.type,
    this.text,
    this.isDone,
    this.imageUrl,
    this.quoteAuthor,
    this.format,
  });
}
