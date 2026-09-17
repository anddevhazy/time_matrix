import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../repositories/task_repository.dart';

class ReorderTasksUsecase {
  const ReorderTasksUsecase(this._repository);

  final TaskRepository _repository;

  /// Persists [orderedIds] as positions 0..n-1.
  Future<Either<Failure, Unit>> call(List<String> orderedIds) =>
      _repository.reorderTasks(orderedIds);
}
