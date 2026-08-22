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

class NoteBlock {
  final NoteBlockType type;

  final String? text;
  final bool? isDone;
  final String? imageUrl;
  final String? quoteAuthor;

  const NoteBlock({
    required this.type,
    this.text,
    this.isDone,
    this.imageUrl,
    this.quoteAuthor,
  });
}
