import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignOutUsecase {
  const SignOutUsecase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call() => _repository.signOut();
}
