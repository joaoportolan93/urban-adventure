import 'package:flutter/foundation.dart';

@immutable
class Folder {
  final String id;
  final String name;
  final List<String> albumIds;
  final DateTime createdAt;

  const Folder({
    required this.id,
    required this.name,
    required this.albumIds,
    required this.createdAt,
  });

  static const String defaultFolderName = 'Ouvir depois';

  factory Folder.createDefault() {
    return Folder(
      id: 'default_listen_later',
      name: defaultFolderName,
      albumIds: const [],
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'albumIds': albumIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Folder.fromMap(Map<dynamic, dynamic> map) {
    return Folder(
      id: map['id'] as String,
      name: map['name'] as String? ?? defaultFolderName,
      albumIds: (map['albumIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Folder copyWith({
    String? id,
    String? name,
    List<String>? albumIds,
    DateTime? createdAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      albumIds: albumIds ?? this.albumIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Folder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

