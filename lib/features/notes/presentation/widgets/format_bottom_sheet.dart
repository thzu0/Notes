import 'package:flutter/material.dart';
import 'package:notes_app/features/notes/model/model.dart';

/// بات‌شیت فرمت‌بندی متن که با زدن آیکون "Aa" باز میشه.
///
/// هر تغییری که کاربر بده (heading، بولد/ایتالیک/آندرلاین، لیست،
/// رنگ متن، رنگ هایلایت) فوراً از طریق onChanged به بیرون گزارش
/// می‌شه، بدون نیاز به دکمه‌ی "Apply" یا وابستگی به نحوه‌ی بسته‌شدن شیت.
///
/// استفاده:
/// showModalBottomSheet(
///   context: context,
///   backgroundColor: Colors.transparent,
///   isScrollControlled: true,
///   builder: (_) => FormatBottomSheet(
///     initialStyle: currentStyle,
///     onChanged: (style) => setState(() => currentStyle = style),
///   ),
/// );
class FormatBottomSheet extends StatefulWidget {
  final TextFormatStyle initialStyle;
  final ValueChanged<TextFormatStyle> onChanged;

  const FormatBottomSheet({
    super.key,
    this.initialStyle = const TextFormatStyle(),
    required this.onChanged,
  });

  @override
  State<FormatBottomSheet> createState() => _FormatBottomSheetState();
}

class _FormatBottomSheetState extends State<FormatBottomSheet> {
  static const Color _sheetBg = Color(0xFF1C1E24);
  static const Color _chipBg = Color(0xFF2A2D35);
  static const Color _textColor = Color(0xFFE5E7EB);
  static const Color _mutedColor = Color(0xFF9AA0A6);

  late HeadingType _selectedHeading;
  late bool _isBold;
  late bool _isItalic;
  late bool _isUnderline;
  late bool _isBulletList;
  late bool _isNumberedList;
  late Color _selectedTextColor;
  Color? _selectedHighlightColor;

  final List<Color> _textColors = const [
    Colors.white,
    Color(0xFF9AA0A6), // خاکستری
    Colors.black,
    Color(0xFFE53935), // قرمز
    Color(0xFFFB8C00), // نارنجی
    Color(0xFFFDD835), // زرد
    Color(0xFF43A047), // سبز
  ];

  final List<Color> _highlightColors = const [
    Color(0xFFD98A8A), // صورتی کم‌رنگ
    Color(0xFFB5834A), // قهوه‌ای
    Color(0xFFB5B24A), // زیتونی
    Color(0xFF6FBF5C), // سبز
    Color(0xFF5CBFB0), // فیروزه‌ای
    Color(0xFF9B7CD9), // بنفش
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();

    final initial = widget.initialStyle;

    _selectedHeading = initial.heading;
    _isBold = initial.isBold;
    _isItalic = initial.isItalic;
    _isUnderline = initial.isUnderline;
    _isBulletList = initial.isBulletList;
    _isNumberedList = initial.isNumberedList;
    _selectedTextColor = initial.textColor;
    _selectedHighlightColor = initial.highlightColor;
  }

  void _emitChange() {
    widget.onChanged(
      TextFormatStyle(
        heading: _selectedHeading,
        isBold: _isBold,
        isItalic: _isItalic,
        isUnderline: _isUnderline,
        isBulletList: _isBulletList,
        isNumberedList: _isNumberedList,
        textColor: _selectedTextColor,
        highlightColor: _selectedHighlightColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  'Format',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _mutedColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Heading 1 / Heading 2 / TXT
            Row(
              children: [
                _StyleTextButton(
                  label: 'Heading 1',
                  selected: _selectedHeading == HeadingType.heading1,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  onTap: () {
                    setState(() => _selectedHeading = HeadingType.heading1);
                    _emitChange();
                  },
                ),
                const SizedBox(width: 24),
                _StyleTextButton(
                  label: 'Heading 2',
                  selected: _selectedHeading == HeadingType.heading2,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  onTap: () {
                    setState(() => _selectedHeading = HeadingType.heading2);
                    _emitChange();
                  },
                ),
                const Spacer(),
                _TxtButton(
                  selected: _selectedHeading == HeadingType.none,
                  onTap: () {
                    setState(() => _selectedHeading = HeadingType.none);
                    _emitChange();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bold / Italic / Underline + لیست‌ها
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _chipBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _ToggleIconButton(
                          icon: Icons.format_bold,
                          active: _isBold,
                          onTap: () {
                            setState(() => _isBold = !_isBold);
                            _emitChange();
                          },
                        ),
                        _ToggleIconButton(
                          icon: Icons.format_italic,
                          active: _isItalic,
                          onTap: () {
                            setState(() => _isItalic = !_isItalic);
                            _emitChange();
                          },
                        ),
                        _ToggleIconButton(
                          icon: Icons.format_underline,
                          active: _isUnderline,
                          onTap: () {
                            setState(() => _isUnderline = !_isUnderline);
                            _emitChange();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _ToggleIconButton(
                    icon: Icons.format_list_bulleted,
                    active: _isBulletList,
                    onTap: () {
                      setState(() {
                        _isBulletList = !_isBulletList;
                        if (_isBulletList) _isNumberedList = false;
                      });
                      _emitChange();
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    color: _chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _ToggleIconButton(
                    icon: Icons.format_list_numbered,
                    active: _isNumberedList,
                    onTap: () {
                      setState(() {
                        _isNumberedList = !_isNumberedList;
                        if (_isNumberedList) _isBulletList = false;
                      });
                      _emitChange();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // رنگ متن
            _ColorSwatchRow(
              leadingIcon: Icons.format_color_text,
              leadingIconColor: _selectedTextColor == Colors.black
                  ? Colors.white
                  : _selectedTextColor,
              colors: _textColors,
              selectedColor: _selectedTextColor,
              onColorSelected: (color) {
                setState(() => _selectedTextColor = color);
                _emitChange();
              },
            ),
            const SizedBox(height: 12),

            // رنگ هایلایت
            _ColorSwatchRow(
              leadingIcon: Icons.format_color_fill,
              leadingIconColor: const Color(0xFFF5A623),
              colors: _highlightColors,
              selectedColor: _selectedHighlightColor,
              onColorSelected: (color) {
                setState(() => _selectedHighlightColor = color);
                _emitChange();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleTextButton extends StatelessWidget {
  final String label;
  final bool selected;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onTap;

  const _StyleTextButton({
    required this.label,
    required this.selected,
    required this.fontSize,
    required this.fontWeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF9AA0A6),
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

class _TxtButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _TxtButton({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2F6FED) : const Color(0xFF2A2D35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'TXT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ToggleIconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleIconButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3A3D47) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : const Color(0xFFC7CAD1),
          size: 20,
        ),
      ),
    );
  }
}

/// یک ردیف اسکرول‌شونده از دایره‌های رنگی، به همراه یک آیکون ابتدایی (مثلاً A زیرخط‌دار)
class _ColorSwatchRow extends StatelessWidget {
  final IconData leadingIcon;
  final Color leadingIconColor;
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorSwatchRow({
    required this.leadingIcon,
    required this.leadingIconColor,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D35),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(leadingIcon, color: leadingIconColor, size: 20),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: Colors.white24),
          const SizedBox(width: 12),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = selectedColor == color;
                return GestureDetector(
                  onTap: () => onColorSelected(color),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
