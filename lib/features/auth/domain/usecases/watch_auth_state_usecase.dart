import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateUsecase {
  const WatchAuthStateUsecase(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() => _repository.authStateChanges();
}
