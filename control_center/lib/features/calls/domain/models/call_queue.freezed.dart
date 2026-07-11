// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_queue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CallQueue _$CallQueueFromJson(Map<String, dynamic> json) {
  return _CallQueue.fromJson(json);
}

/// @nodoc
mixin _$CallQueue {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  RoutingStrategy get routingStrategy => throw _privateConstructorUsedError;
  int get maxWaitTime => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CallQueue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CallQueue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CallQueueCopyWith<CallQueue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CallQueueCopyWith<$Res> {
  factory $CallQueueCopyWith(CallQueue value, $Res Function(CallQueue) then) =
      _$CallQueueCopyWithImpl<$Res, CallQueue>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String? description,
    RoutingStrategy routingStrategy,
    int maxWaitTime,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CallQueueCopyWithImpl<$Res, $Val extends CallQueue>
    implements $CallQueueCopyWith<$Res> {
  _$CallQueueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CallQueue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? description = freezed,
    Object? routingStrategy = null,
    Object? maxWaitTime = null,
    Object? isActive = null,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            routingStrategy: null == routingStrategy
                ? _value.routingStrategy
                : routingStrategy // ignore: cast_nullable_to_non_nullable
                      as RoutingStrategy,
            maxWaitTime: null == maxWaitTime
                ? _value.maxWaitTime
                : maxWaitTime // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$CallQueueImplCopyWith<$Res>
    implements $CallQueueCopyWith<$Res> {
  factory _$$CallQueueImplCopyWith(
    _$CallQueueImpl value,
    $Res Function(_$CallQueueImpl) then,
  ) = __$$CallQueueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String? description,
    RoutingStrategy routingStrategy,
    int maxWaitTime,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CallQueueImplCopyWithImpl<$Res>
    extends _$CallQueueCopyWithImpl<$Res, _$CallQueueImpl>
    implements _$$CallQueueImplCopyWith<$Res> {
  __$$CallQueueImplCopyWithImpl(
    _$CallQueueImpl _value,
    $Res Function(_$CallQueueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CallQueue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? description = freezed,
    Object? routingStrategy = null,
    Object? maxWaitTime = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$CallQueueImpl(
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
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        routingStrategy: null == routingStrategy
            ? _value.routingStrategy
            : routingStrategy // ignore: cast_nullable_to_non_nullable
                  as RoutingStrategy,
        maxWaitTime: null == maxWaitTime
            ? _value.maxWaitTime
            : maxWaitTime // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$CallQueueImpl implements _CallQueue {
  const _$CallQueueImpl({
    required this.id,
    required this.orgId,
    required this.name,
    this.description,
    this.routingStrategy = RoutingStrategy.roundRobin,
    this.maxWaitTime = 300,
    this.isActive = true,
    required this.createdAt,
  });

  factory _$CallQueueImpl.fromJson(Map<String, dynamic> json) =>
      _$$CallQueueImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final RoutingStrategy routingStrategy;
  @override
  @JsonKey()
  final int maxWaitTime;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CallQueue(id: $id, orgId: $orgId, name: $name, description: $description, routingStrategy: $routingStrategy, maxWaitTime: $maxWaitTime, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CallQueueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.routingStrategy, routingStrategy) ||
                other.routingStrategy == routingStrategy) &&
            (identical(other.maxWaitTime, maxWaitTime) ||
                other.maxWaitTime == maxWaitTime) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
    description,
    routingStrategy,
    maxWaitTime,
    isActive,
    createdAt,
  );

  /// Create a copy of CallQueue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CallQueueImplCopyWith<_$CallQueueImpl> get copyWith =>
      __$$CallQueueImplCopyWithImpl<_$CallQueueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CallQueueImplToJson(this);
  }
}

abstract class _CallQueue implements CallQueue {
  const factory _CallQueue({
    required final String id,
    required final String orgId,
    required final String name,
    final String? description,
    final RoutingStrategy routingStrategy,
    final int maxWaitTime,
    final bool isActive,
    required final DateTime createdAt,
  }) = _$CallQueueImpl;

  factory _CallQueue.fromJson(Map<String, dynamic> json) =
      _$CallQueueImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get name;
  @override
  String? get description;
  @override
  RoutingStrategy get routingStrategy;
  @override
  int get maxWaitTime;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;

  /// Create a copy of CallQueue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CallQueueImplCopyWith<_$CallQueueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
