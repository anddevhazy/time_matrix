import '../../domain/entities/dump_entry.dart';

class DumpEntryModel extends DumpEntry {
  const DumpEntryModel({
    required super.id,
    required super.text,
    required super.createdAt,
    super.sortOrder,
  });

  factory DumpEntryModel.fromEntity(DumpEntry entity) => DumpEntryModel(
        id: entity.id,
        text: entity.text,
        createdAt: entity.createdAt,
        sortOrder: entity.sortOrder,
      );

  factory DumpEntryModel.fromJson(Map<String, dynamic> json) => DumpEntryModel(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        sortOrder: (json['sortOrder'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'sortOrder': sortOrder,
      };
}
