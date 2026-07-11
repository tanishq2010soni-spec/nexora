// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_key.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ApiKey _$ApiKeyFromJson(Map<String, dynamic> json) {
  return _ApiKey.fromJson(json);
}

/// @nodoc
mixin _$ApiKey {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get keyPrefix => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get lastUsedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  List<String> get scopes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ApiKey to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyCopyWith<ApiKey> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyCopyWith<$Res> {
  factory $ApiKeyCopyWith(ApiKey value, $Res Function(ApiKey) then) =
      _$ApiKeyCopyWithImpl<$Res, ApiKey>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String keyPrefix,
    String? description,
    bool isActive,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    List<String> scopes,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ApiKeyCopyWithImpl<$Res, $Val extends ApiKey>
    implements $ApiKeyCopyWith<$Res> {
  _$ApiKeyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? keyPrefix = null,
    Object? description = freezed,
    Object? isActive = null,
    Object? lastUsedAt = freezed,
    Object? expiresAt = freezed,
    Object? scopes = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orgId: null == orgId
                ? _value.orgId
                : orgId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            keyPrefix: null == keyPrefix
                ? _value.keyPrefix
                : keyPrefix // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastUsedAt: freezed == lastUsedAt
                ? _value.lastUsedAt
                : lastUsedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            scopes: null == scopes
                ? _value.scopes
                : scopes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiKeyImplCopyWith<$Res> implements $ApiKeyCopyWith<$Res> {
  factory _$$ApiKeyImplCopyWith(
    _$ApiKeyImpl value,
    $Res Function(_$ApiKeyImpl) then,
  ) = __$$ApiKeyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String keyPrefix,
    String? description,
    bool isActive,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    List<String> scopes,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ApiKeyImplCopyWithImpl<$Res>
    extends _$ApiKeyCopyWithImpl<$Res, _$ApiKeyImpl>
    implements _$$ApiKeyImplCopyWith<$Res> {
  __$$ApiKeyImplCopyWithImpl(
    _$ApiKeyImpl _value,
    $Res Function(_$ApiKeyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? keyPrefix = null,
    Object? description = freezed,
    Object? isActive = null,
    Object? lastUsedAt = freezed,
    Object? expiresAt = freezed,
    Object? scopes = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ApiKeyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        keyPrefix: null == keyPrefix
            ? _value.keyPrefix
            : keyPrefix // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastUsedAt: freezed == lastUsedAt
            ? _value.lastUsedAt
            : lastUsedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        scopes: null == scopes
            ? _value._scopes
            : scopes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiKeyImpl implements _ApiKey {
  const _$ApiKeyImpl({
    required this.id,
    required this.orgId,
    required this.name,
    required this.keyPrefix,
    this.description,
    this.isActive = true,
    this.lastUsedAt,
    this.expiresAt,
    required final List<String> scopes,
    required this.createdAt,
  }) : _scopes = scopes;

  factory _$ApiKeyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String name;
  @override
  final String keyPrefix;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? lastUsedAt;
  @override
  final DateTime? expiresAt;
  final List<String> _scopes;
  @override
  List<String> get scopes {
    if (_scopes is EqualUnmodifiableListView) return _scopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scopes);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ApiKey(id: $id, orgId: $orgId, name: $name, keyPrefix: $keyPrefix, description: $description, isActive: $isActive, lastUsedAt: $lastUsedAt, expiresAt: $expiresAt, scopes: $scopes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.keyPrefix, keyPrefix) ||
                other.keyPrefix == keyPrefix) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            const DeepCollectionEquality().equals(other._scopes, _scopes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orgId,
    name,
    keyPrefix,
    description,
    isActive,
    lastUsedAt,
    expiresAt,
    const DeepCollectionEquality().hash(_scopes),
    createdAt,
  );

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyImplCopyWith<_$ApiKeyImpl> get copyWith =>
      __$$ApiKeyImplCopyWithImpl<_$ApiKeyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyImplToJson(this);
  }
}

abstract class _ApiKey implements ApiKey {
  const factory _ApiKey({
    required final String id,
    required final String orgId,
    required final String name,
    required final String keyPrefix,
    final String? description,
    final bool isActive,
    final DateTime? lastUsedAt,
    final DateTime? expiresAt,
    required final List<String> scopes,
    required final DateTime createdAt,
  }) = _$ApiKeyImpl;

  factory _ApiKey.fromJson(Map<String, dynamic> json) = _$ApiKeyImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get name;
  @override
  String get keyPrefix;
  @override
  String? get description;
  @override
  bool get isActive;
  @override
  DateTime? get lastUsedAt;
  @override
  DateTime? get expiresAt;
  @override
  List<String> get scopes;
  @override
  DateTime get createdAt;

  /// Create a copy of ApiKey
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyImplCopyWith<_$ApiKeyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
