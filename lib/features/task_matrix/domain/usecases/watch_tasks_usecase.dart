import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class WatchTasksUsecase {
  const WatchTasksUsecase(this._repository);

  final TaskRepository _repository;

  Stream<Either<Failure, List<TaskEntity>>> call() => _repository.watchTasks();
}
