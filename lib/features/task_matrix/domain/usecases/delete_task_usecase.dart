import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUsecase {
  const DeleteTaskUsecase(this._repository);

  final TaskRepository _repository;

  Future<Either<Failure, Unit>> call(String id) => _repository.deleteTask(id);
}
