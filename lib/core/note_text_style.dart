import 'package:flutter/material.dart';

import 'note_colors.dart';

class NoteTextStyle {
  // ============================================================
  // HEADINGS
  // ============================================================

  static const TextStyle headingTitleApp = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPriamry,
  );

  // Notes and Daily Notes style
  static const TextStyle headingTitleCard = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.textPriamry,
  );

  // ============================================================
  // BODY
  // ============================================================

  // Font for folder names, checklist items, etc.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPriamry,
  );

  // Font for secondary text and descriptions
  static const TextStyle bodyRegular = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondery,
  );

  // ============================================================
  // SMALL / CAPTION
  // ============================================================

  static const TextStyle caption = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // ============================================================
  // ONBOARDING DESCRIPTION
  // ============================================================

  static const TextStyle descriptionOnboarding = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondery,
    height: 1.5,
  );

  // ============================================================
  // BUTTONS
  // ============================================================

  static const TextStyle button = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPriamry,
  );

  // ============================================================
  // TABS
  // ============================================================

  static const TextStyle tabActive = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryPurple,
  );

  static const TextStyle tabInactive = TextStyle(
    fontFamily: 'Vazirmatn',
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
