import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/note_colors.dart';
import '../../model/model.dart';
import '../../model/model_folder.dart';
import '../widgets/note_card_builder.dart';
import 'create_note_page.dart';

class FolderNotesPage extends StatefulWidget {
  final Folder folder;
  final List<Note> notes;

  final ValueChanged<Note> onNoteCreated;
  final ValueChanged<Note> onNoteUpdated;

  const FolderNotesPage({
    super.key,
    required this.folder,
    required this.notes,
    required this.onNoteCreated,
    required this.onNoteUpdated,
  });

  @override
  State<FolderNotesPage> createState() => _FolderNotesPageState();
}

class _FolderNotesPageState extends State<FolderNotesPage> {
  // ============================================================
  // LOCAL FOLDER NOTES
  // ============================================================

  late List<Note> _folderNotes;

  @override
  void initState() {
    super.initState();

    // فقط نوت‌های متعلق به همین فولدر
    _folderNotes = widget.notes
        .where((note) => note.folderld == widget.folder.id)
        .toList();
  }

  // ============================================================
  // CREATE NOTE
  // ============================================================

  Future<void> _createNote() async {
    final Note? note = await Navigator.of(context).push<Note>(
      MaterialPageRoute(builder: (_) => CreateNotePage(folder: widget.folder)),
    );

    if (note == null) {
      return;
    }

    // اول داخل همین صفحه نمایش بده
    setState(() {
      _folderNotes.add(note);
    });

    // بعد به HomePage اطلاع بده
    widget.onNoteCreated(note);
  }

  // ============================================================
  // EDIT NOTE
  // ============================================================

  Future<void> _editNote(Note note) async {
    final Note? updatedNote = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (_) =>
            CreateNotePage(existingNote: note, folder: widget.folder),
      ),
    );

    if (updatedNote == null) {
      return;
    }

    // پیدا کردن نوت داخل فولدر
    final index = _folderNotes.indexWhere((item) => item.id == updatedNote.id);

    if (index != -1) {
      setState(() {
        _folderNotes[index] = updatedNote;
      });
    }

    // اطلاع به HomePage
    widget.onNoteUpdated(updatedNote);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        title: Row(
          children: [
            Icon(Icons.folder, color: widget.folder.colorValue),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                widget.folder.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPriamry,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: _folderNotes.isEmpty
          ? const Center(
              child: Text(
                'No Notes Yet',
                style: TextStyle(color: AppColors.textSecondery, fontSize: 15),
              ),
            )
          : MasonryGridView.count(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),

              crossAxisCount: 2,

              mainAxisSpacing: 12,
              crossAxisSpacing: 12,

              itemCount: _folderNotes.length,

              itemBuilder: (context, index) {
                final Note note = _folderNotes[index];

                return GestureDetector(
                  onTap: () {
                    _editNote(note);
                  },

                  child: NoteCardBuilder(note: note),
                );
              },
            ),

      // ========================================================
      // FAB
      // ========================================================
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 8),

        child: FloatingActionButton(
          backgroundColor: widget.folder.colorValue,
          shape: const CircleBorder(),

          onPressed: _createNote,

          child: const Icon(Icons.note_add_outlined, color: Colors.white),
        ),
      ),
    );
  }
}
