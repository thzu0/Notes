import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../isar_service.dart';
import '../models/folder_db.dart';

import '../../../features/notes/model/model_folder.dart';

class FolderRepository {
  final Isar _isar;

  FolderRepository({Isar? isar}) : _isar = isar ?? IsarService.instance;

  // ============================================================
  // CREATE
  // ============================================================

  Future<void> saveFolder(Folder folder) async {
    final folderDb = _toDb(folder);

    await _isar.writeTxn(() async {
      await _isar.folderDbs.put(folderDb);
    });
  }

  // ============================================================
  // READ - ALL
  // ============================================================

  Future<List<Folder>> getFolders() async {
    final foldersDb = await _isar.folderDbs.where().findAll();

    return foldersDb.map(_fromDb).toList();
  }

  // ============================================================
  // READ - ONE
  // ============================================================

  Future<Folder?> getFolderById(String folderId) async {
    final folderDb = await _isar.folderDbs
        .filter()
        .folderIdEqualTo(folderId)
        .findFirst();

    if (folderDb == null) {
      return null;
    }

    return _fromDb(folderDb);
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updateFolder(Folder folder) async {
    final existingFolderDb = await _isar.folderDbs
        .filter()
        .folderIdEqualTo(folder.id)
        .findFirst();

    if (existingFolderDb == null) {
      throw Exception('Folder not found: ${folder.id}');
    }

    final updatedFolderDb = _toDb(folder);

    updatedFolderDb.id = existingFolderDb.id;

    await _isar.writeTxn(() async {
      await _isar.folderDbs.put(updatedFolderDb);
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteFolder(String folderId) async {
    final folderDb = await _isar.folderDbs
        .filter()
        .folderIdEqualTo(folderId)
        .findFirst();

    if (folderDb == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.folderDbs.delete(folderDb.id);
    });
  }

  // ============================================================
  // FOLDER → FOLDER DB
  // ============================================================

  FolderDb _toDb(Folder folder) {
    return FolderDb()
      ..folderId = folder.id
      ..name = folder.name
      ..colorValue = folder.colorValue.value;
  }

  // ============================================================
  // FOLDER DB → FOLDER
  // ============================================================

  Folder _fromDb(FolderDb folderDb) {
    return Folder(
      id: folderDb.folderId,
      name: folderDb.name,
      colorValue: Color(folderDb.colorValue),
    );
  }
}
