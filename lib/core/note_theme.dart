import 'package:flutter/material.dart';
import 'note_colors.dart';
import 'note_text_style.dart';

class NoteTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      // ==========================================================
      // GENERAL
      // ==========================================================
      brightness: Brightness.dark,

      fontFamily: 'Vazirmatn',

      scaffoldBackgroundColor: AppColors.background,

      primaryColor: AppColors.primaryPurple,

      useMaterial3: true,

      // ==========================================================
      // COLOR SCHEME
      // ==========================================================
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryPurple,
        onPrimary: AppColors.textPriamry,

        secondary: AppColors.folderYellow,
        onSecondary: AppColors.textPriamry,

        error: Color(0xFFE74C3C),
        onError: AppColors.textPriamry,

        surface: AppColors.darkCardBackground,
        onSurface: AppColors.textPriamry,
      ),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,

        titleTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPriamry,
        ),

        iconTheme: IconThemeData(color: AppColors.textPriamry),
      ),

      // ==========================================================
      // TEXT THEME
      // ==========================================================
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPriamry,
        ),

        displayMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPriamry,
        ),

        headlineLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPriamry,
        ),

        headlineMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPriamry,
        ),

        headlineSmall: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPriamry,
        ),

        titleLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPriamry,
        ),

        titleMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPriamry,
        ),

        titleSmall: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPriamry,
        ),

        bodyLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPriamry,
        ),

        bodyMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPriamry,
        ),

        bodySmall: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondery,
        ),

        labelLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPriamry,
        ),

        labelMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondery,
        ),

        labelSmall: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondery,
        ),
      ),

      // ==========================================================
      // CARD
      // ==========================================================
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 0,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ==========================================================
      // ELEVATED BUTTON
      // ==========================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.textPriamry,

          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),

          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          elevation: 0,
        ),
      ),

      // ==========================================================
      // TEXT BUTTON
      // ==========================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPriamry,

          textStyle: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ==========================================================
      // FLOATING ACTION BUTTON
      // ==========================================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: AppColors.textPriamry,
        elevation: 4,
      ),

      // ==========================================================
      // DIVIDER
      // ==========================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ==========================================================
      // ICON
      // ==========================================================
      iconTheme: const IconThemeData(color: AppColors.textSecondery, size: 22),

      // ==========================================================
      // CHECKBOX
      // ==========================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return AppColors.checkBlueTargets;
          }

          return Colors.transparent;
        }),

        checkColor: WidgetStateProperty.all(AppColors.textPriamry),

        side: const BorderSide(color: AppColors.textMuted, width: 1.5),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      // ==========================================================
      // INPUT DECORATION
      // ==========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: AppColors.darkCardBackground,

        hintStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondery,
        ),

        labelStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondery,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(
            color: AppColors.primaryPurple,
            width: 1.2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // ==========================================================
      // DROPDOWN
      // ==========================================================
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPriamry,
        ),

        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            AppColors.darkCardBackground,
          ),

          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),

      // ==========================================================
      // TOOLTIP
      // ==========================================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D35),
          borderRadius: BorderRadius.circular(8),
        ),

        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 12,
          color: Colors.white,
        ),

        waitDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
