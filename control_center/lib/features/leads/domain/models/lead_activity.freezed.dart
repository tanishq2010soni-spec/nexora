// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeadActivity _$LeadActivityFromJson(Map<String, dynamic> json) {
  return _LeadActivity.fromJson(json);
}

/// @nodoc
mixin _$LeadActivity {
  String get id => throw _privateConstructorUsedError;
  String get leadId => throw _privateConstructorUsedError;
  ActivityType get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get performedBy => throw _privateConstructorUsedError;
  String? get oldValue => throw _privateConstructorUsedError;
  String? get newValue => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LeadActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadActivityCopyWith<LeadActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadActivityCopyWith<$Res> {
  factory $LeadActivityCopyWith(
    LeadActivity value,
    $Res Function(LeadActivity) then,
  ) = _$LeadActivityCopyWithImpl<$Res, LeadActivity>;
  @useResult
  $Res call({
    String id,
    String leadId,
    ActivityType type,
    String description,
    String? performedBy,
    String? oldValue,
    String? newValue,
    DateTime createdAt,
  });
}

/// @nodoc
class _$LeadActivityCopyWithImpl<$Res, $Val extends LeadActivity>
    implements $LeadActivityCopyWith<$Res> {
  _$LeadActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? leadId = null,
    Object? type = null,
    Object? description = null,
    Object? performedBy = freezed,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            leadId: null == leadId
                ? _value.leadId
                : leadId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ActivityType,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            performedBy: freezed == performedBy
                ? _value.performedBy
                : performedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            oldValue: freezed == oldValue
                ? _value.oldValue
                : oldValue // ignore: cast_nullable_to_non_nullable
                      as String?,
            newValue: freezed == newValue
                ? _value.newValue
                : newValue // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$LeadActivityImplCopyWith<$Res>
    implements $LeadActivityCopyWith<$Res> {
  factory _$$LeadActivityImplCopyWith(
    _$LeadActivityImpl value,
    $Res Function(_$LeadActivityImpl) then,
  ) = __$$LeadActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String leadId,
    ActivityType type,
    String description,
    String? performedBy,
    String? oldValue,
    String? newValue,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$LeadActivityImplCopyWithImpl<$Res>
    extends _$LeadActivityCopyWithImpl<$Res, _$LeadActivityImpl>
    implements _$$LeadActivityImplCopyWith<$Res> {
  __$$LeadActivityImplCopyWithImpl(
    _$LeadActivityImpl _value,
    $Res Function(_$LeadActivityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? leadId = null,
    Object? type = null,
    Object? description = null,
    Object? performedBy = freezed,
    Object? oldValue = freezed,
    Object? newValue = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$LeadActivityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        leadId: null == leadId
            ? _value.leadId
            : leadId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ActivityType,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        performedBy: freezed == performedBy
            ? _value.performedBy
            : performedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        oldValue: freezed == oldValue
            ? _value.oldValue
            : oldValue // ignore: cast_nullable_to_non_nullable
                  as String?,
        newValue: freezed == newValue
            ? _value.newValue
            : newValue // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$LeadActivityImpl implements _LeadActivity {
  const _$LeadActivityImpl({
    required this.id,
    required this.leadId,
    required this.type,
    required this.description,
    this.performedBy,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  factory _$LeadActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String leadId;
  @override
  final ActivityType type;
  @override
  final String description;
  @override
  final String? performedBy;
  @override
  final String? oldValue;
  @override
  final String? newValue;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LeadActivity(id: $id, leadId: $leadId, type: $type, description: $description, performedBy: $performedBy, oldValue: $oldValue, newValue: $newValue, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.leadId, leadId) || other.leadId == leadId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            (identical(other.oldValue, oldValue) ||
                other.oldValue == oldValue) &&
            (identical(other.newValue, newValue) ||
                other.newValue == newValue) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    leadId,
    type,
    description,
    performedBy,
    oldValue,
    newValue,
    createdAt,
  );

  /// Create a copy of LeadActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadActivityImplCopyWith<_$LeadActivityImpl> get copyWith =>
      __$$LeadActivityImplCopyWithImpl<_$LeadActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadActivityImplToJson(this);
  }
}

abstract class _LeadActivity implements LeadActivity {
  const factory _LeadActivity({
    required final String id,
    required final String leadId,
    required final ActivityType type,
    required final String description,
    final String? performedBy,
    final String? oldValue,
    final String? newValue,
    required final DateTime createdAt,
  }) = _$LeadActivityImpl;

  factory _LeadActivity.fromJson(Map<String, dynamic> json) =
      _$LeadActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get leadId;
  @override
  ActivityType get type;
  @override
  String get description;
  @override
  String? get performedBy;
  @override
  String? get oldValue;
  @override
  String? get newValue;
  @override
  DateTime get createdAt;

  /// Create a copy of LeadActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadActivityImplCopyWith<_$LeadActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
