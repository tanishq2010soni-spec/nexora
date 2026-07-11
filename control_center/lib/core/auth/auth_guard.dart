import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../logging/app_logger.dart';
import 'session_manager.dart';
import 'session_state.dart';

class AuthGuard {
  final Ref ref;
  String _lastDecision = '';

  AuthGuard(this.ref);

  String? redirect(BuildContext context, GoRouterState state) {
    final session = ref.read(sessionManagerProvider);
    final location = state.matchedLocation;
    final isLoginRoute = location == '/login';
    final isRegisterRoute = location == '/register';
    final isSplashRoute = location == '/splash';
    final isAuthRoute = isLoginRoute || isRegisterRoute || isSplashRoute;

    String? decision;

    if (session.status == SessionStatus.initial ||
        session.status == SessionStatus.refreshing) {
      decision = isSplashRoute ? null : '/splash';
    } else if (session.isAuthenticated) {
      decision = (isLoginRoute || isRegisterRoute) ? '/dashboard' : null;
    } else {
      decision = isAuthRoute ? null : '/login';
    }

    final decisionStr = decision ?? 'null';
    if (decisionStr == _lastDecision) {
      return null;
    }
    _lastDecision = decisionStr;

    AppLogger.instance.info(
      '[AUTH_GUARD] status=${session.status}, isAuth=${session.isAuthenticated}, route=$location, decision=$decision',
    );

    return decision;
  }
}
