import 'dart:convert';

import 'package:flutter/material.dart';

/// یه رندرر سبک برای نمایش خروجی Quill Delta (JSON) به‌صورت Text.rich،
/// بدون نیاز به خود ویجت QuillEditor. برای preview بلاک‌های نهایی شده
/// (توی FreeNoteEditor) و کارت خونه (BlockNoteCard) استفاده می‌شه.
///
/// اگه deltaJson یه Delta معتبر نباشه (مثلاً داده‌ی قدیمی که هنوز
/// plain text بوده)، همون رشته رو عیناً با baseStyle نشون می‌ده.
class QuillDeltaText extends StatelessWidget {
  final String deltaJson;
  final TextStyle baseStyle;
  final int? maxLines;
  final TextOverflow overflow;

  const QuillDeltaText({
    super.key,
    required this.deltaJson,
    required this.baseStyle,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  List<InlineSpan> _buildSpans() {
    List<dynamic> opsJson;

    try {
      final decoded = jsonDecode(deltaJson);
      if (decoded is List) {
        opsJson = decoded;
      } else if (decoded is Map && decoded['ops'] is List) {
        opsJson = decoded['ops'] as List;
      } else {
        return [TextSpan(text: deltaJson, style: baseStyle)];
      }
    } catch (_) {
      return [TextSpan(text: deltaJson, style: baseStyle)];
    }

    final spans = <InlineSpan>[];

    for (final op in opsJson) {
      if (op is! Map) continue;

      final insert = op['insert'];
      if (insert is! String) continue; // embed (تصویر و ...) رو رد کن

      final attrs = (op['attributes'] as Map?) ?? {};

      double fontSize = baseStyle.fontSize ?? 14;
      FontWeight weight = baseStyle.fontWeight ?? FontWeight.w400;

      final header = attrs['header'];
      if (header == 1) {
        fontSize += 6;
        weight = FontWeight.w700;
      } else if (header == 2) {
        fontSize += 3;
        weight = FontWeight.w600;
      }

      if (attrs['bold'] == true) weight = FontWeight.w700;

      Color? color = baseStyle.color;
      if (attrs['color'] is String) {
        color = _colorFromHex(attrs['color'] as String) ?? color;
      }

      Color? background;
      if (attrs['background'] is String) {
        background = _colorFromHex(attrs['background'] as String);
      }

      TextDecoration decoration = TextDecoration.none;
      final underline = attrs['underline'] == true;
      final strike = attrs['strike'] == true;
      if (underline && strike) {
        decoration = TextDecoration.combine([
          TextDecoration.underline,
          TextDecoration.lineThrough,
        ]);
      } else if (underline) {
        decoration = TextDecoration.underline;
      } else if (strike) {
        decoration = TextDecoration.lineThrough;
      }

      spans.add(
        TextSpan(
          text: insert,
          style: baseStyle.copyWith(
            fontSize: fontSize,
            fontWeight: weight,
            fontStyle: attrs['italic'] == true
                ? FontStyle.italic
                : FontStyle.normal,
            decoration: decoration,
            color: color,
            backgroundColor: background,
          ),
        ),
      );
    }

    return spans;
  }

  Color? _colorFromHex(String hex) {
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final value = int.tryParse(h, radix: 16);
    return value == null ? null : Color(value);
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: _buildSpans()),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
