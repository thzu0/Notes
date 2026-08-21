import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const Color _background = Color(0xFF101114);

  static const Color _textColor = Color(0xFFF1F1F3);
  static const Color _secondaryText = Color(0xFF9A9BA2);
  static const Color _accentColor = Color(0xFFF5C65D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: _textColor,
            size: 24,
          ),
        ),

        title: const Text(
          'About Us',
          style: TextStyle(
            color: _textColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------------------------
              // Logo
              // ---------------------------
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.darkCardBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.sticky_note_2_outlined,
                  color: _accentColor,
                  size: 48,
                ),
              ),

              const SizedBox(height: 20),

              // ---------------------------
              // App name
              // ---------------------------
              const Text(
                'Notes',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Simple notes. Clear thoughts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 28),

              // ---------------------------
              // Description
              // ---------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.darkCardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'A simple and beautiful place to capture '
                  'your thoughts, ideas, and everyday moments.\n\n'
                  'We believe taking a note should be quick, '
                  'easy, and free from distractions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ---------------------------
              // Our Mission
              // ---------------------------
              _SectionCard(
                title: 'Our Mission',
                icon: Icons.flag_outlined,
                child: const Text(
                  'We built Notes to make writing down your '
                  'thoughts feel simple, fast, and distraction-free.',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------------
              // Why Notes?
              // ---------------------------
              _SectionCard(
                title: 'Why Notes?',
                icon: Icons.auto_awesome_outlined,
                child: Column(
                  children: const [
                    _FeatureItem(
                      icon: Icons.bolt_outlined,
                      title: 'Simple',
                      description: 'Everything you need, nothing you don’t.',
                    ),
                    SizedBox(height: 18),
                    _FeatureItem(
                      icon: Icons.speed_outlined,
                      title: 'Fast',
                      description: 'Capture your thoughts in seconds.',
                    ),
                    SizedBox(height: 18),
                    _FeatureItem(
                      icon: Icons.lock_outline,
                      title: 'Private',
                      description: 'Your notes belong to you.',
                    ),
                    SizedBox(height: 18),
                    _FeatureItem(
                      icon: Icons.remove_circle_outline,
                      title: 'Distraction-free',
                      description: 'Focus on your thoughts, not the interface.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------------
              // Built by
              // ---------------------------
              _SectionCard(
                title: 'Built by',
                icon: Icons.person_outline,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Th_zu0',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Mobile Producter\nUI & UX designer',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ---------------------------
              // Version
              // ---------------------------
              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 5),
                  Icon(Icons.favorite, color: _accentColor, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Section Card
// --------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AboutUsPage._accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AboutUsPage._accentColor, size: 21),
              ),

              const SizedBox(width: 12),

              Text(
                title,

                style: const TextStyle(
                  color: AboutUsPage._textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

// --------------------------------------------------
// Feature Item
// --------------------------------------------------

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AboutUsPage._background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AboutUsPage._accentColor, size: 21),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AboutUsPage._textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: const TextStyle(
                  color: AboutUsPage._secondaryText,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
