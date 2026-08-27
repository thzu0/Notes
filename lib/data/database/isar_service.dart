import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/note_db.dart';
import 'models/folder_db.dart';

///modeir asli etesal be database

class IsarService {
  static Isar? _isar;

  static Future<Isar?> open() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar;
    }
    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open([
      NoteDbSchema,
      FolderDbSchema,
    ], directory: dir.path);
    return _isar!;
  }

  static Isar get instance {
    if (_isar == null || !_isar!.isOpen) {
      throw Exception(
        'Isar had not been initialized . Call IsarService.opne first.',
      );
    }
    return _isar!;
  }
}
