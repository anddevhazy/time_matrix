import '../../domain/entities/dump_entry.dart';

class DumpEntryModel extends DumpEntry {
  const DumpEntryModel({
    required super.id,
    required super.text,
    required super.createdAt,
  });

  factory DumpEntryModel.fromEntity(DumpEntry entity) => DumpEntryModel(
        id: entity.id,
        text: entity.text,
        createdAt: entity.createdAt,
      );

  factory DumpEntryModel.fromJson(Map<String, dynamic> json) => DumpEntryModel(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
}
