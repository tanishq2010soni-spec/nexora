// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomerActivity _$CustomerActivityFromJson(Map<String, dynamic> json) {
  return _CustomerActivity.fromJson(json);
}

/// @nodoc
mixin _$CustomerActivity {
  String get id => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  CustomerActivityType get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get performedBy => throw _privateConstructorUsedError;
  String? get performedByName => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CustomerActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerActivityCopyWith<CustomerActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerActivityCopyWith<$Res> {
  factory $CustomerActivityCopyWith(
    CustomerActivity value,
    $Res Function(CustomerActivity) then,
  ) = _$CustomerActivityCopyWithImpl<$Res, CustomerActivity>;
  @useResult
  $Res call({
    String id,
    String customerId,
    CustomerActivityType type,
    String description,
    String? performedBy,
    String? performedByName,
    Map<String, dynamic>? metadata,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CustomerActivityCopyWithImpl<$Res, $Val extends CustomerActivity>
    implements $CustomerActivityCopyWith<$Res> {
  _$CustomerActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? type = null,
    Object? description = null,
    Object? performedBy = freezed,
    Object? performedByName = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as CustomerActivityType,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            performedBy: freezed == performedBy
                ? _value.performedBy
                : performedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            performedByName: freezed == performedByName
                ? _value.performedByName
                : performedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
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
abstract class _$$CustomerActivityImplCopyWith<$Res>
    implements $CustomerActivityCopyWith<$Res> {
  factory _$$CustomerActivityImplCopyWith(
    _$CustomerActivityImpl value,
    $Res Function(_$CustomerActivityImpl) then,
  ) = __$$CustomerActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerId,
    CustomerActivityType type,
    String description,
    String? performedBy,
    String? performedByName,
    Map<String, dynamic>? metadata,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CustomerActivityImplCopyWithImpl<$Res>
    extends _$CustomerActivityCopyWithImpl<$Res, _$CustomerActivityImpl>
    implements _$$CustomerActivityImplCopyWith<$Res> {
  __$$CustomerActivityImplCopyWithImpl(
    _$CustomerActivityImpl _value,
    $Res Function(_$CustomerActivityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? type = null,
    Object? description = null,
    Object? performedBy = freezed,
    Object? performedByName = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$CustomerActivityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as CustomerActivityType,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        performedBy: freezed == performedBy
            ? _value.performedBy
            : performedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        performedByName: freezed == performedByName
            ? _value.performedByName
            : performedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
class _$CustomerActivityImpl implements _CustomerActivity {
  const _$CustomerActivityImpl({
    required this.id,
    required this.customerId,
    required this.type,
    required this.description,
    this.performedBy,
    this.performedByName,
    final Map<String, dynamic>? metadata,
    required this.createdAt,
  }) : _metadata = metadata;

  factory _$CustomerActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
  @override
  final CustomerActivityType type;
  @override
  final String description;
  @override
  final String? performedBy;
  @override
  final String? performedByName;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CustomerActivity(id: $id, customerId: $customerId, type: $type, description: $description, performedBy: $performedBy, performedByName: $performedByName, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            (identical(other.performedByName, performedByName) ||
                other.performedByName == performedByName) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    customerId,
    type,
    description,
    performedBy,
    performedByName,
    const DeepCollectionEquality().hash(_metadata),
    createdAt,
  );

  /// Create a copy of CustomerActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerActivityImplCopyWith<_$CustomerActivityImpl> get copyWith =>
      __$$CustomerActivityImplCopyWithImpl<_$CustomerActivityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerActivityImplToJson(this);
  }
}

abstract class _CustomerActivity implements CustomerActivity {
  const factory _CustomerActivity({
    required final String id,
    required final String customerId,
    required final CustomerActivityType type,
    required final String description,
    final String? performedBy,
    final String? performedByName,
    final Map<String, dynamic>? metadata,
    required final DateTime createdAt,
  }) = _$CustomerActivityImpl;

  factory _CustomerActivity.fromJson(Map<String, dynamic> json) =
      _$CustomerActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get customerId;
  @override
  CustomerActivityType get type;
  @override
  String get description;
  @override
  String? get performedBy;
  @override
  String? get performedByName;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime get createdAt;

  /// Create a copy of CustomerActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerActivityImplCopyWith<_$CustomerActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
