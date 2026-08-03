import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../global/core/error/failure_mapper.dart';
import '../../../global/core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  AppUser _toAppUser(User user) => AppUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
      );

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user == null ? null : _toAppUser(user));
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final credential = await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
      final user = credential.user;
      if (user == null) {
        return const Left(UnexpectedFailure('Sign-in did not return a user.'));
      }
      return Right(_toAppUser(user));
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(unit);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
