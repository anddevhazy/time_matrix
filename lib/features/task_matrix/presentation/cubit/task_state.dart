part of 'task_cubit.dart';

sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  const TaskLoaded({
    required this.tasks,
    this.searchQuery = '',
  });

  final List<TaskEntity> tasks;
  final String searchQuery;

  /// Tasks after the search query has been applied, still unsorted-by-quadrant.
  List<TaskEntity> get visibleTasks {
    if (searchQuery.isEmpty) return tasks;
    return tasks.where((task) {
      return task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          task.tags.any((t) => t.toLowerCase().contains(searchQuery.toLowerCase()));
    }).toList();
  }

  List<TaskEntity> tasksFor(Quadrant quadrant) {
    final filtered = visibleTasks.where((t) => t.quadrant == quadrant).toList();
    filtered.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      final aDue = a.dueDate;
      final bDue = b.dueDate;
      if (aDue == null && bDue == null) return b.createdAt.compareTo(a.createdAt);
      if (aDue == null) return 1;
      if (bDue == null) return -1;
      return aDue.compareTo(bDue);
    });
    return filtered;
  }

  TaskLoaded copyWith({
    List<TaskEntity>? tasks,
    String? searchQuery,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [tasks, searchQuery];
}

class TaskError extends TaskState {
  const TaskError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
