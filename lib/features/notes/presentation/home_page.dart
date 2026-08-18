import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';
import 'package:notes_app/core/note_text_style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Notes'),
          actions: <Widget>[
            TextButton(
              onPressed: () {},
              child: const Text('Edit', style: NoteTextStyle.tabInactive),
            ),
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
                const PopupMenuItem(value: 'profile', child: Text('Profile')),

                const PopupMenuItem(value: 'setting', child: Text('Settings')),

                const PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            ),
          ],

          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),

            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TabBar(
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
        body: SafeArea(child: Column(children: <Widget>[])),
      ),
    );
  }
}
