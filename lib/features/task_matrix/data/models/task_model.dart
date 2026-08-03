import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.quadrant,
    super.description,
    super.dueDate,
    super.tags,
    super.isCompleted,
    required super.createdAt,
  });

  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        quadrant: entity.quadrant,
        dueDate: entity.dueDate,
        tags: entity.tags,
        isCompleted: entity.isCompleted,
        createdAt: entity.createdAt,
      );

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        quadrant: Quadrant.fromName(json['quadrant'] as String),
        dueDate: json['dueDate'] == null ? null : DateTime.tryParse(json['dueDate'] as String),
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        isCompleted: json['isCompleted'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'quadrant': quadrant.name,
        'dueDate': dueDate?.toIso8601String(),
        'tags': tags,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };
}
