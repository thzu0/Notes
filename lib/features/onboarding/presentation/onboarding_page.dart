import 'package:flutter/material.dart';
import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/features/notes/presentation/home_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Image.asset(
                'assets/images/onboarding_page.png',
                height: 400,
                width: 500,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 65),
            Text('Daily Notes', style: NoteTextStyle.headingTitleApp),

            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 60),
              child: Text(
                'Take notes, reminders, set targets,\n collect resources, and secure privacy',
                textAlign: TextAlign.center,
                style: NoteTextStyle.descriptionOnboarding,
              ),
            ),
            SizedBox(
              width: 200,
              height: 65,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
