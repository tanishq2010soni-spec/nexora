import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_manager.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_result.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/models/auth_models.dart';
import '../domain/repositories/auth_repository_interface.dart';

final authDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  return AuthRepository(ref.read(authDatasourceProvider));
});

final authProvider = NotifierProvider<AuthProvider, AsyncValue<void>>(
  AuthProvider.new,
);

class AuthProvider extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .login(email, password);
    return switch (result) {
      ApiSuccess(:final data) => await _onAuthSuccess(data),
      ApiError(:final exception) => await _onAuthError(exception),
      _ => false,
    };
  }

  Future<bool> signup(
    String email,
    String password,
    String organizationName,
  ) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .signup(email, password, organizationName);
    return switch (result) {
      ApiSuccess(:final data) => await _onAuthSuccess(data),
      ApiError(:final exception) => await _onAuthError(exception),
      _ => false,
    };
  }

  Future<bool> _onAuthSuccess(AuthTokens tokens) async {
    await ref
        .read(sessionManagerProvider.notifier)
        .setAuthenticated(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          email: tokens.email,
          orgId: tokens.orgId,
          role: tokens.role,
        );
    state = const AsyncData(null);
    return true;
  }

  Future<bool> _onAuthError(AppException exception) async {
    state = AsyncError(exception, StackTrace.current);
    return false;
  }

  Future<void> logout() async {
    await ref.read(sessionManagerProvider.notifier).forceLogout();
    state = const AsyncData(null);
  }
}
