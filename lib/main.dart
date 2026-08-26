import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fleather/fleather.dart';

import 'package:notes_app/features/onboarding/presentation/onboarding_page.dart';
import 'core/note_theme.dart';

void main(List<String> args) {
  runApp(const NotesApp());
}

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: NoteTheme.darkTheme,

      localizationsDelegates: const [
        FleatherLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      supportedLocales: FleatherLocalizations.supportedLocales,

      home: OnboardingPage(),
    );
  }
}
