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

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.folderld,
    required this.createdAt,
    required this.imageUrl,
    required List<ChecklistItem> checklistItems,
    List<ChecklistItem>? checklistitems, // پارامتر قدیمی، اختیاری شد
  }) : checklistitems =
           checklistItems; // همیشه دیتای واقعی (checklistItems) ذخیره میشه
}

class ChecklistItem {
  final String title;
  final bool isDone;

  const ChecklistItem({required this.title, this.isDone = false});
}
