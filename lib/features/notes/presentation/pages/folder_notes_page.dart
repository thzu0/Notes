import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/note_colors.dart';
import '../../../../data/database/repositories/note_repository.dart';
import '../../model/model.dart';
import '../../model/model_folder.dart';
import '../widgets/note_card_builder.dart';
import 'create_note_page.dart';

class FolderNotesPage extends StatefulWidget {
  final Folder folder;
  final List<Note> notes;

  final Future<void> Function(Note note) onNoteCreated;
  final Future<void> Function(Note note) onNoteUpdated;
  final Future<void> Function(String noteId) onNoteDeleted;

  const FolderNotesPage({
    super.key,
    required this.folder,
    required this.notes,
    required this.onNoteCreated,
    required this.onNoteUpdated,
    required this.onNoteDeleted,
  });

  @override
  State<FolderNotesPage> createState() => _FolderNotesPageState();
}

class _FolderNotesPageState extends State<FolderNotesPage> {
  // ============================================================
  // DATA
  // ============================================================

  late List<Note> _folderNotes;

  final NoteRepository _noteRepository = NoteRepository();

  // برای انتخاب چند Note
  final Set<String> _selectedNoteIds = {};

  bool _isSelectionMode = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _folderNotes = widget.notes
        .where((note) => note.folderld == widget.folder.id)
        .toList();
  }

  // ============================================================
  // SELECTION MODE
  // ============================================================
  void _enterSelectionMode(String noteId) {
    setState(() {
      _isSelectionMode = true;
      _selectedNoteIds.add(noteId);
    });
  }

  void _toggleNoteSelection(String noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
      } else {
        _selectedNoteIds.add(noteId);
      }

      if (_selectedNoteIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _cancelSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNoteIds.clear();
    });
  }

  Future<void> _deleteSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) return;

    final count = _selectedNoteIds.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Text('Delete Notes'),
          content: Text(
            'Are you sure you want to delete '
            '$count note${count == 1 ? '' : 's'}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.15),
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final selectedIds = Set<String>.from(_selectedNoteIds);

    for (final noteId in selectedIds) {
      await _noteRepository.deleteNote(noteId);
      await widget.onNoteDeleted(noteId);
    }

    if (!mounted) return;

    setState(() {
      _folderNotes.removeWhere((note) => selectedIds.contains(note.id));

      _selectedNoteIds.clear();
      _isSelectionMode = false;
    });
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

    // نمایش داخل همین Folder
    setState(() {
      _folderNotes.add(note);
    });

    // اطلاع به HomePage
    await widget.onNoteCreated(note);
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

    final index = _folderNotes.indexWhere((item) => item.id == updatedNote.id);

    if (index != -1) {
      setState(() {
        _folderNotes[index] = updatedNote;
      });
    }

    await widget.onNoteUpdated(updatedNote);
  }

  // ============================================================
  // SHOW ADD EXISTING NOTES
  // ============================================================

  Future<void> _showAddExistingNotes() async {
    final availableNotes = widget.notes
        .where((note) => note.folderld != widget.folder.id)
        .toList();

    if (availableNotes.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other notes available.')),
      );

      return;
    }

    final Set<String> tempSelectedIds = Set<String>.from(_selectedNoteIds);

    final bool? shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),

              title: const Text('Add Notes'),

              content: SizedBox(
                width: 360,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableNotes.length,
                  itemBuilder: (context, index) {
                    final note = availableNotes[index];

                    final bool isSelected = tempSelectedIds.contains(note.id);

                    return CheckboxListTile(
                      value: isSelected,

                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            tempSelectedIds.add(note.id);
                          } else {
                            tempSelectedIds.remove(note.id);
                          }
                        });
                      },

                      title: Text(
                        note.title.isEmpty ? 'Untitled Note' : note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      subtitle: Text(
                        note.type.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),

                TextButton(
                  onPressed: tempSelectedIds.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).pop(true);
                        },
                  child: Text(
                    tempSelectedIds.isEmpty
                        ? 'Add'
                        : 'Add (${tempSelectedIds.length})',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldAdd != true || tempSelectedIds.isEmpty) {
      return;
    }

    await _addSelectedNotes(tempSelectedIds);
  }

  // ============================================================
  // ADD SELECTED NOTES TO CURRENT FOLDER
  // ============================================================

  Future<void> _addSelectedNotes(Set<String> selectedIds) async {
    final selectedNotes = widget.notes
        .where((note) => selectedIds.contains(note.id))
        .toList();

    final List<Note> updatedNotes = [];

    for (final note in selectedNotes) {
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        type: note.type,
        folderld: widget.folder.id,
        createdAt: note.createdAt,
        imageUrl: note.imageUrl,
        checklistitems: note.checklistitems,
        reminderTime: note.reminderTime,
        blocks: note.blocks,
      );

      await _noteRepository.updateNote(updatedNote);

      await widget.onNoteUpdated(updatedNote);

      updatedNotes.add(updatedNote);
    }

    if (!mounted) return;

    setState(() {
      for (final updatedNote in updatedNotes) {
        final index = _folderNotes.indexWhere(
          (note) => note.id == updatedNote.id,
        );

        if (index == -1) {
          _folderNotes.add(updatedNote);
        } else {
          _folderNotes[index] = updatedNote;
        }
      }

      _selectedNoteIds.clear();
    });

    if (updatedNotes.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${updatedNotes.length} note'
            '${updatedNotes.length == 1 ? '' : 's'} '
            'added to ${widget.folder.name}',
          ),
        ),
      );
    }
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

        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelSelectionMode,
              )
            : null,

        title: _isSelectionMode
            ? Text('${_selectedNoteIds.length} selected')
            : Row(
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

        actions: _isSelectionMode
            ? [
                IconButton(
                  onPressed: _deleteSelectedNotes,
                  icon: const Icon(Icons.delete_outline, size: 28),
                ),
              ]
            : [
                IconButton(
                  onPressed: _showAddExistingNotes,
                  tooltip: 'Add existing note',
                  icon: const Icon(
                    Icons.add,
                    size: 26,
                    color: AppColors.textPriamry,
                  ),
                ),
              ],
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
                final bool isSelected = _selectedNoteIds.contains(note.id);

                return GestureDetector(
                  onLongPress: () {
                    if (!_isSelectionMode) {
                      _enterSelectionMode(note.id);
                    }
                  },

                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleNoteSelection(note.id);
                      return;
                    }

                    _editNote(note);
                  },

                  child: Stack(
                    children: [
                      NoteCardBuilder(note: note),

                      if (isSelected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5C65D),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 19,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
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
