import 'package:flutter/material.dart';

import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/features/notes/model/model.dart';
import 'package:notes_app/features/notes/presentation/pages/create_note_page.dart';
import 'package:notes_app/features/notes/presentation/widgets/note_card_builder.dart';

class SearchPage extends StatefulWidget {
  final List<Note> notes;

  const SearchPage({super.key, required this.notes});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Note> _results = [];

  @override
  void initState() {
    super.initState();

    _results = List<Note>.from(widget.notes);

    _searchController.addListener(_search);
  }

  @override
  void dispose() {
    _searchController.removeListener(_search);

    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _search() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _results = List<Note>.from(widget.notes);
      });

      return;
    }

    final results = widget.notes.where((note) {
      // --------------------------------------------------------
      // TITLE
      // --------------------------------------------------------

      if (note.title.toLowerCase().contains(query)) {
        return true;
      }

      // --------------------------------------------------------
      // CONTENT
      // --------------------------------------------------------

      if (note.content.toLowerCase().contains(query)) {
        return true;
      }

      // --------------------------------------------------------
      // BLOCKS
      // --------------------------------------------------------

      for (final block in note.blocks) {
        final text = block.text?.toLowerCase() ?? '';

        if (text.contains(query)) {
          return true;
        }

        final author = block.quoteAuthor?.toLowerCase() ?? '';

        if (author.contains(query)) {
          return true;
        }
      }

      // --------------------------------------------------------
      // REMINDER CHECKLIST
      // --------------------------------------------------------

      for (final item in note.checklistitems ?? <ChecklistItem>[]) {
        if (item.title.toLowerCase().contains(query)) {
          return true;
        }
      }

      return false;
    }).toList();

    setState(() {
      _results = results;
    });
  }

  // ============================================================
  // EDIT NOTE
  // ============================================================

  Future<void> _openNote(Note note) async {
    final updatedNote = await Navigator.of(context).push<Note>(
      MaterialPageRoute(
        builder: (context) => CreateNotePage(existingNote: note),
      ),
    );

    if (updatedNote == null) {
      return;
    }

    final index = widget.notes.indexWhere((item) => item.id == updatedNote.id);

    if (index != -1) {
      widget.notes[index] = updatedNote;
    }

    _search();
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void _clearSearch() {
    _searchController.clear();

    _searchFocusNode.requestFocus();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.textPriamry),
        ),

        titleSpacing: 0,

        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,

            autofocus: true,

            style: const TextStyle(color: AppColors.textPriamry, fontSize: 15),

            cursorColor: const Color(0xFFF5C65D),

            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),

              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondery,
                size: 21,
              ),

              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondery,
                        size: 19,
                      ),
                    ),

              hintText: 'Search notes...',
              hintStyle: const TextStyle(
                color: AppColors.textSecondery,
                fontSize: 15,
              ),
            ),
          ),
        ),

        actions: const [SizedBox(width: 12)],
      ),

      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_searchController.text.trim().isNotEmpty && _results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: AppColors.textSecondery, size: 42),

            SizedBox(height: 12),

            Text(
              'No notes found',
              style: TextStyle(
                color: AppColors.textPriamry,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'Try a different keyword',
              style: TextStyle(color: AppColors.textSecondery, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'No Notes Yet',
          style: TextStyle(color: AppColors.textSecondery),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final note = _results[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _openNote(note),
            child: NoteCardBuilder(
              note: note,

              onReminderItemChanged: (itemIndex, value) {},

              onBlockChecklistChanged: (blockIndex, value) {},
            ),
          ),
        );
      },
    );
  }
}
