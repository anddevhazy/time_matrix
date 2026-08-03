import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../global/core/error/failures.dart';
import '../../domain/entities/quadrant.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({
    required GetTasksUsecase getTasksUsecase,
    required AddTaskUsecase addTaskUsecase,
    required UpdateTaskUsecase updateTaskUsecase,
    required DeleteTaskUsecase deleteTaskUsecase,
  })  : _getTasksUsecase = getTasksUsecase,
        _addTaskUsecase = addTaskUsecase,
        _updateTaskUsecase = updateTaskUsecase,
        _deleteTaskUsecase = deleteTaskUsecase,
        super(const TaskInitial());

  final GetTasksUsecase _getTasksUsecase;
  final AddTaskUsecase _addTaskUsecase;
  final UpdateTaskUsecase _updateTaskUsecase;
  final DeleteTaskUsecase _deleteTaskUsecase;

  Future<void> loadTasks() async {
    emit(const TaskLoading());
    final result = await _getTasksUsecase();
    result.fold(
      (failure) => emit(TaskError(failure)),
      (tasks) => emit(TaskLoaded(tasks: tasks)),
    );
  }

  Future<void> addTask(TaskEntity task) async {
    final current = state;
    if (current is! TaskLoaded) return;

    final result = await _addTaskUsecase(task);
    result.fold(
      (failure) => emit(TaskError(failure)),
      (_) => emit(current.copyWith(tasks: [...current.tasks, task])),
    );
  }

  Future<void> updateTask(TaskEntity task) async {
    final current = state;
    if (current is! TaskLoaded) return;

    final result = await _updateTaskUsecase(task);
    result.fold(
      (failure) => emit(TaskError(failure)),
      (_) => emit(current.copyWith(
        tasks: [for (final t in current.tasks) if (t.id == task.id) task else t],
      )),
    );
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
    final current = state;
    if (current is! TaskLoaded) return;

    final result = await _deleteTaskUsecase(taskId);
    result.fold(
      (failure) => emit(TaskError(failure)),
      (_) => emit(current.copyWith(
        tasks: current.tasks.where((t) => t.id != taskId).toList(),
      )),
    );
  }

  void search(String query) {
    final current = state;
    if (current is! TaskLoaded) return;
    emit(current.copyWith(searchQuery: query));
  }

  void filterByPriority(TaskPriority? priority) {
    final current = state;
    if (current is! TaskLoaded) return;
    emit(current.copyWith(priorityFilter: priority, clearPriorityFilter: priority == null));
  }
}
