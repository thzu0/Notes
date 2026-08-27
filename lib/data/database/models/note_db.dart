import 'package:isar/isar.dart';

part 'note_db.g.dart';

enum NoteTypeDb { reminder, checklist, quote, diary, target, image, text }

enum NoteBlockTypeDb { text, checklist, image, quote }

@collection
class NoteDb {
  ///isar خود primary key
  Id id = Isar.autoIncrement;

  /// مدل اصلی برنامه ID
  late String noteId;

  String title = '';

  String content = '';

  @enumerated
  NoteTypeDb type = NoteTypeDb.text;

  String? folderId;

  late DateTime createdAt;

  String? imageUrl;

  bool isPinned = false;
  bool isLocked = false;

  DateTime? reminderTime;

  late List<ChecklistItemDb> checklistItems;

  List<NoteBlockDb> blocks = [];
}

@embedded
class ChecklistItemDb {
  String title = '';

  bool isDone = false;
}

@embedded
class NoteBlockDb {
  @enumerated
  NoteBlockTypeDb type = NoteBlockTypeDb.text;

  String? text;

  String? richTextJson;

  bool? isDone;

  String? imageUrl;

  String? quoteAuthor;
}
