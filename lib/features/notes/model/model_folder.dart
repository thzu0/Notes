import 'package:flutter/material.dart';

class Folder {
  final String id;
  final String name;

  final Color colorValue;

  Folder({required this.id, required this.name, required this.colorValue});

  Folder copyWith({
    String? id,
    String? name,
    int? noteCount,
    Color? colorValue,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,

      colorValue: colorValue ?? this.colorValue,
    );
  }
}
