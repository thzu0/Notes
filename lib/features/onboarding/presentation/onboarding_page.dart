import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notes_app/core/note_text_style.dart';
import 'package:notes_app/features/notes/presentation/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // ============================================================
  // FINISH ONBOARDING
  // ============================================================

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // تصویر نسبت به عرض صفحه
            final double imageWidth = screenWidth.clamp(280.0, 500.0);

            final double imageHeight = (screenHeight * 0.38).clamp(
              250.0,
              400.0,
            );

            // فاصله‌ها نسبت به ارتفاع صفحه
            final double titleTopSpacing = (screenHeight * 0.05).clamp(
              20.0,
              45.0,
            );

            final double descriptionTopSpacing = (screenHeight * 0.025).clamp(
              16.0,
              30.0,
            );

            final double descriptionBottomSpacing = (screenHeight * 0.05).clamp(
              25.0,
              60.0,
            );

            // عرض دکمه نسبت به صفحه
            final double buttonWidth = (screenWidth * 0.55).clamp(180.0, 240.0);

            final double buttonHeight = (screenHeight * 0.075).clamp(
              52.0,
              65.0,
            );

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Column(
                  children: [
                    // ==================================================
                    // IMAGE
                    // ==================================================
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.06,
                        left: 20,
                        right: 20,
                      ),
                      child: Image.asset(
                        'assets/images/onboarding_page.png',
                        height: imageHeight,
                        width: imageWidth,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // ==================================================
                    // TITLE
                    // ==================================================
                    SizedBox(height: titleTopSpacing),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Daily Notes',
                        textAlign: TextAlign.center,
                        style: NoteTextStyle.headingTitleApp,
                      ),
                    ),

                    // ==================================================
                    // DESCRIPTION
                    // ==================================================
                    Padding(
                      padding: EdgeInsets.only(
                        top: descriptionTopSpacing,
                        left: 20,
                        right: 20,
                        bottom: descriptionBottomSpacing,
                      ),
                      child: Text(
                        'Take notes, reminders, set targets,\n'
                        'collect resources, and secure privacy',
                        textAlign: TextAlign.center,
                        style: NoteTextStyle.descriptionOnboarding,
                      ),
                    ),

                    // ==================================================
                    // GET STARTED BUTTON
                    // ==================================================
                    SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _finishOnboarding,
                        child: const Text('Get Started'),
                      ),
                    ),

                    // فضای پایین
                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
