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

  /// Tasks in [quadrant] that match the search, in their manual order.
  List<TaskEntity> tasksFor(Quadrant quadrant) => _inOrder(visibleTasks, quadrant);

  /// Every task in [quadrant] in its manual order, ignoring the search query.
  List<TaskEntity> allTasksFor(Quadrant quadrant) => _inOrder(tasks, quadrant);

  static List<TaskEntity> _inOrder(List<TaskEntity> source, Quadrant quadrant) {
    final filtered = source.where((t) => t.quadrant == quadrant).toList();
    filtered.sort((a, b) {
      final byOrder = a.effectiveSortOrder.compareTo(b.effectiveSortOrder);
      return byOrder != 0 ? byOrder : a.createdAt.compareTo(b.createdAt);
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
