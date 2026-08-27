import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fleather/fleather.dart';
import 'package:notes_app/core/note_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notes_app/data/database/isar_service.dart';
import 'package:notes_app/features/onboarding/presentation/onboarding_page.dart';
import 'package:notes_app/features/notes/presentation/home_page.dart';
import 'core/note_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarService.open();

  await NotificationService.instance.init();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  runApp(NotesApp(onboardingCompleted: onboardingCompleted));
}

class NotesApp extends StatefulWidget {
  final bool onboardingCompleted;

  const NotesApp({super.key, required this.onboardingCompleted});

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

      home: widget.onboardingCompleted
          ? const HomePage()
          : const OnboardingPage(),
    );
  }
}
