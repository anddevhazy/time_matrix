import 'package:dartz/dartz.dart';

import '../../../global/core/error/failure_mapper.dart';
import '../../../global/core/error/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../data_sources/local/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._localDataSource);

  final TaskLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final tasks = await _localDataSource.getTasks();
      return Right(tasks);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> addTask(TaskEntity task) async {
    return _mutate((tasks) => tasks..add(TaskModel.fromEntity(task)));
  }

  @override
  Future<Either<Failure, Unit>> updateTask(TaskEntity task) async {
    return _mutate((tasks) {
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index == -1) return tasks;
      tasks[index] = TaskModel.fromEntity(task);
      return tasks;
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String id) async {
    return _mutate((tasks) => tasks..removeWhere((t) => t.id == id));
  }

  Future<Either<Failure, Unit>> _mutate(
    List<TaskModel> Function(List<TaskModel> tasks) transform,
  ) async {
    try {
      final tasks = await _localDataSource.getTasks();
      await _localDataSource.saveTasks(transform(tasks));
      return const Right(unit);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
