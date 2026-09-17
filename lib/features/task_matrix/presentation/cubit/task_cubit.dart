import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../global/core/error/failures.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/reorder_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/watch_tasks_usecase.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({
    required WatchTasksUsecase watchTasksUsecase,
    required AddTaskUsecase addTaskUsecase,
    required UpdateTaskUsecase updateTaskUsecase,
    required DeleteTaskUsecase deleteTaskUsecase,
    required ReorderTasksUsecase reorderTasksUsecase,
  })  : _watchTasksUsecase = watchTasksUsecase,
        _addTaskUsecase = addTaskUsecase,
        _updateTaskUsecase = updateTaskUsecase,
        _deleteTaskUsecase = deleteTaskUsecase,
        _reorderTasksUsecase = reorderTasksUsecase,
        super(const TaskInitial());

  final WatchTasksUsecase _watchTasksUsecase;
  final AddTaskUsecase _addTaskUsecase;
  final UpdateTaskUsecase _updateTaskUsecase;
  final DeleteTaskUsecase _deleteTaskUsecase;
  final ReorderTasksUsecase _reorderTasksUsecase;

  StreamSubscription<Either<Failure, List<TaskEntity>>>? _subscription;

  /// Subscribes to the signed-in user's tasks. Firestore keeps this stream
  /// updated in realtime, so edits on another device land here automatically.
  Future<void> loadTasks() async {
    emit(const TaskLoading());
    await _subscription?.cancel();
    _subscription = _watchTasksUsecase().listen((result) {
      result.fold(
        (failure) => emit(TaskError(failure)),
        (tasks) {
          final current = state;
          emit(
            current is TaskLoaded ? current.copyWith(tasks: tasks) : TaskLoaded(tasks: tasks),
          );
        },
      );
    });
  }

  /// Stops watching Firestore — call when the user signs out so a stale
  /// listener doesn't keep querying with no authenticated uid.
  Future<void> stopWatching() async {
    await _subscription?.cancel();
    _subscription = null;
    emit(const TaskInitial());
  }

  Future<void> addTask(TaskEntity task) async {
    final result = await _addTaskUsecase(task);
    result.fold((failure) => emit(TaskError(failure)), (_) {});
  }

  Future<void> updateTask(TaskEntity task) async {
    final result = await _updateTaskUsecase(task);
    result.fold((failure) => emit(TaskError(failure)), (_) {});
  }

  Future<void> moveTaskToQuadrant(String taskId, Quadrant quadrant) async {
    final current = state;
    if (current is! TaskLoaded) return;
    final task = current.tasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null || task.quadrant == quadrant) return;
    // A fresh timestamp outranks every reordered index, so it joins at the bottom.
    await updateTask(
      task.copyWith(quadrant: quadrant, sortOrder: DateTime.now().millisecondsSinceEpoch),
    );
  }

  /// Handles a drop from [ReorderableListView] in [quadrant]'s visible list.
  /// While searching, that list is a subset, so the reordered tasks are put
  /// back into the positions they held in the full quadrant — hidden tasks
  /// don't move. The new order shows immediately and is then saved.
  Future<void> reorderTask(Quadrant quadrant, int oldIndex, int newIndex) async {
    final current = state;
    if (current is! TaskLoaded) return;
    final visible = current.tasksFor(quadrant);
    if (oldIndex < 0 || oldIndex >= visible.length) return;
    // The index is reported as if the dragged task were still in the list.
    if (newIndex > oldIndex) newIndex -= 1;
    if (newIndex == oldIndex) return;

    final reordered = [...visible];
    reordered.insert(newIndex, reordered.removeAt(oldIndex));

    final visibleIds = visible.map((t) => t.id).toSet();
    final nextVisible = reordered.iterator;
    final orderedIds = [
      for (final task in current.allTasksFor(quadrant))
        if (visibleIds.contains(task.id) && nextVisible.moveNext())
          nextVisible.current.id
        else
          task.id,
    ];

    final positions = {for (var i = 0; i < orderedIds.length; i++) orderedIds[i]: i};
    emit(
      current.copyWith(
        tasks: [
          for (final task in current.tasks)
            if (positions[task.id] case final position?)
              task.copyWith(sortOrder: position)
            else
              task,
        ],
      ),
    );

    final result = await _reorderTasksUsecase(orderedIds);
    result.fold((failure) => emit(TaskError(failure)), (_) {});
  }

  Future<void> toggleCompletion(String taskId) async {
    final current = state;
    if (current is! TaskLoaded) return;
    final task = current.tasks.where((t) => t.id == taskId).firstOrNull;
    if (task == null) return;
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<void> deleteTask(String taskId) async {
    final result = await _deleteTaskUsecase(taskId);
    result.fold((failure) => emit(TaskError(failure)), (_) {});
  }

  void search(String query) {
    final current = state;
    if (current is! TaskLoaded) return;
    emit(current.copyWith(searchQuery: query));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
