import 'package:isar/isar.dart';

part 'folder_db.g.dart';

@collection
class FolderDb {
  Id id = Isar.autoIncrement;

  late String folderId;

  String name = '';

  int colorValue = 0;
}
