import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/dump_entry.dart';
import '../repositories/dump_repository.dart';

class WatchDumpEntriesUsecase {
  const WatchDumpEntriesUsecase(this._repository);

  final DumpRepository _repository;

  Stream<Either<Failure, List<DumpEntry>>> call() => _repository.watchEntries();
}
