import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();

  Future<Either<Failure, Unit>> addTask(TaskEntity task);

  Future<Either<Failure, Unit>> updateTask(TaskEntity task);

  Future<Either<Failure, Unit>> deleteTask(String id);
}
