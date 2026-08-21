import 'package:flutter/material.dart';
import 'package:notes_app/core/note_colors.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const Color _background = Color(0xFF101114);
  static const Color _cardColor = Color(0xFF1D1F26);
  static const Color _textColor = Color(0xFFF1F1F3);
  static const Color _secondaryText = Color(0xFF9A9BA2);
  static const Color _borderColor = Color(0xFF777A82);
  static const Color _buttonColor = Color(0xFF30343D);
  static const Color _submitColor = Color(0xFFF5C65D);

  final TextEditingController _detailsController = TextEditingController();

  final List<String> _feedbackTypes = [
    'Poor experience',
    'Notes disappeared',
    'Lags or crashes',
    'Account issues',
    'Feature suggestions',
    'Too many ads',
    'Others',
  ];

  final Set<String> _selectedTypes = {};

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _toggleType(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  void _pickImage() {
    // بعداً image_picker رو اینجا اضافه می‌کنیم.
  }

  void _submitFeedback() {
    if (_detailsController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 6 characters.')),
      );
      return;
    }

    print('Selected problems: $_selectedTypes');
    print('Details: ${_detailsController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submitted successfully.')),
    );
  }

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
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Tell us the problem you\nencountered',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 30,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              // Problem types
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkCardBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: _feedbackTypes.map((type) {
                    final bool selected = _selectedTypes.contains(type);

                    return InkWell(
                      onTap: () => _toggleType(type),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            // Checkbox
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: selected ? Colors.white : _borderColor,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.black,
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: Text(
                                type,
                                style: const TextStyle(
                                  color: _textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Details
              Container(
                width: double.infinity,
                height: 292,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                decoration: BoxDecoration(
                  color: AppColors.darkCardBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _detailsController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          color: _textColor,
                          fontSize: 17,
                          height: 1.35,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              'Please tell us more details so that we can '
                              'locate and solve your problem faster (at least 6 '
                              'characters)',
                          hintStyle: TextStyle(
                            color: _secondaryText,
                            fontSize: 17,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Camera
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: _buttonColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
