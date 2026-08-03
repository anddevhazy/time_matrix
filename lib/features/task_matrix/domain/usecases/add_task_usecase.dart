import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class AddTaskUsecase {
  const AddTaskUsecase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Unit>> call(TaskEntity task) {
    if (task.title.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Task title cannot be empty.')));
    }
    return _repository.addTask(task);
  }
}
