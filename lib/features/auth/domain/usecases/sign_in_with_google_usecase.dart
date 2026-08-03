import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUsecase {
  const SignInWithGoogleUsecase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AppUser>> call() => _repository.signInWithGoogle();
}
