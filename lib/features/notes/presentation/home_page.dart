import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/data/database/repositories/folder_repository.dart';
import 'package:notes_app/data/database/repositories/note_repository.dart';

import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/model/model_folder.dart';

import 'package:notes_app/features/notes/presentation/pages/Create_folder_bottom_sheet.dart.dart';
import 'package:notes_app/features/notes/presentation/pages/about_us_page.dart';
import 'package:notes_app/features/notes/presentation/pages/create_note_page.dart';
import 'package:notes_app/features/notes/presentation/pages/feedback_page.dart';
import 'package:notes_app/features/notes/presentation/pages/folder_notes_page.dart';
import 'package:notes_app/features/notes/presentation/pages/search_page.dart';

import 'package:notes_app/features/notes/presentation/widgets/folder_card_builder.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_card_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // DATA
  // ============================================================

  final List<Note> notes = [];
  final List<Folder> folders = [];

  final NoteRepository _noteRepository = NoteRepository();
  final FolderRepository _folderRepository = FolderRepository();

  late TabController _tabController;

  // ============================================================
  // NOTE SELECTION
  // ============================================================

  bool _isSelectionMode = false;

  final Set<String> _selectedNoteIds = {};

  // ============================================================
  // TAB
  // ============================================================

  void onTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(onTabChanged);

    _loadNotes();
    _loadFolders();
  }

  // ============================================================
  // LOAD NOTES
  // ============================================================

  Future<void> _loadNotes() async {
    final savedNotes = await _noteRepository.getNotes();

    if (!mounted) return;

    setState(() {
      notes.clear();
      notes.addAll(savedNotes);
    });
  }

  // ============================================================
  // LOAD FOLDERS
  // ============================================================

  Future<void> _loadFolders() async {
    final savedFolders = await _folderRepository.getFolders();

    if (!mounted) return;

    setState(() {
      folders.clear();
      folders.addAll(savedFolders);
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _tabController.removeListener(onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // NOTE SELECTION MODE
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

  // ============================================================
  // DELETE SELECTED NOTES
  // ============================================================

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
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                foregroundColor: AppColors.textMuted,
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
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
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final selectedIds = Set<String>.from(_selectedNoteIds);

    for (final noteId in selectedIds) {
      await _noteRepository.deleteNote(noteId);
    }

    if (!mounted) return;

    setState(() {
      notes.removeWhere((note) => selectedIds.contains(note.id));

      _selectedNoteIds.clear();
      _isSelectionMode = false;
    });
  }

  // ============================================================
  // REMINDER CHECKLIST
  // ============================================================

  Future<void> _updateReminderItem(
    String noteId,
    int itemIndex,
    bool value,
  ) async {
    final noteIndex = notes.indexWhere((note) => note.id == noteId);

    if (noteIndex == -1) return;

    final note = notes[noteIndex];

    final items = List<ChecklistItem>.from(note.checklistitems ?? []);

    if (itemIndex >= items.length) return;

    items[itemIndex] = ChecklistItem(
      title: items[itemIndex].title,
      isDone: value,
    );

    final updatedNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      type: note.type,
      folderld: note.folderld,
      createdAt: note.createdAt,
      imageUrl: note.imageUrl,
      checklistitems: items,
      reminderTime: note.reminderTime,
      blocks: note.blocks,
    );

    await _noteRepository.updateNote(updatedNote);

    if (!mounted) return;

    setState(() {
      notes[noteIndex] = updatedNote;
    });
  }

  // ============================================================
  // BLOCK CHECKLIST
  // ============================================================

  Future<void> _updateBlockChecklistItem(
    String noteId,
    int blockIndex,
    bool value,
  ) async {
    final noteIndex = notes.indexWhere((note) => note.id == noteId);

    if (noteIndex == -1) return;

    final note = notes[noteIndex];

    final blocks = List<NoteBlock>.from(note.blocks);

    if (blockIndex >= blocks.length) return;

    final block = blocks[blockIndex];

    blocks[blockIndex] = NoteBlock(
      type: block.type,
      text: block.text,
      richTextJson: block.richTextJson,
      isDone: value,
      imageUrl: block.imageUrl,
      quoteAuthor: block.quoteAuthor,
    );

    final updatedNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      type: note.type,
      folderld: note.folderld,
      createdAt: note.createdAt,
      imageUrl: note.imageUrl,
      checklistitems: note.checklistitems,
      reminderTime: note.reminderTime,
      blocks: blocks,
    );

    await _noteRepository.updateNote(updatedNote);

    if (!mounted) return;

    setState(() {
      notes[noteIndex] = updatedNote;
    });
  }

  // ============================================================
  // EDIT NOTE
  // ============================================================

  Future<void> _editNote(Note note) async {
    final Note? updatedNote = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (context) => CreateNotePage(existingNote: note),
      ),
    );

    if (updatedNote == null) return;

    final noteIndex = notes.indexWhere((n) => n.id == note.id);

    if (noteIndex == -1) return;

    await _noteRepository.updateNote(updatedNote);

    if (!mounted) return;

    setState(() {
      notes[noteIndex] = updatedNote;
    });
  }

  // ============================================================
  // CREATE FOLDER
  // ============================================================

  Future<void> _createFolder() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return const CreateFolderBottomSheet();
      },
    );

    if (result == null) return;

    final String name = result['name'] as String;
    final Color color = result['color'] as Color;

    final Folder newFolder = Folder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      colorValue: color,
    );

    await _folderRepository.saveFolder(newFolder);

    if (!mounted) return;

    setState(() {
      folders.add(newFolder);
    });
  }

  // ============================================================
  // DELETE FOLDER
  // ============================================================

  Future<void> _showFolderActions(Folder folder) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final noteCount = notes
            .where((note) => note.folderld == folder.id)
            .length;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.darkCardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Icon(Icons.folder, color: folder.colorValue, size: 42),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            folder.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPriamry,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '$noteCount '
                            '${noteCount == 1 ? 'note' : 'notes'}',
                            style: const TextStyle(
                              color: AppColors.textSecondery,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Divider(color: Color(0xFF2A2D35), height: 1),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 26,
                  ),
                  title: const Text(
                    'Delete Folder',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop('delete');
                  },
                ),

                const Divider(color: Color(0xFF2A2D35), height: 1),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.close,
                    color: AppColors.textPriamry,
                    size: 26,
                  ),
                  title: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textPriamry,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop('cancel');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == 'delete') {
      await _confirmDeleteFolder(folder);
    }
  }

  // ============================================================
  // CONFIRM DELETE FOLDER
  // ============================================================

  Future<void> _confirmDeleteFolder(Folder folder) async {
    final noteCount = notes.where((note) => note.folderld == folder.id).length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text('Delete "${folder.name}"?'),
          content: Text(
            noteCount == 0
                ? 'This folder will be permanently deleted.'
                : 'The folder will be deleted, but the '
                      '$noteCount '
                      '${noteCount == 1 ? 'note' : 'notes'} '
                      'inside it will not be deleted.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(width: 8),

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
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _deleteFolder(folder);
  }

  // ============================================================
  // DELETE FOLDER FROM DATABASE
  // ============================================================

  Future<void> _deleteFolder(Folder folder) async {
    final affectedNotes = notes
        .where((note) => note.folderld == folder.id)
        .toList();

    // ----------------------------------------------------------
    // Remove folder relation from notes
    // ----------------------------------------------------------

    for (final note in affectedNotes) {
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        type: note.type,
        folderld: null,
        createdAt: note.createdAt,
        imageUrl: note.imageUrl,
        checklistitems: note.checklistitems,
        reminderTime: note.reminderTime,
        blocks: note.blocks,
      );

      await _noteRepository.updateNote(updatedNote);

      final noteIndex = notes.indexWhere((item) => item.id == note.id);

      if (noteIndex != -1) {
        notes[noteIndex] = updatedNote;
      }
    }

    // ----------------------------------------------------------
    // Delete folder from Isar
    // ----------------------------------------------------------

    await _folderRepository.deleteFolder(folder.id);

    if (!mounted) return;

    setState(() {
      folders.removeWhere((item) => item.id == folder.id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${folder.name}" deleted')));
  }

  // ============================================================
  // FOLDER TAP
  // ============================================================

  void _openFolder(Folder folder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FolderNotesPage(
          folder: folder,
          notes: notes,

          // ====================================================
          // CREATE NOTE INSIDE FOLDER
          // ====================================================
          onNoteCreated: (note) async {
            await _noteRepository.saveNote(note);

            if (!mounted) return;

            setState(() {
              notes.add(note);
            });
          },

          // ====================================================
          // UPDATE NOTE INSIDE FOLDER
          // ====================================================
          onNoteUpdated: (updatedNote) async {
            await _noteRepository.updateNote(updatedNote);

            if (!mounted) return;

            final index = notes.indexWhere((note) => note.id == updatedNote.id);

            if (index == -1) return;

            setState(() {
              notes[index] = updatedNote;
            });
          },

          // ====================================================
          // DELETE NOTE INSIDE FOLDER
          // ====================================================
          onNoteDeleted: (noteId) async {
            final index = notes.indexWhere((note) => note.id == noteId);

            if (index == -1) return;

            setState(() {
              notes.removeAt(index);
            });
          },
        ),
      ),
    );
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
        automaticallyImplyLeading: false,

        title: _isSelectionMode
            ? Text('${_selectedNoteIds.length} selected')
            : const Text('Notes'),

        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelSelectionMode,
              )
            : null,

        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 28,
                  onPressed: _deleteSelectedNotes,
                ),
              ]
            : [
                IconButton(
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (value) => SearchPage(notes: notes),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search, size: 30),
                ),

                PopupMenuButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert_outlined),
                  iconSize: 30,
                  iconColor: AppColors.textMuted,
                  menuPadding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'feedback',
                      child: const Text('FeedBack'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const FeedbackPage(),
                          ),
                        );
                      },
                    ),

                    PopupMenuItem(
                      value: 'about us',
                      child: const Text('About Us'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AboutUsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],

        // ========================================================
        // TAB BAR
        // ========================================================
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(75),

          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 20),

              child: Container(
                color: Colors.white.withValues(alpha: 0),

                child: Padding(
                  padding: const EdgeInsets.only(top: 10),

                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicatorColor: const Color(0xFFF5C65D),
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,

                    labelColor: const Color(0xFFF5C65D),

                    unselectedLabelColor: Colors.grey,

                    labelStyle: NoteTextStyle.tabActive,

                    unselectedLabelStyle: NoteTextStyle.tabInactive,

                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Folder'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,

          children: [
            // ====================================================
            // ALL NOTES
            // ====================================================
            AllNotesView(
              notes: notes,

              onReminderItemChanged: _updateReminderItem,

              onBlockChecklistChanged: _updateBlockChecklistItem,

              onNoteTap: _editNote,

              onNoteLongPress: _enterSelectionMode,

              onNoteSelect: _toggleNoteSelection,

              isSelectionMode: _isSelectionMode,

              selectedNoteIds: _selectedNoteIds,
            ),

            // ====================================================
            // FOLDERS
            // ====================================================
            FolderView(
              folders: folders,
              onFolderTap: _openFolder,
              onFolderLongPress: _showFolderActions,
            ),
          ],
        ),
      ),

      // ========================================================
      // FAB
      // ========================================================
      floatingActionButton: _isSelectionMode
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 30, right: 8),
              child: FloatingActionButton(
                shape: const CircleBorder(),

                onPressed: () async {
                  // ==========================================
                  // ALL TAB
                  // ==========================================

                  if (_tabController.index == 0) {
                    final Note? newNote = await Navigator.of(context)
                        .push<Note>(
                          MaterialPageRoute(
                            builder: (_) => const CreateNotePage(),
                          ),
                        );

                    if (newNote != null) {
                      await _noteRepository.saveNote(newNote);

                      if (!mounted) return;

                      setState(() {
                        notes.add(newNote);
                      });
                    }

                    return;
                  }

                  // ==========================================
                  // FOLDER TAB
                  // ==========================================

                  await _createFolder();
                },

                child: Icon(
                  _tabController.index == 0
                      ? Icons.note_add_outlined
                      : Icons.create_new_folder_outlined,
                ),
              ),
            ),
    );
  }
}

// ==================================================================
// ALL NOTES VIEW
// ==================================================================

class AllNotesView extends StatelessWidget {
  final List<Note> notes;

  final Future<void> Function(String noteId, int itemIndex, bool value)?
  onReminderItemChanged;

  final Future<void> Function(String noteId, int blockIndex, bool value)?
  onBlockChecklistChanged;

  final void Function(Note note)? onNoteTap;

  final void Function(String noteId)? onNoteLongPress;

  final void Function(String noteId)? onNoteSelect;

  final bool isSelectionMode;

  final Set<String> selectedNoteIds;

  const AllNotesView({
    super.key,
    required this.notes,
    this.onReminderItemChanged,
    this.onBlockChecklistChanged,
    this.onNoteTap,
    this.onNoteLongPress,
    this.onNoteSelect,
    this.isSelectionMode = false,
    this.selectedNoteIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(child: Text('No Notes Yet'));
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),

      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,

      itemCount: notes.length,

      itemBuilder: (context, index) {
        final Note note = notes[index];

        final bool isSelected = selectedNoteIds.contains(note.id);

        return GestureDetector(
          onLongPress: () {
            if (!isSelectionMode) {
              onNoteLongPress?.call(note.id);
            }
          },

          onTap: () {
            if (isSelectionMode) {
              onNoteSelect?.call(note.id);
              return;
            }

            onNoteTap?.call(note);
          },

          child: Stack(
            children: [
              NoteCardBuilder(
                note: note,

                onReminderItemChanged: (itemIndex, value) async {
                  await onReminderItemChanged?.call(note.id, itemIndex, value);
                },

                onBlockChecklistChanged: (blockIndex, value) async {
                  await onBlockChecklistChanged?.call(
                    note.id,
                    blockIndex,
                    value,
                  );
                },
              ),

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
    );
  }
}

// ==================================================================
// FOLDER VIEW
// ==================================================================

class FolderView extends StatelessWidget {
  final List<Folder> folders;

  final void Function(Folder folder)? onFolderTap;

  final void Function(Folder folder)? onFolderLongPress;

  const FolderView({
    super.key,
    required this.folders,
    this.onFolderTap,
    this.onFolderLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return const Center(child: Text('No Folders Yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

      itemCount: folders.length,

      // ==========================================================
      // ORIGINAL FOLDER SIZING
      // ==========================================================
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),

      itemBuilder: (context, index) {
        final Folder folder = folders[index];

        return GestureDetector(
          onLongPress: () {
            onFolderLongPress?.call(folder);
          },

          onTap: () {
            onFolderTap?.call(folder);
          },

          // ======================================================
          // ORIGINAL CARD - UNCHANGED
          // ======================================================
          child: FolderCardBuilder(folder: folder),
        );
      },
    );
  }
}
