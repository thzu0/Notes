import 'package:flutter/material.dart';

import '../../model/model_folder.dart';
import 'folder_card.dart';

class FolderCardBuilder extends StatelessWidget {
  final Folder folder;

  const FolderCardBuilder({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return FolderCard(folder: folder);
  }
}
