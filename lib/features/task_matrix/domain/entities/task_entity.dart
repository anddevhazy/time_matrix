import 'package:equatable/equatable.dart';

import 'quadrant.dart';

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.quadrant,
    this.description = '',
    this.dueDate,
    this.tags = const [],
    this.isCompleted = false,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final Quadrant quadrant;
  final DateTime? dueDate;
  final List<String> tags;
  final bool isCompleted;
  final DateTime createdAt;

  bool get isOverdue =>
      dueDate != null && !isCompleted && dueDate!.isBefore(DateTime.now());

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    Quadrant? quadrant,
    DateTime? dueDate,
    bool clearDueDate = false,
    List<String>? tags,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      quadrant: quadrant ?? this.quadrant,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        quadrant,
        dueDate,
        tags,
        isCompleted,
        createdAt,
      ];
}
