// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_setting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrganizationSetting _$OrganizationSettingFromJson(Map<String, dynamic> json) {
  return _OrganizationSetting.fromJson(json);
}

/// @nodoc
mixin _$OrganizationSetting {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this OrganizationSetting to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizationSetting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizationSettingCopyWith<OrganizationSetting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizationSettingCopyWith<$Res> {
  factory $OrganizationSettingCopyWith(
    OrganizationSetting value,
    $Res Function(OrganizationSetting) then,
  ) = _$OrganizationSettingCopyWithImpl<$Res, OrganizationSetting>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String key,
    String value,
    String? description,
    String? category,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$OrganizationSettingCopyWithImpl<$Res, $Val extends OrganizationSetting>
    implements $OrganizationSettingCopyWith<$Res> {
  _$OrganizationSettingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizationSetting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? key = null,
    Object? value = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? updatedAt = null,
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
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrganizationSettingImplCopyWith<$Res>
    implements $OrganizationSettingCopyWith<$Res> {
  factory _$$OrganizationSettingImplCopyWith(
    _$OrganizationSettingImpl value,
    $Res Function(_$OrganizationSettingImpl) then,
  ) = __$$OrganizationSettingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String key,
    String value,
    String? description,
    String? category,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$OrganizationSettingImplCopyWithImpl<$Res>
    extends _$OrganizationSettingCopyWithImpl<$Res, _$OrganizationSettingImpl>
    implements _$$OrganizationSettingImplCopyWith<$Res> {
  __$$OrganizationSettingImplCopyWithImpl(
    _$OrganizationSettingImpl _value,
    $Res Function(_$OrganizationSettingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrganizationSetting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? key = null,
    Object? value = null,
    Object? description = freezed,
    Object? category = freezed,
    Object? updatedAt = null,
  }) {
    return _then(
      _$OrganizationSettingImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizationSettingImpl implements _OrganizationSetting {
  const _$OrganizationSettingImpl({
    required this.id,
    required this.orgId,
    required this.key,
    required this.value,
    this.description,
    this.category,
    required this.updatedAt,
  });

  factory _$OrganizationSettingImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizationSettingImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String key;
  @override
  final String value;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'OrganizationSetting(id: $id, orgId: $orgId, key: $key, value: $value, description: $description, category: $category, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizationSettingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orgId,
    key,
    value,
    description,
    category,
    updatedAt,
  );

  /// Create a copy of OrganizationSetting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizationSettingImplCopyWith<_$OrganizationSettingImpl> get copyWith =>
      __$$OrganizationSettingImplCopyWithImpl<_$OrganizationSettingImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizationSettingImplToJson(this);
  }
}

abstract class _OrganizationSetting implements OrganizationSetting {
  const factory _OrganizationSetting({
    required final String id,
    required final String orgId,
    required final String key,
    required final String value,
    final String? description,
    final String? category,
    required final DateTime updatedAt,
  }) = _$OrganizationSettingImpl;

  factory _OrganizationSetting.fromJson(Map<String, dynamic> json) =
      _$OrganizationSettingImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get key;
  @override
  String get value;
  @override
  String? get description;
  @override
  String? get category;
  @override
  DateTime get updatedAt;

  /// Create a copy of OrganizationSetting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizationSettingImplCopyWith<_$OrganizationSettingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
