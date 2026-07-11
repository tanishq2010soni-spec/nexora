import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/session_manager.dart';
import '../../../../core/auth/session_state.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionManagerProvider);

    AppLogger.instance.info(
      '[SPLASH] build() - status: ${session.status}, isAuthenticated: ${session.isAuthenticated}, hasNavigated: $_hasNavigated, route: ${ModalRoute.of(context)?.settings.name ?? GoRouterState.of(context).matchedLocation}',
    );

    final shouldNavigate =
        !_hasNavigated &&
        session.status != SessionStatus.initial &&
        session.status != SessionStatus.refreshing;

    if (shouldNavigate) {
      _hasNavigated = true;
      AppLogger.instance.info(
        '[SPLASH] Scheduling navigation. status=${session.status}, isAuthenticated=${session.isAuthenticated}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (session.isAuthenticated) {
          AppLogger.instance.info('[SPLASH] Navigating to /dashboard');
          context.go('/dashboard');
        } else {
          AppLogger.instance.info('[SPLASH] Navigating to /login');
          context.go('/login');
        }
      });
    }

    if (session.status == SessionStatus.initial ||
        session.status == SessionStatus.refreshing) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
              const SizedBox(height: 16),
              Text(
                session.status == SessionStatus.refreshing
                    ? 'Refreshing session...'
                    : 'Loading...',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
