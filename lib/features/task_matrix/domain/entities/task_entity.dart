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
    this.sortOrder,
  });

  final String id;
  final String title;
  final String description;
  final Quadrant quadrant;
  final DateTime? dueDate;
  final List<String> tags;
  final bool isCompleted;
  final DateTime createdAt;

  /// Manual position within the task's quadrant, set by drag-to-reorder.
  /// Null until the task is first reordered or moved.
  final int? sortOrder;

  /// Tasks that have never been positioned fall back to their creation time,
  /// which is always larger than a reordered index — so new tasks land at the
  /// bottom of their quadrant without having to look up the current maximum.
  int get effectiveSortOrder => sortOrder ?? createdAt.millisecondsSinceEpoch;

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
    int? sortOrder,
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
      sortOrder: sortOrder ?? this.sortOrder,
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
        sortOrder,
      ];
}
