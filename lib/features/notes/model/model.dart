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
  final bool isPinned;
  final bool isLocked;

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
    this.isPinned = false,
    this.isLocked = false,
  });
}

class ChecklistItem {
  final String title;
  final bool isDone;

  const ChecklistItem({required this.title, this.isDone = false});
}

enum NoteBlockType { text, checklist, image, quote }

/// هر Text Block می‌تواند یک Document کامل Fleather داشته باشد.
///
/// richTextJson شامل JSON مربوط به ParchmentDocument است.
/// بنابراین مثلاً:
///
/// Hello
///     ↑ Bold
///
/// و:
///
/// world
///     ↑ Italic
///
/// هر دو در یک Block ذخیره می‌شوند.
class NoteBlock {
  final NoteBlockType type;

  /// متن ساده برای استفاده‌های قدیمی / preview ساده.
  final String? text;

  /// JSON سند Rich Text مربوط به Fleather.
  final String? richTextJson;

  final bool? isDone;
  final String? imageUrl;
  final String? quoteAuthor;

  const NoteBlock({
    required this.type,
    this.text,
    this.richTextJson,
    this.isDone,
    this.imageUrl,
    this.quoteAuthor,
  });
}
