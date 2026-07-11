// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) {
  return _Subscription.fromJson(json);
}

/// @nodoc
mixin _$Subscription {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get planId => throw _privateConstructorUsedError;
  String get planName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get interval => throw _privateConstructorUsedError;
  DateTime? get currentPeriodStart => throw _privateConstructorUsedError;
  DateTime? get currentPeriodEnd => throw _privateConstructorUsedError;
  DateTime? get cancelAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Subscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
    Subscription value,
    $Res Function(Subscription) then,
  ) = _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String planId,
    String planName,
    String status,
    double amount,
    String interval,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? cancelAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? planId = null,
    Object? planName = null,
    Object? status = null,
    Object? amount = null,
    Object? interval = null,
    Object? currentPeriodStart = freezed,
    Object? currentPeriodEnd = freezed,
    Object? cancelAt = freezed,
    Object? createdAt = null,
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
            planId: null == planId
                ? _value.planId
                : planId // ignore: cast_nullable_to_non_nullable
                      as String,
            planName: null == planName
                ? _value.planName
                : planName // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as String,
            currentPeriodStart: freezed == currentPeriodStart
                ? _value.currentPeriodStart
                : currentPeriodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            currentPeriodEnd: freezed == currentPeriodEnd
                ? _value.currentPeriodEnd
                : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cancelAt: freezed == cancelAt
                ? _value.cancelAt
                : cancelAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
    _$SubscriptionImpl value,
    $Res Function(_$SubscriptionImpl) then,
  ) = __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String planId,
    String planName,
    String status,
    double amount,
    String interval,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? cancelAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
    _$SubscriptionImpl _value,
    $Res Function(_$SubscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? planId = null,
    Object? planName = null,
    Object? status = null,
    Object? amount = null,
    Object? interval = null,
    Object? currentPeriodStart = freezed,
    Object? currentPeriodEnd = freezed,
    Object? cancelAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SubscriptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        planId: null == planId
            ? _value.planId
            : planId // ignore: cast_nullable_to_non_nullable
                  as String,
        planName: null == planName
            ? _value.planName
            : planName // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as String,
        currentPeriodStart: freezed == currentPeriodStart
            ? _value.currentPeriodStart
            : currentPeriodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        currentPeriodEnd: freezed == currentPeriodEnd
            ? _value.currentPeriodEnd
            : currentPeriodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cancelAt: freezed == cancelAt
            ? _value.cancelAt
            : cancelAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$SubscriptionImpl implements _Subscription {
  const _$SubscriptionImpl({
    required this.id,
    required this.orgId,
    required this.planId,
    required this.planName,
    required this.status,
    required this.amount,
    required this.interval,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$SubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String planId;
  @override
  final String planName;
  @override
  final String status;
  @override
  final double amount;
  @override
  final String interval;
  @override
  final DateTime? currentPeriodStart;
  @override
  final DateTime? currentPeriodEnd;
  @override
  final DateTime? cancelAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Subscription(id: $id, orgId: $orgId, planId: $planId, planName: $planName, status: $status, amount: $amount, interval: $interval, currentPeriodStart: $currentPeriodStart, currentPeriodEnd: $currentPeriodEnd, cancelAt: $cancelAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.planId, planId) || other.planId == planId) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.currentPeriodStart, currentPeriodStart) ||
                other.currentPeriodStart == currentPeriodStart) &&
            (identical(other.currentPeriodEnd, currentPeriodEnd) ||
                other.currentPeriodEnd == currentPeriodEnd) &&
            (identical(other.cancelAt, cancelAt) ||
                other.cancelAt == cancelAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orgId,
    planId,
    planName,
    status,
    amount,
    interval,
    currentPeriodStart,
    currentPeriodEnd,
    cancelAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionImplToJson(this);
  }
}

abstract class _Subscription implements Subscription {
  const factory _Subscription({
    required final String id,
    required final String orgId,
    required final String planId,
    required final String planName,
    required final String status,
    required final double amount,
    required final String interval,
    final DateTime? currentPeriodStart,
    final DateTime? currentPeriodEnd,
    final DateTime? cancelAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SubscriptionImpl;

  factory _Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get planId;
  @override
  String get planName;
  @override
  String get status;
  @override
  double get amount;
  @override
  String get interval;
  @override
  DateTime? get currentPeriodStart;
  @override
  DateTime? get currentPeriodEnd;
  @override
  DateTime? get cancelAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
