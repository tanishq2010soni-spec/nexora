import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../env/env.dart';
import '../logging/app_logger.dart';
import 'session_state.dart';
import 'token_manager.dart';

final tokenManagerProvider = Provider<TokenManager>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final sessionManagerProvider = NotifierProvider<SessionManager, SessionState>(
  SessionManager.new,
);

class SessionManager extends Notifier<SessionState> {
  Timer? _refreshTimer;
  Completer<void>? _refreshCompleter;

  TokenManager get _tokenManager => ref.read(tokenManagerProvider);

  @override
  SessionState build() {
    AppLogger.instance.info('[SESSION] SessionManager.build() called');
    _initializeFromStorage();
    return const SessionState(status: SessionStatus.initial);
  }

  void _initializeFromStorage() {
    Future(() async {
      try {
        await _doInitializeFromStorage().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            AppLogger.instance.warning(
              '[SESSION] Initialization timed out, forcing unauthenticated',
            );
            state = const SessionState(status: SessionStatus.unauthenticated);
          },
        );
      } catch (e) {
        AppLogger.instance.error(
          '[SESSION] _initializeFromStorage() exception',
          e.toString(),
        );
        if (state.status == SessionStatus.initial ||
            state.status == SessionStatus.refreshing) {
          state = const SessionState(status: SessionStatus.unauthenticated);
        }
      }
    });
  }

  Future<void> _doInitializeFromStorage() async {
    AppLogger.instance.info('[SESSION] Reading tokens from storage...');
    final accessToken = await _tokenManager.getAccessToken();
    final refreshToken = await _tokenManager.getRefreshToken();
    final hasTokens = accessToken != null && refreshToken != null;
    AppLogger.instance.info('[SESSION] Tokens found: $hasTokens');

    if (hasTokens) {
      if (_tokenManager.isTokenExpired(accessToken)) {
        if (!_tokenManager.isTokenExpired(refreshToken)) {
          state = const SessionState(status: SessionStatus.refreshing);
          await _refreshToken();
        } else {
          state = const SessionState(status: SessionStatus.unauthenticated);
        }
      } else {
        final payload = _tokenManager.decodeToken(accessToken);
        state = SessionState(
          status: SessionStatus.authenticated,
          accessToken: accessToken,
          refreshToken: refreshToken,
          tokenExpiry: _tokenManager.getTokenExpiry(accessToken),
          userId: payload?['sub'] as String?,
          email: payload?['email'] as String? ?? payload?['sub'] as String?,
          orgId: payload?['org_id'] as String?,
          role: payload?['role'] as String?,
        );
        _startRefreshTimer();
      }
    } else {
      state = const SessionState(status: SessionStatus.unauthenticated);
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAndRefresh(),
    );
    AppLogger.instance.info('[SESSION] Refresh timer started (30s interval)');
  }

  Future<void> _checkAndRefresh() async {
    if (state.needsRefresh && state.isAuthenticated) {
      AppLogger.instance.info('[SESSION] Periodic check: token needs refresh');
      await _refreshToken();
    } else {
      AppLogger.instance.debug(
        '[SESSION] Periodic check: no refresh needed (needsRefresh=${state.needsRefresh}, isAuthenticated=${state.isAuthenticated})',
      );
    }
  }

  Future<void> _refreshToken() async {
    if (_refreshCompleter != null) {
      AppLogger.instance.info(
        '[SESSION] Refresh already in progress, waiting...',
      );
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer();
    try {
      final refreshToken =
          state.refreshToken ?? await _tokenManager.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.instance.warning(
          '[SESSION] No refresh token available, forcing logout',
        );
        await forceLogout();
        return;
      }

      AppLogger.instance.info('[SESSION] Refreshing token...');

      final dio = Dio(
        BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await dio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      AppLogger.instance.info(
        '[SESSION] Token refresh status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await _tokenManager.saveTokens(newAccessToken, newRefreshToken);
          final payload = _tokenManager.decodeToken(newAccessToken);
          state = SessionState(
            status: SessionStatus.authenticated,
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            tokenExpiry: _tokenManager.getTokenExpiry(newAccessToken),
            userId: payload?['sub'] as String?,
            email: payload?['email'] as String? ?? payload?['sub'] as String?,
            orgId: payload?['org_id'] as String?,
            role: payload?['role'] as String?,
          );
          AppLogger.instance.info(
            '[SESSION] Token refresh succeeded, state: authenticated',
          );
        } else {
          AppLogger.instance.warning('[SESSION] Refresh returned null tokens');
          await forceLogout();
        }
      } else {
        AppLogger.instance.warning(
          '[SESSION] Refresh returned non-200: ${response.statusCode}',
        );
        await forceLogout();
      }
    } on DioException catch (e) {
      AppLogger.instance.error(
        '[SESSION] Token refresh failed (DioException)',
        e.message,
      );
      await forceLogout();
    } catch (e) {
      AppLogger.instance.error(
        '[SESSION] Token refresh failed (unknown)',
        e.toString(),
      );
      await forceLogout();
    } finally {
      _refreshCompleter?.complete();
      _refreshCompleter = null;
    }
  }

  Future<void> setAuthenticated({
    required String accessToken,
    required String refreshToken,
    required String email,
    required String orgId,
    required String role,
  }) async {
    AppLogger.instance.info(
      '[SESSION] setAuthenticated() called for email=$email',
    );
    await _tokenManager.saveTokens(accessToken, refreshToken);
    final payload = _tokenManager.decodeToken(accessToken);
    state = SessionState(
      status: SessionStatus.authenticated,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenExpiry: _tokenManager.getTokenExpiry(accessToken),
      userId: payload?['sub'] as String?,
      email: email,
      orgId: orgId,
      role: role,
    );
    AppLogger.instance.info(
      '[SESSION] State: authenticated (from setAuthenticated)',
    );
    _startRefreshTimer();
  }

  Future<void> forceLogout() async {
    AppLogger.instance.info('[SESSION] forceLogout() called');
    _refreshTimer?.cancel();
    await _tokenManager.clearTokens();
    state = const SessionState(status: SessionStatus.unauthenticated);
    AppLogger.instance.info(
      '[SESSION] State: unauthenticated (after forceLogout)',
    );
  }
}
