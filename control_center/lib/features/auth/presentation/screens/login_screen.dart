import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  String _resolveErrorMessage(Object error) {
    final msg = error.toString();
    if (msg.contains('Invalid credentials') || msg.contains('incorrect')) {
      return 'Invalid email or password. Please try again.';
    }
    if (msg.contains('Connection') ||
        msg.contains('network') ||
        msg.contains('timeout')) {
      return 'Unable to connect to server. Please check your connection.';
    }
    return 'Login failed. Please try again.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen(sessionManagerProvider, (prev, next) {
      if (next.isAuthenticated) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LoginHeader(),
                const SizedBox(height: 32),
                LoginForm(
                  isLoading: authState is AsyncLoading,
                  onSubmit: (email, password) {
                    ref.read(authProvider.notifier).login(email, password);
                  },
                ),
                if (authState is AsyncError) ...[
                  const SizedBox(height: 16),
                  Text(
                    _resolveErrorMessage(authState.error),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
