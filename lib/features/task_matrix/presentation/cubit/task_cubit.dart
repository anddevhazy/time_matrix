import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../global/core/error/failures.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/watch_tasks_usecase.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({
    required WatchTasksUsecase watchTasksUsecase,
    required AddTaskUsecase addTaskUsecase,
    required UpdateTaskUsecase updateTaskUsecase,
    required DeleteTaskUsecase deleteTaskUsecase,
  })  : _watchTasksUsecase = watchTasksUsecase,
        _addTaskUsecase = addTaskUsecase,
        _updateTaskUsecase = updateTaskUsecase,
        _deleteTaskUsecase = deleteTaskUsecase,
        super(const TaskInitial());

  final WatchTasksUsecase _watchTasksUsecase;
  final AddTaskUsecase _addTaskUsecase;
  final UpdateTaskUsecase _updateTaskUsecase;
  final DeleteTaskUsecase _deleteTaskUsecase;

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
    await updateTask(task.copyWith(quadrant: quadrant));
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
