import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';

class FormatBottomSheet extends StatefulWidget {
  final FleatherController controller;

  final VoidCallback? onFormatChanged;

  const FormatBottomSheet({
    super.key,
    required this.controller,
    this.onFormatChanged,
  });

  @override
  State<FormatBottomSheet> createState() => _FormatBottomSheetState();
}

class _FormatBottomSheetState extends State<FormatBottomSheet> {
  FleatherController get controller => widget.controller;

  // ============================================================
  // ACTIVE STATE
  // ============================================================

  bool _isActive(ParchmentAttribute attribute) {
    final style = controller.getSelectionStyle();

    return style.containsSame(attribute) ||
        controller.toggledStyles.containsSame(attribute);
  }

  // ============================================================
  // INLINE FORMAT
  // ============================================================

  void _toggleInline(ParchmentAttribute attribute) {
    final bool active =
        controller.getSelectionStyle().containsSame(attribute) ||
        controller.toggledStyles.containsSame(attribute);

    if (active) {
      controller.formatSelection(attribute.unset);
    } else {
      controller.formatSelection(attribute);
    }

    widget.onFormatChanged?.call();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // LINE FORMAT
  // ============================================================

  void _applyLine(ParchmentAttribute attribute) {
    controller.formatSelection(attribute);

    widget.onFormatChanged?.call();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // BLOCK TOGGLE
  // ============================================================

  void _toggleBlock(ParchmentAttribute attribute) {
    final bool active = controller.getSelectionStyle().containsSame(attribute);

    if (active) {
      controller.formatSelection(attribute.unset);
    } else {
      controller.formatSelection(attribute);
    }

    widget.onFormatChanged?.call();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
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
                // BOLD / ITALIC / UNDERLINE / STRIKE
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_bold,
                        active: _isActive(ParchmentAttribute.bold),
                        onPressed: () {
                          _toggleInline(ParchmentAttribute.bold);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_italic,
                        active: _isActive(ParchmentAttribute.italic),
                        onPressed: () {
                          _toggleInline(ParchmentAttribute.italic);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_underline,
                        active: _isActive(ParchmentAttribute.underline),
                        onPressed: () {
                          _toggleInline(ParchmentAttribute.underline);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _FormatButton(
                        icon: Icons.strikethrough_s,
                        active: _isActive(ParchmentAttribute.strikethrough),
                        onPressed: () {
                          _toggleInline(ParchmentAttribute.strikethrough);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ==================================================
                // HEADINGS
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: _TextFormatButton(
                        text: 'H1',
                        active: _isActive(ParchmentAttribute.h1),
                        onPressed: () {
                          _applyLine(ParchmentAttribute.h1);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _TextFormatButton(
                        text: 'H2',
                        active: _isActive(ParchmentAttribute.h2),
                        onPressed: () {
                          _applyLine(ParchmentAttribute.h2);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _TextFormatButton(
                        text: 'H3',
                        active: _isActive(ParchmentAttribute.h3),
                        onPressed: () {
                          _applyLine(ParchmentAttribute.h3);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _TextFormatButton(
                        text: 'H4',
                        active: _isActive(ParchmentAttribute.h4),
                        onPressed: () {
                          _applyLine(ParchmentAttribute.h4);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ==================================================
                // LISTS
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_list_bulleted,
                        active: _isActive(ParchmentAttribute.ul),
                        onPressed: () {
                          _toggleBlock(ParchmentAttribute.ul);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_list_numbered,
                        active: _isActive(ParchmentAttribute.ol),
                        onPressed: () {
                          _toggleBlock(ParchmentAttribute.ol);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_quote,
                        active: _isActive(ParchmentAttribute.bq),
                        onPressed: () {
                          _toggleBlock(ParchmentAttribute.bq);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ==================================================
                // ALIGNMENT
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_align_left,
                        active: _isActive(ParchmentAttribute.left),
                        onPressed: () {
                          _applyLine(ParchmentAttribute.left);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_align_center,
                        active: _isActive(ParchmentAttribute.center),
                        onPressed: () {
                          _applyLine(ParchmentAttribute.center);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_align_right,
                        active: _isActive(ParchmentAttribute.right),
                        onPressed: () {
                          _applyLine(ParchmentAttribute.right);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _FormatButton(
                        icon: Icons.format_align_justify,
                        active: _isActive(ParchmentAttribute.justify),
                        onPressed: () {
                          _applyLine(ParchmentAttribute.justify);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ==================================================
                // DONE
                // ==================================================
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
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ICON BUTTON
// ================================================================

class _FormatButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onPressed;

  const _FormatButton({
    required this.icon,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFF3A3D47) : const Color(0xFF292C33),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          child: Icon(
            icon,
            color: active ? Colors.white : Colors.grey.shade400,
            size: 21,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// TEXT BUTTON
// ================================================================

class _TextFormatButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onPressed;

  const _TextFormatButton({
    required this.text,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFF3A3D47) : const Color(0xFF292C33),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey.shade400,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
