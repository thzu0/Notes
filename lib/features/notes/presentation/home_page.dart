import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/core/app_security_service.dart';

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
import 'package:notes_app/features/notes/presentation/pages/security_pin_page.dart';

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
      _sortNotesByPin();
    });
  }
  // ============================================================
  // SORT NOTES BY PIN
  // ============================================================

  void _sortNotesByPin() {
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) {
        return -1;
      }
      if (!a.isPinned && b.isPinned) {
        return 1;
      }

      return 0;
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

    final selectedIds = Set<String>.from(_selectedNoteIds);

    final selectedNotes = notes
        .where((note) => selectedIds.contains(note.id))
        .toList();

    if (selectedNotes.isEmpty) return;

    // ============================================================
    // CHECK LOCKED NOTES
    // ============================================================

    final hasLockedNote = selectedNotes.any((note) => note.isLocked);

    // ============================================================
    // IF THERE IS A LOCKED NOTE → ASK FOR PIN
    // ============================================================

    if (hasLockedNote) {
      final authenticated = await _authenticateWithPin();

      if (!authenticated) {
        return;
      }
    }

    // ============================================================
    // DELETE
    // ============================================================

    final count = selectedNotes.length;

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

    // ============================================================
    // DELETE FROM DATABASE
    // ============================================================

    for (final noteId in selectedIds) {
      await _noteRepository.deleteNote(noteId);
    }

    if (!mounted) return;

    // ============================================================
    // REMOVE FROM LOCAL LIST
    // ============================================================

    setState(() {
      notes.removeWhere((note) => selectedIds.contains(note.id));

      _selectedNoteIds.clear();
      _isSelectionMode = false;
    });
  }

  // ============================================================
  // LOCK / UNLOCK SELECTED NOTES
  // ============================================================

  Future<void> _toggleLockSelectedNotes() async {
    // ============================================================
    // NO SELECTED NOTES
    // ============================================================

    if (_selectedNoteIds.isEmpty) {
      return;
    }

    // ============================================================
    // GET SELECTED NOTES
    // ============================================================

    final selectedIds = Set<String>.from(_selectedNoteIds);

    final selectedNotes = notes
        .where((note) => selectedIds.contains(note.id))
        .toList();

    if (selectedNotes.isEmpty) {
      return;
    }

    // ============================================================
    // DETERMINE LOCK / UNLOCK
    // ============================================================

    // اگر همه نوت‌های انتخاب‌شده Lock باشند → Unlock
    // در غیر این صورت → Lock
    final bool shouldUnlock = selectedNotes.every((note) => note.isLocked);

    // ============================================================
    // UNLOCK
    // ============================================================

    if (shouldUnlock) {
      final authenticated = await _authenticateToUnlockNote();

      if (!authenticated) {
        return;
      }
    }

    // ============================================================
    // LOCK
    // ============================================================

    if (!shouldUnlock) {
      final security = AppSecurityService.instance;

      // ==========================================================
      // 1. CHECK PIN
      // ==========================================================

      final hasPin = await security.hasPin();

      if (!hasPin) {
        final pinCreated = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const SecurityPinPage()),
        );

        // کاربر PIN نساخت / صفحه را بست
        if (pinCreated != true) {
          return;
        }
      }

      // ==========================================================
      // 2. ASK FOR BIOMETRIC
      // ==========================================================

      final biometricEnabled = await security.isBiometricEnabled();

      if (!biometricEnabled) {
        await _askToEnableBiometric();
      }
    }

    // ============================================================
    // APPLY LOCK / UNLOCK
    // ============================================================

    for (final note in selectedNotes) {
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
        blocks: note.blocks,

        // حفظ Pin
        isPinned: note.isPinned,

        // تغییر Lock
        isLocked: !shouldUnlock,
      );

      // ==========================================================
      // SAVE DATABASE
      // ==========================================================

      await _noteRepository.updateNote(updatedNote);

      // ==========================================================
      // UPDATE LOCAL LIST
      // ==========================================================

      final index = notes.indexWhere((item) => item.id == note.id);

      if (index != -1) {
        notes[index] = updatedNote;
      }
    }

    // ============================================================
    // EXIT SELECTION MODE
    // ============================================================

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedNoteIds.clear();
      _isSelectionMode = false;
    });
  }

  // ============================================================
  // AUTH TO UNLOCK NOTE
  // ============================================================

  Future<bool> _authenticateToUnlockNote() async {
    final security = AppSecurityService.instance;

    // ==========================================================
    // 1. BIOMETRIC
    // ==========================================================

    final biometricEnabled = await security.isBiometricEnabled();

    final canUseBiometric = await security.canUseBiometrics();

    if (biometricEnabled && canUseBiometric) {
      final authenticated = await security.authenticateWithBiometrics();

      if (authenticated) {
        return true;
      }
    }

    // ==========================================================
    // 2. FALLBACK TO PIN
    // ==========================================================

    return await _authenticateWithPin();
  }

  // ============================================================
  // AUTH PIN
  // ============================================================

  Future<bool> _authenticateWithPin() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final controller = TextEditingController();

        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Unlock Note'),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                style: const TextStyle(fontSize: 20, letterSpacing: 6),
                decoration: InputDecoration(
                  labelText: 'PIN',
                  counterText: '',
                  errorText: errorMessage,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Cancel'),
                ),

                TextButton(
                  onPressed: () async {
                    final pin = controller.text.trim();

                    if (pin.length != 4) {
                      setDialogState(() {
                        errorMessage = 'Enter your 4-digit PIN.';
                      });

                      return;
                    }

                    final valid = await AppSecurityService.instance.verifyPin(
                      pin,
                    );

                    if (!valid) {
                      setDialogState(() {
                        errorMessage = 'Incorrect PIN.';
                      });

                      controller.clear();
                      return;
                    }

                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Unlock'),
                ),
              ],
            );
          },
        );
      },
    );

    return result == true;
  }

  // ============================================================
  // ASK TO ENABLE BIOMETRIC
  // ============================================================

  Future<void> _askToEnableBiometric() async {
    final security = AppSecurityService.instance;

    // ============================================================
    // ASK ONLY ONCE
    // ============================================================

    final alreadyAsked = await security.hasAskedBiometricPrompt();

    if (alreadyAsked || !mounted) {
      return;
    }

    // ============================================================
    // MARK PROMPT AS SHOWN
    // ============================================================

    await security.setBiometricPromptShown();

    if (!mounted) {
      return;
    }

    // ============================================================
    // ASK USER
    // ============================================================

    final shouldEnable = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Use Biometric?'),
          content: const Text(
            'Would you like to use fingerprint or Face '
            'authentication to unlock your locked notes?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Not now'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );

    // ============================================================
    // NOT NOW
    // ============================================================

    if (shouldEnable != true) {
      return;
    }

    // ============================================================
    // CHECK BIOMETRIC SUPPORT ONLY AFTER ENABLE
    // ============================================================

    final canUseBiometric = await security.canUseBiometrics();
    debugPrint('CAN USE BIOMETRIC = $canUseBiometric');

    if (!canUseBiometric || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Biometric authentication is not available on this device.',
          ),
        ),
      );

      return;
    }

    // ============================================================
    // AUTHENTICATE
    // ============================================================

    debugPrint('STARTING BIOMETRIC AUTH');

    final authenticated = await security.authenticateWithBiometrics();

    debugPrint('BIOMETRIC AUTH RESULT = $authenticated');

    if (!authenticated) {
      return;
    }

    // ============================================================
    // ENABLE
    // ============================================================

    await security.setBiometricEnabled(true);

    final check = await security.isBiometricEnabled();

    debugPrint('BIOMETRIC ENABLED = $check');
  }

  // ============================================================
  // PIN / UNPIN SELECTED NOTES
  // ============================================================

  Future<void> _togglePinSelectedNotes() async {
    if (_selectedNoteIds.isEmpty) {
      return;
    }

    final selectedIds = Set<String>.from(_selectedNoteIds);

    final selectedNotes = notes
        .where((note) => selectedIds.contains(note.id))
        .toList();

    final bool shouldUnpin =
        selectedNotes.isNotEmpty &&
        selectedNotes.every((note) => note.isPinned);

    for (final note in selectedNotes) {
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
        blocks: note.blocks,

        isPinned: !shouldUnpin,
        isLocked: note.isLocked,
      );

      await _noteRepository.updateNote(updatedNote);

      final index = notes.indexWhere((item) => item.id == note.id);

      if (index != -1) {
        notes[index] = updatedNote;
      }
    }

    if (!mounted) return;

    setState(() {
      _sortNotesByPin();

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

    if (itemIndex >= items.length) {
      return;
    }

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
      isPinned: note.isPinned,
      isLocked: note.isLocked,
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

    if (blockIndex >= blocks.length) {
      return;
    }

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
      isPinned: note.isPinned,
      isLocked: note.isLocked,
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
    // Note معمولی
    if (!note.isLocked) {
      await _openNoteEditor(note);
      return;
    }

    // Note قفل‌شده → احراز هویت
    final authenticated = await _authenticateToUnlockNote();

    if (!authenticated) {
      return;
    }

    await _openNoteEditor(note);
  }

  Future<void> _openNoteEditor(Note note) async {
    final Note? updatedNote = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (context) => CreateNotePage(existingNote: note),
      ),
    );

    if (updatedNote == null) {
      return;
    }

    final noteIndex = notes.indexWhere((n) => n.id == note.id);

    if (noteIndex == -1) {
      return;
    }

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

    if (result == null) {
      return;
    }

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
  // FOLDER ACTIONS
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

                // ==================================================
                // EDIT FOLDER
                // ==================================================
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textPriamry,
                    size: 26,
                  ),
                  title: const Text(
                    'Edit Folder',
                    style: TextStyle(
                      color: AppColors.textPriamry,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop('edit');
                  },
                ),

                const Divider(color: Color(0xFF2A2D35), height: 1),

                // ==================================================
                // DELETE FOLDER
                // ==================================================
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

                // ==================================================
                // CANCEL
                // ==================================================
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

    if (action == 'edit') {
      await _editFolder(folder);
    } else if (action == 'delete') {
      await _confirmDeleteFolder(folder);
    }
  }

  // ============================================================
  // EDIT FOLDER
  // ============================================================

  Future<void> _editFolder(Folder folder) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return CreateFolderBottomSheet(existingFolder: folder);
      },
    );

    if (result == null) {
      return;
    }

    final String name = result['name'] as String;

    final Color color = result['color'] as Color;

    final Folder updatedFolder = Folder(
      id: folder.id,
      name: name,
      colorValue: color,
    );

    // مهم:
    // برای Edit از updateFolder استفاده می‌کنیم.
    await _folderRepository.updateFolder(updatedFolder);

    if (!mounted) return;

    final index = folders.indexWhere((item) => item.id == folder.id);

    if (index != -1) {
      setState(() {
        folders[index] = updatedFolder;
      });
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

    if (confirmed != true) {
      return;
    }

    await _deleteFolder(folder);
  }

  // ============================================================
  // DELETE FOLDER
  // ============================================================

  Future<void> _deleteFolder(Folder folder) async {
    final affectedNotes = notes
        .where((note) => note.folderld == folder.id)
        .toList();

    // ----------------------------------------------------------
    // REMOVE FOLDER RELATION FROM NOTES
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
        isPinned: note.isPinned,
        isLocked: note.isLocked,
      );

      await _noteRepository.updateNote(updatedNote);

      final noteIndex = notes.indexWhere((item) => item.id == note.id);

      if (noteIndex != -1) {
        notes[noteIndex] = updatedNote;
      }
    }

    // ----------------------------------------------------------
    // DELETE FOLDER FROM ISAR
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
  // OPEN FOLDER
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

            if (index == -1) {
              return;
            }

            setState(() {
              notes[index] = updatedNote;
            });
          },

          // ====================================================
          // DELETE NOTE INSIDE FOLDER
          // ====================================================
          onNoteDeleted: (noteId) async {
            final index = notes.indexWhere((note) => note.id == noteId);

            if (index == -1) {
              return;
            }

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
            : const Text('Notes', style: TextStyle(fontSize: 30)),

        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelSelectionMode,
              )
            : null,

        actions: _isSelectionMode
            ? [
                // ==================================================
                // DELETE
                // ==================================================
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 28,
                  onPressed: _deleteSelectedNotes,
                ),
                // ==================================================
                // PIN / LOCK MENU
                // ==================================================
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert),
                  iconSize: 30,
                  iconColor: AppColors.textPriamry,

                  menuPadding: const EdgeInsets.all(8),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  onSelected: (value) {
                    if (value == 'pin') {
                      _togglePinSelectedNotes();
                    } else if (value == 'lock') {
                      _toggleLockSelectedNotes();
                    }
                  },

                  itemBuilder: (context) {
                    final selectedNotes = notes
                        .where((note) => _selectedNoteIds.contains(note.id))
                        .toList();

                    final bool allPinned =
                        selectedNotes.isNotEmpty &&
                        selectedNotes.every((note) => note.isPinned);

                    final bool allLocked =
                        selectedNotes.isNotEmpty &&
                        selectedNotes.every((note) => note.isLocked);

                    return [
                      // ============================================
                      // PIN
                      // ============================================
                      PopupMenuItem<String>(
                        value: 'pin',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.push_pin_outlined,
                              color: AppColors.textPriamry,
                              size: 22,
                            ),

                            const SizedBox(width: 12),

                            Text(
                              allPinned ? 'Unpin' : 'Pin',
                              style: const TextStyle(
                                color: AppColors.textPriamry,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ============================================
                      // LOCK
                      // ============================================
                      PopupMenuItem<String>(
                        value: 'lock',
                        child: Row(
                          children: [
                            Icon(
                              allLocked
                                  ? Icons.lock_open_outlined
                                  : Icons.lock_outline,
                              color: AppColors.textPriamry,
                              size: 22,
                            ),

                            const SizedBox(width: 12),

                            Text(
                              allLocked ? 'Unlock' : 'Lock',
                              style: const TextStyle(
                                color: AppColors.textPriamry,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ]
            : [
                // ==================================================
                // SEARCH
                // ==================================================
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

                // ==================================================
                // MORE
                // ==================================================
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
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
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
                  // ========================================
                  // ALL TAB
                  // ========================================

                  if (_tabController.index == 0) {
                    final Note? newNote = await Navigator.of(context)
                        .push<Note>(
                          MaterialPageRoute(
                            builder: (_) => const CreateNotePage(),
                          ),
                        );

                    if (newNote != null) {
                      await _noteRepository.saveNote(newNote);

                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        notes.add(newNote);
                      });
                    }

                    return;
                  }

                  // ========================================
                  // FOLDER TAB
                  // ========================================

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
                  left: 8,
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
          child: FolderCardBuilder(folder: folder),
        );
      },
    );
  }
}
