import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../repositories/dump_repository.dart';

class ReorderDumpEntriesUsecase {
  const ReorderDumpEntriesUsecase(this._repository);

  final DumpRepository _repository;

  /// Persists [orderedIds] as positions 0..n-1.
  Future<Either<Failure, Unit>> call(List<String> orderedIds) =>
      _repository.reorderEntries(orderedIds);
}
