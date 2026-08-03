import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../global/core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required WatchAuthStateUsecase watchAuthStateUsecase,
    required SignInWithGoogleUsecase signInWithGoogleUsecase,
    required SignOutUsecase signOutUsecase,
  })  : _signInWithGoogleUsecase = signInWithGoogleUsecase,
        _signOutUsecase = signOutUsecase,
        super(const AuthInitial()) {
    _subscription = watchAuthStateUsecase().listen((user) {
      emit(user == null ? const AuthUnauthenticated() : AuthAuthenticated(user));
    });
  }

  final SignInWithGoogleUsecase _signInWithGoogleUsecase;
  final SignOutUsecase _signOutUsecase;
  late final StreamSubscription<AppUser?> _subscription;

  Future<void> signInWithGoogle() async {
    emit(const AuthAuthenticating());
    final result = await _signInWithGoogleUsecase();
    // On success, the authStateChanges listener above emits AuthAuthenticated.
    result.fold((failure) => emit(AuthFailed(failure)), (_) {});
  }

  Future<void> signOut() => _signOutUsecase();

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
