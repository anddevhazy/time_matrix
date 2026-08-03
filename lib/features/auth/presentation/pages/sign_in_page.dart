import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../global/constants/app_colors.dart';
import '../../../global/constants/app_text_styles.dart';
import '../cubit/auth_cubit.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 20),
                Text('Time Matrix', style: AppTextStyles.displayLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Sign in to sync your tasks across every device.',
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFailed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.failure.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isAuthenticating = state is AuthAuthenticating;
                    return FilledButton.icon(
                      onPressed: isAuthenticating
                          ? null
                          : () => context.read<AuthCubit>().signInWithGoogle(),
                      icon: isAuthenticating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(isAuthenticating ? 'Signing in…' : 'Sign in with Google'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
