// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return _Conversation.fromJson(json);
}

/// @nodoc
mixin _$Conversation {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get externalUserId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  String get agentName => throw _privateConstructorUsedError;
  ConversationPlatform get platform => throw _privateConstructorUsedError;
  ConversationStatus get status => throw _privateConstructorUsedError;
  int get messageCount => throw _privateConstructorUsedError;
  int get callDurationSeconds => throw _privateConstructorUsedError;
  String? get lastMessagePreview => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  String? get assignedTo => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
    Conversation value,
    $Res Function(Conversation) then,
  ) = _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String externalUserId,
    String agentId,
    String agentName,
    ConversationPlatform platform,
    ConversationStatus status,
    int messageCount,
    int callDurationSeconds,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    String? assignedTo,
    Map<String, dynamic>? metadata,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? externalUserId = null,
    Object? agentId = null,
    Object? agentName = null,
    Object? platform = null,
    Object? status = null,
    Object? messageCount = null,
    Object? callDurationSeconds = null,
    Object? lastMessagePreview = freezed,
    Object? lastMessageAt = freezed,
    Object? assignedTo = freezed,
    Object? metadata = freezed,
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
            externalUserId: null == externalUserId
                ? _value.externalUserId
                : externalUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            agentId: null == agentId
                ? _value.agentId
                : agentId // ignore: cast_nullable_to_non_nullable
                      as String,
            agentName: null == agentName
                ? _value.agentName
                : agentName // ignore: cast_nullable_to_non_nullable
                      as String,
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as ConversationPlatform,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ConversationStatus,
            messageCount: null == messageCount
                ? _value.messageCount
                : messageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            callDurationSeconds: null == callDurationSeconds
                ? _value.callDurationSeconds
                : callDurationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            lastMessagePreview: freezed == lastMessagePreview
                ? _value.lastMessagePreview
                : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMessageAt: freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            assignedTo: freezed == assignedTo
                ? _value.assignedTo
                : assignedTo // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
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
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
    _$ConversationImpl value,
    $Res Function(_$ConversationImpl) then,
  ) = __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String externalUserId,
    String agentId,
    String agentName,
    ConversationPlatform platform,
    ConversationStatus status,
    int messageCount,
    int callDurationSeconds,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    String? assignedTo,
    Map<String, dynamic>? metadata,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
    _$ConversationImpl _value,
    $Res Function(_$ConversationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? externalUserId = null,
    Object? agentId = null,
    Object? agentName = null,
    Object? platform = null,
    Object? status = null,
    Object? messageCount = null,
    Object? callDurationSeconds = null,
    Object? lastMessagePreview = freezed,
    Object? lastMessageAt = freezed,
    Object? assignedTo = freezed,
    Object? metadata = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ConversationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        externalUserId: null == externalUserId
            ? _value.externalUserId
            : externalUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        agentId: null == agentId
            ? _value.agentId
            : agentId // ignore: cast_nullable_to_non_nullable
                  as String,
        agentName: null == agentName
            ? _value.agentName
            : agentName // ignore: cast_nullable_to_non_nullable
                  as String,
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as ConversationPlatform,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ConversationStatus,
        messageCount: null == messageCount
            ? _value.messageCount
            : messageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        callDurationSeconds: null == callDurationSeconds
            ? _value.callDurationSeconds
            : callDurationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        lastMessagePreview: freezed == lastMessagePreview
            ? _value.lastMessagePreview
            : lastMessagePreview // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMessageAt: freezed == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        assignedTo: freezed == assignedTo
            ? _value.assignedTo
            : assignedTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
class _$ConversationImpl implements _Conversation {
  const _$ConversationImpl({
    required this.id,
    required this.orgId,
    required this.externalUserId,
    required this.agentId,
    required this.agentName,
    required this.platform,
    required this.status,
    this.messageCount = 0,
    this.callDurationSeconds = 0,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.assignedTo,
    final Map<String, dynamic>? metadata,
    required this.createdAt,
    required this.updatedAt,
  }) : _metadata = metadata;

  factory _$ConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String externalUserId;
  @override
  final String agentId;
  @override
  final String agentName;
  @override
  final ConversationPlatform platform;
  @override
  final ConversationStatus status;
  @override
  @JsonKey()
  final int messageCount;
  @override
  @JsonKey()
  final int callDurationSeconds;
  @override
  final String? lastMessagePreview;
  @override
  final DateTime? lastMessageAt;
  @override
  final String? assignedTo;
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
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Conversation(id: $id, orgId: $orgId, externalUserId: $externalUserId, agentId: $agentId, agentName: $agentName, platform: $platform, status: $status, messageCount: $messageCount, callDurationSeconds: $callDurationSeconds, lastMessagePreview: $lastMessagePreview, lastMessageAt: $lastMessageAt, assignedTo: $assignedTo, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.externalUserId, externalUserId) ||
                other.externalUserId == externalUserId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
            (identical(other.callDurationSeconds, callDurationSeconds) ||
                other.callDurationSeconds == callDurationSeconds) &&
            (identical(other.lastMessagePreview, lastMessagePreview) ||
                other.lastMessagePreview == lastMessagePreview) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
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
    externalUserId,
    agentId,
    agentName,
    platform,
    status,
    messageCount,
    callDurationSeconds,
    lastMessagePreview,
    lastMessageAt,
    assignedTo,
    const DeepCollectionEquality().hash(_metadata),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationImplToJson(this);
  }
}

abstract class _Conversation implements Conversation {
  const factory _Conversation({
    required final String id,
    required final String orgId,
    required final String externalUserId,
    required final String agentId,
    required final String agentName,
    required final ConversationPlatform platform,
    required final ConversationStatus status,
    final int messageCount,
    final int callDurationSeconds,
    final String? lastMessagePreview,
    final DateTime? lastMessageAt,
    final String? assignedTo,
    final Map<String, dynamic>? metadata,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ConversationImpl;

  factory _Conversation.fromJson(Map<String, dynamic> json) =
      _$ConversationImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get externalUserId;
  @override
  String get agentId;
  @override
  String get agentName;
  @override
  ConversationPlatform get platform;
  @override
  ConversationStatus get status;
  @override
  int get messageCount;
  @override
  int get callDurationSeconds;
  @override
  String? get lastMessagePreview;
  @override
  DateTime? get lastMessageAt;
  @override
  String? get assignedTo;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
