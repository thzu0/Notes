import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/data/fake_folder.dart';

import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/pages/Create_folder_bottom_sheet.dart.dart';
import 'package:notes_app/features/notes/presentation/pages/about_us_page.dart';
import 'package:notes_app/features/notes/presentation/pages/create_note_page.dart';
import 'package:notes_app/features/notes/presentation/pages/feedback_page.dart';
import 'package:notes_app/features/notes/presentation/widgets/folder_card_builder.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_card_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final List<Note> notes = [];
  late TabController _tabController;

  void onTabChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _updateReminderItem(String noteId, int itemIndex, bool value) {
    final noteIndex = notes.indexWhere((note) => note.id == noteId);

    if (noteIndex == -1) return;

    final note = notes[noteIndex];

    final items = List<ChecklistItem>.from(note.checklistitems ?? []);

    if (itemIndex >= items.length) return;

    items[itemIndex] = ChecklistItem(
      title: items[itemIndex].title,
      isDone: value,
    );

    setState(() {
      notes[noteIndex] = Note(
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
    });
  }

  // برای نوت‌های آزاد (بلاک‌محور): وقتی کاربر روی یه آیتم
  // چک‌لیستِ داخل note.blocks تپ می‌کنه.
  void _updateBlockChecklistItem(String noteId, int blockIndex, bool value) {
    final noteIndex = notes.indexWhere((note) => note.id == noteId);

    if (noteIndex == -1) return;

    final note = notes[noteIndex];

    final blocks = List<NoteBlock>.from(note.blocks);

    if (blockIndex >= blocks.length) return;

    final block = blocks[blockIndex];

    blocks[blockIndex] = NoteBlock(
      type: block.type,
      text: block.text,
      isDone: value,
      imageUrl: block.imageUrl,
      quoteAuthor: block.quoteAuthor,
    );

    setState(() {
      notes[noteIndex] = Note(
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
    });
  }

  // با تپ روی یه کارت، صفحه ادیت با نوت موجود باز می‌شه
  // و در برگشت، همون نوت (با همون id) در لیست جایگزین می‌شه.
  Future<void> _editNote(Note note) async {
    final Note? updatedNote = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (context) => CreateNotePage(existingNote: note),
      ),
    );

    if (updatedNote == null) return;

    final noteIndex = notes.indexWhere((n) => n.id == note.id);

    if (noteIndex == -1) return;

    setState(() {
      notes[noteIndex] = updatedNote;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text('Notes'),
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.zero,

              style: IconButton.styleFrom(foregroundColor: AppColors.textMuted),
              onPressed: () {},
              icon: Icon(Icons.search, size: 30),
            ),
            PopupMenuButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.more_vert_outlined),
              iconSize: 30,
              iconColor: AppColors.textMuted,

              menuPadding: EdgeInsets.all(8.0),
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
                        builder: (value) => const FeedbackPage(),
                      ),
                    );
                  },
                ),

                PopupMenuItem(
                  value: 'about us',
                  child: Text('About Us'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (value) => const AboutUsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],

          bottom: PreferredSize(
            preferredSize: Size.fromHeight(75),

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

                      indicatorColor: Color(0xFFF5C65D),

                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Color(0xFFF5C65D),
                      unselectedLabelColor: Colors.grey,

                      labelStyle: NoteTextStyle.tabActive,
                      unselectedLabelStyle: NoteTextStyle.tabInactive,

                      tabs: <Widget>[
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
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              AllNotesView(
                notes: notes,
                onReminderItemChanged: _updateReminderItem,
                onBlockChecklistChanged: _updateBlockChecklistItem,
                onNoteTap: _editNote,
              ),
              FolderView(),
            ],
          ),
        ),

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 30, right: 8),
          child: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () async {
              if (_tabController.index == 0) {
                final Note? newNote = await Navigator.of(context).push<Note>(
                  MaterialPageRoute(
                    builder: (context) => const CreateNotePage(),
                  ),
                );
                if (newNote != null) {
                  setState(() {
                    notes.add(newNote);
                  });
                }
              } else {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const CreateFolderBottomSheet(),
                );

                if (result != null) {
                  final String name = result['name'];
                  final Color color = result['color'];

                  // فعلاً برای تست
                  print('Folder name: $name');
                  print('Folder color: $color');

                  // اینجا بعداً فولدر رو به fakeFolders اضافه می‌کنی
                  // و setState می‌زنی تا Home آپدیت بشه.
                }
              }
            },
            child: Icon(
              _tabController.index == 0
                  ? Icons.note_add_outlined
                  : Icons.create_new_folder_outlined,
            ),
          ),
        ),
      ),
    );
  }
}

class AllNotesView extends StatelessWidget {
  final List<Note> notes;
  final void Function(String noteId, int itemIndex, bool value)?
  onReminderItemChanged;
  final void Function(String noteId, int blockIndex, bool value)?
  onBlockChecklistChanged;
  final void Function(Note note)? onNoteTap;

  const AllNotesView({
    super.key,
    required this.notes,
    this.onReminderItemChanged,
    this.onBlockChecklistChanged,
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(child: Text('No Notes Yet'));
    }
    return MasonryGridView.count(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 100),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () => onNoteTap?.call(note),
          child: NoteCardBuilder(
            note: note,
            onReminderItemChanged: (itemIndex, value) {
              onReminderItemChanged?.call(note.id, itemIndex, value);
            },
            onBlockChecklistChanged: (blockIndex, value) {
              onBlockChecklistChanged?.call(note.id, blockIndex, value);
            },
          ),
        );
      },
    );
  }
}

class FolderView extends StatelessWidget {
  const FolderView({super.key});

  @override
  Widget build(BuildContext context) {
    if (fakeFolders.isEmpty) {
      return const Center(child: Text('No Folders Yet'));
    }
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: fakeFolders.length,
      itemBuilder: (context, index) {
        final folder = fakeFolders[index];
        return FolderCardBuilder(folder: folder);
      },
    );
  }
}
