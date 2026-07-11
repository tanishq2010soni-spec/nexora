import 'package:freezed_annotation/freezed_annotation.dart';
part 'session_state.freezed.dart';

enum SessionStatus {
  initial,
  authenticated,
  refreshing,
  unauthenticated,
  expired,
}

@freezed
class SessionState with _$SessionState {
  const SessionState._();

  const factory SessionState({
    @Default(SessionStatus.initial) SessionStatus status,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
    String? userId,
    String? email,
    String? orgId,
    String? role,
  }) = _SessionState;

  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get isExpired => tokenExpiry?.isBefore(DateTime.now()) ?? true;
  bool get needsRefresh =>
      tokenExpiry != null &&
      tokenExpiry!.difference(DateTime.now()).inSeconds < 30;
}
