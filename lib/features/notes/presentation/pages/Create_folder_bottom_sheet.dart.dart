import 'package:flutter/material.dart';

/// بات‌شیت افزودن فولدر جدید.
///
/// استفاده (مثلاً توی onPressed فب):
/// final result = await showModalBottomSheet<Map<String, dynamic>>(
///   context: context,
///   backgroundColor: Colors.transparent,
///   isScrollControlled: true,
///   builder: (_) => const AddFolderBottomSheet(),
/// );
/// if (result != null) {
///   final String name = result['name'];
///   final Color color = result['color'];
///   // اینجا فولدر رو بساز/سیو کن
/// }
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
    Color(0xFFF5A623), // نارنجی (پیش‌فرض)
    Color(0xFFE53935), // قرمز
    Color(0xFFFDD835), // زرد
    Color(0xFF43A047), // سبز
    Color(0xFF29B6F6), // آبی روشن
    Color(0xFF5C6BC0), // بنفش‌آبی
    Color(0xFF9B7CD9), // بنفش
    Color(0xFFEC407A), // صورتی
  ];
  late Color _selectedColor;

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedColor = _folderColors.first;
    _nameController.addListener(() => setState(() {}));
    // یه فریم صبر می‌کنیم تا بات‌شیت کامل باز بشه، بعد کیبورد رو باز می‌کنیم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (!_isNameValid) return;
    Navigator.of(
      context,
    ).pop({'name': _nameController.text.trim(), 'color': _selectedColor});
  }

  @override
  Widget build(BuildContext context) {
    // فاصله‌ی کیبورد، تا شیت زیر کیبورد گم نشه
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
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
              // هدر
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // فیلد اسم فولدر
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
                  onSubmitted: (_) => _handleCreate(),
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

              const Text(
                'Color',
                style: TextStyle(
                  color: _hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              // ردیف رنگ‌ها
              Wrap(
                spacing: 14,
                runSpacing: 12,
                children: _folderColors.map((color) {
                  final bool isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
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

              // دکمه‌ی ساخت
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isNameValid ? _handleCreate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedBlue,
                    disabledBackgroundColor: _fieldBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
    );
  }
}
