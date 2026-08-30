import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerBottomSheet extends StatefulWidget {
  final FleatherController controller;

  final VoidCallback? onColorChanged;

  const ColorPickerBottomSheet({
    super.key,
    required this.controller,
    this.onColorChanged,
  });

  @override
  State<ColorPickerBottomSheet> createState() => _ColorPickerBottomSheetState();
}

class _ColorPickerBottomSheetState extends State<ColorPickerBottomSheet> {
  // ============================================================
  // COLORS
  // ============================================================

  static const List<Color> _colors = [
    Color(0xFFFFFFFF),
    Color(0xFFE5E7EB),
    Color(0xFF9CA3AF),
    Color(0xFFF87171),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFFFACC15),
    Color(0xFF4ADE80),
    Color(0xFF22C55E),
    Color(0xFF38BDF8),
    Color(0xFF3B82F6),
    Color(0xFF818CF8),
    Color(0xFFA78BFA),
    Color(0xFFEC4899),
  ];

  // ============================================================
  // SELECTED COLOR
  // ============================================================

  Color? _selectedColor;

  // ============================================================
  // CUSTOM COLOR
  // ============================================================

  Color _customColor = Colors.white;

  bool _showCustomPicker = false;

  // ============================================================
  // APPLY COLOR
  // ============================================================

  void _applyColor(Color color) {
    widget.controller.formatSelection(
      ParchmentAttribute.foregroundColor.withValue(color.value),
    );

    if (mounted) {
      setState(() {
        _selectedColor = color;
        _customColor = color;
      });
    }

    widget.onColorChanged?.call();

    // بستن Bottom Sheet بعد از انتخاب رنگ
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // ============================================================
  // OPEN CUSTOM PICKER
  // ============================================================

  void _openCustomColorPicker() {
    setState(() {
      _showCustomPicker = true;
    });
  }

  // ============================================================
  // APPLY CUSTOM COLOR
  // ============================================================

  void _applyCustomColor() {
    _applyColor(_customColor);
  }

  // ============================================================
  // REMOVE COLOR
  // ============================================================

  void _removeColor() {
    widget.controller.formatSelection(ParchmentAttribute.foregroundColor.unset);

    if (mounted) {
      setState(() {
        _selectedColor = null;
      });
    }

    widget.onColorChanged?.call();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // ============================================================
  // COLOR ITEM
  // ============================================================

  Widget _buildColorItem(Color color) {
    final bool isSelected = _selectedColor?.value == color.value;

    return GestureDetector(
      onTap: () {
        _applyColor(color);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: isSelected
              ? Icon(
                  Icons.check,
                  size: 19,
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                )
              : null,
        ),
      ),
    );
  }

  // ============================================================
  // RESET ITEM
  // ============================================================

  Widget _buildResetItem() {
    final bool isSelected = _selectedColor == null;

    return GestureDetector(
      onTap: _removeColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF292C33),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.format_color_reset,
          color: isSelected ? Colors.white : Colors.white70,
          size: 20,
        ),
      ),
    );
  }

  // ============================================================
  // CUSTOM COLOR ITEM
  // ============================================================

  Widget _buildCustomColorItem() {
    return GestureDetector(
      onTap: _openCustomColorPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _showCustomPicker ? Colors.white : Colors.white24,
            width: _showCustomPicker ? 2.5 : 1,
          ),
          boxShadow: _showCustomPicker
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.cyan,
                Colors.blue,
                Colors.purple,
                Colors.red,
              ],
            ),
          ),
          child: const Icon(Icons.colorize, color: Colors.white, size: 19),
        ),
      ),
    );
  }

  // ============================================================
  // CUSTOM PICKER
  // ============================================================

  Widget _buildCustomPicker() {
    return Column(
      children: [
        // --------------------------------------------------------
        // BACK
        // --------------------------------------------------------
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _showCustomPicker = false;
              });
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 20),
            label: const Text(
              'Back to colors',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // --------------------------------------------------------
        // COLOR PICKER
        // --------------------------------------------------------
        ColorPicker(
          pickerColor: _customColor,
          onColorChanged: (color) {
            setState(() {
              _customColor = color;
            });
          },
          enableAlpha: false,
          displayThumbColor: true,
          pickerAreaHeightPercent: 0.8,
        ),

        const SizedBox(height: 12),

        // --------------------------------------------------------
        // PREVIEW
        // --------------------------------------------------------
        Row(
          children: [
            const Text(
              'Selected:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(width: 12),

            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _customColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
            ),

            const Spacer(),

            Text(
              '#${_customColor.value.toRadixString(16).substring(2).toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // --------------------------------------------------------
        // APPLY
        // --------------------------------------------------------
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: _applyCustomColor,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF2A2D35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Apply',
              style: TextStyle(
                color: Color(0xFFF5C65D),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double bottomInset = mediaQuery.viewInsets.bottom;

    final double availableHeight = mediaQuery.size.height - bottomInset;

    final double maxSheetHeight = availableHeight * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF202126),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ==================================================
                  // HANDLE
                  // ==================================================
                  Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // ==================================================
                  // TITLE
                  // ==================================================
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _showCustomPicker ? 'Custom Color' : 'Text Color',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // CONTENT
                  // ==================================================
                  if (_showCustomPicker)
                    _buildCustomPicker()
                  else ...[
                    // ================================================
                    // PALETTE
                    // ================================================
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildResetItem(),

                        ..._colors.map((color) => _buildColorItem(color)),

                        _buildCustomColorItem(),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ================================================
                    // DONE
                    // ================================================
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2D35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
