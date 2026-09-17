import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Stream<Either<Failure, List<TaskEntity>>> watchTasks();

  Future<Either<Failure, Unit>> addTask(TaskEntity task);

  Future<Either<Failure, Unit>> updateTask(TaskEntity task);

  Future<Either<Failure, Unit>> deleteTask(String id);

  Future<Either<Failure, Unit>> reorderTasks(List<String> orderedIds);
}
