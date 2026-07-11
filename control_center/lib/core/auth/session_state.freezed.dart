// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SessionState {
  SessionStatus get status => throw _privateConstructorUsedError;
  String? get accessToken => throw _privateConstructorUsedError;
  String? get refreshToken => throw _privateConstructorUsedError;
  DateTime? get tokenExpiry => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get orgId => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionStateCopyWith<SessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionStateCopyWith<$Res> {
  factory $SessionStateCopyWith(
    SessionState value,
    $Res Function(SessionState) then,
  ) = _$SessionStateCopyWithImpl<$Res, SessionState>;
  @useResult
  $Res call({
    SessionStatus status,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
    String? userId,
    String? email,
    String? orgId,
    String? role,
  });
}

/// @nodoc
class _$SessionStateCopyWithImpl<$Res, $Val extends SessionState>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? tokenExpiry = freezed,
    Object? userId = freezed,
    Object? email = freezed,
    Object? orgId = freezed,
    Object? role = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SessionStatus,
            accessToken: freezed == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            refreshToken: freezed == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            tokenExpiry: freezed == tokenExpiry
                ? _value.tokenExpiry
                : tokenExpiry // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            orgId: freezed == orgId
                ? _value.orgId
                : orgId // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionStateImplCopyWith<$Res>
    implements $SessionStateCopyWith<$Res> {
  factory _$$SessionStateImplCopyWith(
    _$SessionStateImpl value,
    $Res Function(_$SessionStateImpl) then,
  ) = __$$SessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    SessionStatus status,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
    String? userId,
    String? email,
    String? orgId,
    String? role,
  });
}

/// @nodoc
class __$$SessionStateImplCopyWithImpl<$Res>
    extends _$SessionStateCopyWithImpl<$Res, _$SessionStateImpl>
    implements _$$SessionStateImplCopyWith<$Res> {
  __$$SessionStateImplCopyWithImpl(
    _$SessionStateImpl _value,
    $Res Function(_$SessionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? tokenExpiry = freezed,
    Object? userId = freezed,
    Object? email = freezed,
    Object? orgId = freezed,
    Object? role = freezed,
  }) {
    return _then(
      _$SessionStateImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SessionStatus,
        accessToken: freezed == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        refreshToken: freezed == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        tokenExpiry: freezed == tokenExpiry
            ? _value.tokenExpiry
            : tokenExpiry // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        orgId: freezed == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SessionStateImpl extends _SessionState {
  const _$SessionStateImpl({
    this.status = SessionStatus.initial,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiry,
    this.userId,
    this.email,
    this.orgId,
    this.role,
  }) : super._();

  @override
  @JsonKey()
  final SessionStatus status;
  @override
  final String? accessToken;
  @override
  final String? refreshToken;
  @override
  final DateTime? tokenExpiry;
  @override
  final String? userId;
  @override
  final String? email;
  @override
  final String? orgId;
  @override
  final String? role;

  @override
  String toString() {
    return 'SessionState(status: $status, accessToken: $accessToken, refreshToken: $refreshToken, tokenExpiry: $tokenExpiry, userId: $userId, email: $email, orgId: $orgId, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.tokenExpiry, tokenExpiry) ||
                other.tokenExpiry == tokenExpiry) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.role, role) || other.role == role));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    accessToken,
    refreshToken,
    tokenExpiry,
    userId,
    email,
    orgId,
    role,
  );

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionStateImplCopyWith<_$SessionStateImpl> get copyWith =>
      __$$SessionStateImplCopyWithImpl<_$SessionStateImpl>(this, _$identity);
}

abstract class _SessionState extends SessionState {
  const factory _SessionState({
    final SessionStatus status,
    final String? accessToken,
    final String? refreshToken,
    final DateTime? tokenExpiry,
    final String? userId,
    final String? email,
    final String? orgId,
    final String? role,
  }) = _$SessionStateImpl;
  const _SessionState._() : super._();

  @override
  SessionStatus get status;
  @override
  String? get accessToken;
  @override
  String? get refreshToken;
  @override
  DateTime? get tokenExpiry;
  @override
  String? get userId;
  @override
  String? get email;
  @override
  String? get orgId;
  @override
  String? get role;

  /// Create a copy of SessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionStateImplCopyWith<_$SessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
