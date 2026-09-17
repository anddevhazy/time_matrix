import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/dump_entry.dart';

abstract class DumpRepository {
  Stream<Either<Failure, List<DumpEntry>>> watchEntries();

  Future<Either<Failure, Unit>> addEntry(DumpEntry entry);

  Future<Either<Failure, Unit>> deleteEntries(List<String> ids);

  Future<Either<Failure, Unit>> reorderEntries(List<String> orderedIds);
}
