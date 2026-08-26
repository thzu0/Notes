import 'package:flutter/material.dart';

import '../../../../core/note_colors.dart';
import '../../model/model_folder.dart';

class FolderCard extends StatelessWidget {
  final Folder folder;

  const FolderCard({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ==================================================
          // FOLDER ICON
          // ==================================================
          Flexible(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(Icons.folder, size: 110, color: folder.colorValue),
            ),
          ),

          const SizedBox(height: 12),

          // ==================================================
          // FOLDER NAME
          // ==================================================
          Text(
            folder.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColors.textPriamry,
            ),
          ),
        ],
      ),
    );
  }
}
