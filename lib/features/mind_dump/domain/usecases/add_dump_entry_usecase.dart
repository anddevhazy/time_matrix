import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/dump_entry.dart';
import '../repositories/dump_repository.dart';

class AddDumpEntryUsecase {
  const AddDumpEntryUsecase(this._repository);

  final DumpRepository _repository;

  Future<Either<Failure, Unit>> call(DumpEntry entry) {
    if (entry.text.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Entry cannot be empty.')));
    }
    return _repository.addEntry(entry);
  }
}
