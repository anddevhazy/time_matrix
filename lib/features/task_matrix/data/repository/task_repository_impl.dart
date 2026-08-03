import 'package:dartz/dartz.dart';

import '../../../global/core/error/failure_mapper.dart';
import '../../../global/core/error/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../data_sources/remote/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._remoteDataSource);

  final TaskRemoteDataSource _remoteDataSource;

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasks() async* {
    try {
      await for (final tasks in _remoteDataSource.watchTasks()) {
        yield Right(tasks);
      }
    } catch (e) {
      yield Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> addTask(TaskEntity task) async {
    try {
      await _remoteDataSource.addTask(TaskModel.fromEntity(task));
      return const Right(unit);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTask(TaskEntity task) async {
    try {
      await _remoteDataSource.updateTask(TaskModel.fromEntity(task));
      return const Right(unit);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String id) async {
    try {
      await _remoteDataSource.deleteTask(id);
      return const Right(unit);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
