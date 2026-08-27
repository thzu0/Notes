import 'package:flutter/material.dart';

class CreateFolderBottomSheet extends StatefulWidget {
  const CreateFolderBottomSheet({super.key});

  @override
  State<CreateFolderBottomSheet> createState() =>
      _CreateFolderBottomSheetState();
}

class _CreateFolderBottomSheetState extends State<CreateFolderBottomSheet> {
  static const Color _sheetBg = Color(0xFF1C1E24);
  static const Color _fieldBg = Color(0xFF2A2D35);
  static const Color _textColor = Color(0xFFE5E7EB);
  static const Color _hintColor = Color(0xFF6B7280);
  static const Color _selectedBlue = Color(0xFF2F6FED);

  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  final List<Color> _folderColors = const [
    Color(0xFFF5A623),
    Color(0xFFE53935),
    Color(0xFFFDD835),
    Color(0xFF43A047),
    Color(0xFF29B6F6),
    Color(0xFF5C6BC0),
    Color(0xFF9B7CD9),
    Color(0xFFEC407A),
  ];

  late Color _selectedColor;

  bool get _isNameValid {
    return _nameController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    _selectedColor = _folderColors.first;

    _nameController.addListener(_onNameChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  void _onNameChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _handleCreate() {
    final String name = _nameController.text.trim();

    if (name.isEmpty) {
      return;
    }

    Navigator.of(context).pop({'name': name, 'color': _selectedColor});
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double bottomInset = mediaQuery.viewInsets.bottom;

    final double availableHeight = mediaQuery.size.height - bottomInset;

    final double maxSheetHeight = availableHeight * 0.9;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Container(
              decoration: const BoxDecoration(
                color: _sheetBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================
                  Row(
                    children: [
                      const Text(
                        'New Folder',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const Spacer(),

                      IconButton(
                        icon: const Icon(Icons.close, color: _hintColor),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // FOLDER NAME
                  // ==================================================
                  Container(
                    decoration: BoxDecoration(
                      color: _fieldBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      style: const TextStyle(color: _textColor, fontSize: 16),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        _handleCreate();
                      },
                      decoration: const InputDecoration(
                        hintText: 'Folder name',
                        hintStyle: TextStyle(color: _hintColor, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // COLOR TITLE
                  // ==================================================
                  const Text(
                    'Color',
                    style: TextStyle(
                      color: _hintColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==================================================
                  // COLORS
                  // ==================================================
                  Wrap(
                    spacing: 14,
                    runSpacing: 12,
                    children: _folderColors.map((color) {
                      final bool isSelected = color == _selectedColor;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // CREATE BUTTON
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isNameValid ? _handleCreate : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedBlue,
                        disabledBackgroundColor: _fieldBg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
