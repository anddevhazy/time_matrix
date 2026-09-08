import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../repositories/dump_repository.dart';

class DeleteDumpEntriesUsecase {
  const DeleteDumpEntriesUsecase(this._repository);

  final DumpRepository _repository;

  Future<Either<Failure, Unit>> call(List<String> ids) => _repository.deleteEntries(ids);
}
