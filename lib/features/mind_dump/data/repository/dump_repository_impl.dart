import 'package:dartz/dartz.dart';

import '../../../global/core/error/failure_mapper.dart';
import '../../../global/core/error/failures.dart';
import '../../domain/entities/dump_entry.dart';
import '../../domain/repositories/dump_repository.dart';
import '../data_sources/remote/dump_remote_data_source.dart';
import '../models/dump_entry_model.dart';

class DumpRepositoryImpl implements DumpRepository {
  DumpRepositoryImpl(this._remoteDataSource);

  final DumpRemoteDataSource _remoteDataSource;

  @override
  Stream<Either<Failure, List<DumpEntry>>> watchEntries() async* {
    try {
      await for (final entries in _remoteDataSource.watchEntries()) {
        yield Right(entries);
      }
    } catch (e) {
      yield Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> addEntry(DumpEntry entry) async {
    try {
      await _remoteDataSource.addEntry(DumpEntryModel.fromEntity(entry));
      return const Right(unit);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEntries(List<String> ids) async {
    try {
      await _remoteDataSource.deleteEntries(ids);
      return const Right(unit);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
