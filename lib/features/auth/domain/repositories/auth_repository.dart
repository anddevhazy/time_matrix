import 'package:dartz/dartz.dart';

import '../../../global/core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, Unit>> signOut();
}
