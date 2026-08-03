import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../task_matrix/presentation/pages/matrix_page.dart';
import '../cubit/auth_cubit.dart';
import '../pages/sign_in_page.dart';

/// Routes between the sign-in screen and the matrix based on auth state,
/// so every route in the app effectively requires a signed-in user.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthAuthenticated() => const MatrixPage(),
          AuthUnauthenticated() || AuthFailed() || AuthAuthenticating() => const SignInPage(),
          AuthInitial() => const Scaffold(body: Center(child: CircularProgressIndicator())),
        };
      },
    );
  }
}
