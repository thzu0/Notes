import 'package:flutter/material.dart';
import 'note_colors.dart';

class NoteTextStyle {
  //===Headings===
  static const TextStyle headingTitleApp = TextStyle(
    fontSize: 33,
    color: AppColors.textPriamry,
  );
  //Notes and Daily Notes style

  static const TextStyle headingTitleCard = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPriamry,
  );
  //Title of card like "Reminder" and "Quote Today"

  //===Body===
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPriamry,
  );
  //Font of like name of Folder and Items in checkList

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondery,
  );
  //Font of like info of card and decription

  //=== Small / Caption ===
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );
  //Lable of Category and date of card

  static const TextStyle descriptionOnboarding = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondery,
    height: 1.5, // فاصله بین خطوط، برای خوانایی بهتر متن دو خطی
  );
  //Description text under "Daily Notes" title on onboarding page

  //===Buttons===
  static const TextStyle button = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPriamry,
  );
  //Text of buttons like "Get Started"

  // ===== Tabs =====
  static const TextStyle tabActive = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryPurple,
  ); //Like connect tab "All"

  static const TextStyle tabInactive = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  ); //Like disconnect tab "Folder"
}
