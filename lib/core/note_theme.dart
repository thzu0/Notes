import 'package:flutter/material.dart';
import 'note_colors.dart';
import 'note_text_style.dart';

class NoteTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark, //because UI is navy
      scaffoldBackgroundColor:
          AppColors.background, //background color of all page
      primaryColor: AppColors.primaryPurple, //main color of app
      //=== Color Scheme ===
      colorScheme: ColorScheme(
        brightness: Brightness.dark, // روشنایی کلی تم (تیره)
        error: Color(
          0xFFE74C3C,
        ), // رنگ خطا (قرمز، برای پیام‌های ارور و اعتبارسنجی)
        onError: AppColors.textPriamry, //رنگ متن روی پس‌زمینه ارور
        primary: AppColors.primaryPurple, //رنگ اصلی (دکمه‌ها، آیکون فعال)
        secondary: AppColors.folderYellow, //رنگ ثانویه (زرد فولدرها)
        surface: AppColors.darkCardBackground, //پس‌زمینه کارت‌ها و سطوح
        onPrimary: AppColors.textPriamry, //رنگ متن روی primary
        onSecondary: AppColors.textPriamry, //رنگ متن روی secondary
        onSurface: AppColors.textPriamry, //رنگ متن روی surface
      ),

      //=== AppBar ===
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: NoteTextStyle.headingTitleApp,
        iconTheme: IconThemeData(color: AppColors.textPriamry),
      ),

      //=== Text Theme ===
      textTheme: TextTheme(
        headlineLarge: NoteTextStyle.headingTitleApp,
        headlineMedium: NoteTextStyle.headingTitleCard,
        bodyLarge: NoteTextStyle.bodyMedium,
        bodyMedium: NoteTextStyle.bodyRegular,
        bodySmall: NoteTextStyle.caption,
        labelLarge: NoteTextStyle.button,
      ),

      //=== Card ===
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),

      //=== Elevated Button ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.textPriamry,
          textStyle: NoteTextStyle.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
      ),

      //=== Floating Action Button ====
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.textPriamry,
        elevation: 4,
      ),

      //=== Divider ===
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),

      //=== Icon ===
      iconTheme: const IconThemeData(color: AppColors.textSecondery),

      //=== Checkbox ==
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return AppColors.checkBlueTargets; //وقتی تیک خورده، آبی می‌شه
          }
          return Colors.transparent; // وقتی خالیه، بدون رنگ پرشده
        }),
        checkColor: WidgetStateProperty.all(AppColors.textPriamry),
        side: const BorderSide(
          color: AppColors.textMuted,
          width: 1.5,
        ), //لبه چک‌باکس خالی
      ),

      //=== Input Decoration ===
      //theme for feild of search and popmenue and other
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardBackground,
        hintStyle: NoteTextStyle.bodyRegular,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // بدون خط دور فیلد
        ),
      ),
    );
  }
}
