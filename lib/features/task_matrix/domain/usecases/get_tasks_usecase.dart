import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUsecase {
  const GetTasksUsecase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, List<TaskEntity>>> call() => _repository.getTasks();
}
