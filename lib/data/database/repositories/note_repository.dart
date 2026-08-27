import 'package:isar/isar.dart';
import 'package:notes_app/core/note_notification_service.dart';
import 'package:notes_app/data/database/isar_service.dart';
import 'package:notes_app/data/database/models/note_db.dart';
import 'package:notes_app/features/notes/model/model.dart';

class NoteRepository {
  final Isar _isar;

  NoteRepository({Isar? isar}) : _isar = isar ?? IsarService.instance;

  // ============================================================
  // CREATE
  // ============================================================
  Future<void> saveNote(Note note) async {
    final noteDb = _toDb(note);

    await _isar.writeTxn(() async {
      await _isar.noteDbs.put(noteDb);
    });

    if (note.type == NoteType.reminder && note.reminderTime != null) {
      await NotificationService.instance.scheduleReminder(
        noteId: note.id,
        title: note.title,
        body: _buildReminderBody(note),
        scheduledTime: note.reminderTime!,
      );
    }
  }

  // ============================================================
  // READ - ALL
  // ============================================================

  Future<List<Note>> getNotes() async {
    final notesDb = await _isar.noteDbs.where().findAll();
    return notesDb.map(_fromDb).toList();
  }

  // ============================================================
  // READ - ONE
  // ============================================================

  Future<Note?> getNoteById(String noteId) async {
    final noteDb = await _isar.noteDbs
        .filter()
        .noteIdEqualTo(noteId)
        .findFirst();

    if (noteDb == null) {
      return null;
    }

    return _fromDb(noteDb);
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updateNote(Note note) async {
    final existingNoteDb = await _isar.noteDbs
        .filter()
        .noteIdEqualTo(note.id)
        .findFirst();

    if (existingNoteDb == null) {
      throw Exception('Note not found: ${note.id}');
    }

    final updateNoteDb = _toDb(note);

    // حفظ ID داخلی Isar
    updateNoteDb.id = existingNoteDb.id;

    await _isar.writeTxn(() async {
      await _isar.noteDbs.put(updateNoteDb);
    });

    // حذف Notification قبلی
    await NotificationService.instance.cancelReminder(note.id);

    // اگر هنوز Reminder است و زمان دارد،
    // Notification جدید با محتوای جدید بساز
    if (note.type == NoteType.reminder && note.reminderTime != null) {
      await NotificationService.instance.scheduleReminder(
        noteId: note.id,
        title: note.title,
        body: _buildReminderBody(note),
        scheduledTime: note.reminderTime!,
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================
  Future<void> deleteNote(String noteId) async {
    final noteDb = await _isar.noteDbs
        .filter()
        .noteIdEqualTo(noteId)
        .findFirst();

    if (noteDb == null) {
      return;
    }

    // اول Notification را حذف می‌کنیم.
    await NotificationService.instance.cancelReminder(noteId);

    await _isar.writeTxn(() async {
      await _isar.noteDbs.delete(noteDb.id);
    });
  }

  // ============================================================
  // FOR SHOW ALL TASK IN REMINDER NOTIF
  // ============================================================
  String _buildReminderBody(Note note) {
    final List<String> parts = [];

    // متن اصلی نوت
    if (note.content.trim().isNotEmpty) {
      parts.add(note.content.trim());
    }

    // Checklist
    final items = note.checklistitems ?? [];

    for (final item in items) {
      if (item.title.trim().isNotEmpty) {
        parts.add('• ${item.title.trim()}');
      }
    }

    // اگر هیچ محتوایی نداشت
    if (parts.isEmpty) {
      return 'You have a reminder';
    }

    return parts.join('\n');
  }

  // ============================================================
  // NOTE → NOTE DB
  // ============================================================

  NoteDb _toDb(Note note) {
    return NoteDb()
      ..noteId = note.id
      ..title = note.title
      ..content = note.content
      ..type = _noteTypeToDb(note.type)
      ..folderId = note.folderld
      ..createdAt = note.createdAt
      ..imageUrl = note.imageUrl
      ..isPinned = note.isPinned
      ..isLocked = note.isLocked
      ..reminderTime = note.reminderTime
      ..checklistItems = (note.checklistitems ?? [])
          .map(
            (item) => ChecklistItemDb()
              ..title = item.title
              ..isDone = item.isDone,
          )
          .toList()
      ..blocks = note.blocks
          .map(
            (block) => NoteBlockDb()
              ..type = _blockTypeToDb(block.type)
              ..text = block.text
              ..richTextJson = block.richTextJson
              ..isDone = block.isDone
              ..imageUrl = block.imageUrl
              ..quoteAuthor = block.quoteAuthor,
          )
          .toList();
  }
  // ============================================================
  // NOTE DB → NOTE
  // ============================================================

  Note _fromDb(NoteDb noteDb) {
    return Note(
      id: noteDb.noteId,
      title: noteDb.title,
      content: noteDb.content,
      type: _noteTypeFromDb(noteDb.type),
      folderld: noteDb.folderId,
      createdAt: noteDb.createdAt,
      imageUrl: noteDb.imageUrl,
      isPinned: noteDb.isPinned,
      isLocked: noteDb.isLocked,
      reminderTime: noteDb.reminderTime,
      checklistitems: noteDb.checklistItems
          .map((item) => ChecklistItem(title: item.title, isDone: item.isDone))
          .toList(),
      blocks: noteDb.blocks
          .map(
            (block) => NoteBlock(
              type: _blockTypeFromDb(block.type),
              text: block.text,
              richTextJson: block.richTextJson,
              isDone: block.isDone,
              imageUrl: block.imageUrl,
              quoteAuthor: block.quoteAuthor,
            ),
          )
          .toList(),
    );
  }
  // ============================================================
  // NOTE TYPE MAPPING
  // ============================================================

  NoteTypeDb _noteTypeToDb(NoteType type) {
    switch (type) {
      case NoteType.reminder:
        return NoteTypeDb.reminder;

      case NoteType.cheklist:
        return NoteTypeDb.checklist;

      case NoteType.quote:
        return NoteTypeDb.quote;

      case NoteType.diary:
        return NoteTypeDb.diary;

      case NoteType.target:
        return NoteTypeDb.target;

      case NoteType.image:
        return NoteTypeDb.image;

      case NoteType.text:
        return NoteTypeDb.text;
    }
  }

  NoteType _noteTypeFromDb(NoteTypeDb type) {
    switch (type) {
      case NoteTypeDb.reminder:
        return NoteType.reminder;

      case NoteTypeDb.checklist:
        return NoteType.cheklist;

      case NoteTypeDb.quote:
        return NoteType.quote;

      case NoteTypeDb.diary:
        return NoteType.diary;

      case NoteTypeDb.target:
        return NoteType.target;

      case NoteTypeDb.image:
        return NoteType.image;

      case NoteTypeDb.text:
        return NoteType.text;
    }
  }

  // ============================================================
  // BLOCK TYPE MAPPING
  // ============================================================

  NoteBlockTypeDb _blockTypeToDb(NoteBlockType type) {
    switch (type) {
      case NoteBlockType.text:
        return NoteBlockTypeDb.text;

      case NoteBlockType.checklist:
        return NoteBlockTypeDb.checklist;

      case NoteBlockType.image:
        return NoteBlockTypeDb.image;

      case NoteBlockType.quote:
        return NoteBlockTypeDb.quote;
    }
  }

  NoteBlockType _blockTypeFromDb(NoteBlockTypeDb type) {
    switch (type) {
      case NoteBlockTypeDb.text:
        return NoteBlockType.text;

      case NoteBlockTypeDb.checklist:
        return NoteBlockType.checklist;

      case NoteBlockTypeDb.image:
        return NoteBlockType.image;

      case NoteBlockTypeDb.quote:
        return NoteBlockType.quote;
    }
  }
}
