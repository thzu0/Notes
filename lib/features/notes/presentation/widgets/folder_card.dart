import 'package:flutter/material.dart';

import '../../../../core/note_colors.dart';

import '../../model/model_folder.dart';

class FolderCard extends StatelessWidget {
  final Folder folder;
  const FolderCard({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Icon(Icons.folder, size: 110, color: AppColors.folderYellow),
          ),
          SizedBox(height: 16),
          Text(
            folder.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppColors.textPriamry,
            ),
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}
