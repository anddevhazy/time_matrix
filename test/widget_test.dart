import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:time_matrix/features/auth/domain/entities/app_user.dart';
import 'package:time_matrix/features/auth/domain/repositories/auth_repository.dart';
import 'package:time_matrix/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:time_matrix/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:time_matrix/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:time_matrix/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:time_matrix/features/auth/presentation/pages/sign_in_page.dart';
import 'package:time_matrix/features/global/core/error/failures.dart';

/// A fake repository stands in for Firebase here — VM widget tests can't
/// run the Firebase JS SDK, and this keeps the test focused on the widget
/// reacting to auth state rather than exercising real Firebase Auth.
class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> authStateChanges() => Stream.value(null);

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async =>
      const Right(AppUser(uid: 'test-uid'));

  @override
  Future<Either<Failure, Unit>> signOut() async => const Right(unit);
}

void main() {
  testWidgets('Sign-in page prompts for Google sign-in when unauthenticated', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();
    final cubit = AuthCubit(
      watchAuthStateUsecase: WatchAuthStateUsecase(repository),
      signInWithGoogleUsecase: SignInWithGoogleUsecase(repository),
      signOutUsecase: SignOutUsecase(repository),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const SignInPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Time Matrix'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
