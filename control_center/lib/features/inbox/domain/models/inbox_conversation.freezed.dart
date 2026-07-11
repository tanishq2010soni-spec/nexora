// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InboxConversation _$InboxConversationFromJson(Map<String, dynamic> json) {
  return _InboxConversation.fromJson(json);
}

/// @nodoc
mixin _$InboxConversation {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  InboxChannel get channel => throw _privateConstructorUsedError;
  String get platformUserId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String? get customerPhone => throw _privateConstructorUsedError;
  String? get customerEmail => throw _privateConstructorUsedError;
  String? get lastMessage => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  InboxStatus get status => throw _privateConstructorUsedError;
  String? get assignedTo => throw _privateConstructorUsedError;
  String? get assignedToName => throw _privateConstructorUsedError;
  TakeoverMode get takeoverMode => throw _privateConstructorUsedError;
  int get messageCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this InboxConversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InboxConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InboxConversationCopyWith<InboxConversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InboxConversationCopyWith<$Res> {
  factory $InboxConversationCopyWith(
    InboxConversation value,
    $Res Function(InboxConversation) then,
  ) = _$InboxConversationCopyWithImpl<$Res, InboxConversation>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String customerId,
    InboxChannel channel,
    String platformUserId,
    String customerName,
    String? customerPhone,
    String? customerEmail,
    String? lastMessage,
    int unreadCount,
    InboxStatus status,
    String? assignedTo,
    String? assignedToName,
    TakeoverMode takeoverMode,
    int messageCount,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$InboxConversationCopyWithImpl<$Res, $Val extends InboxConversation>
    implements $InboxConversationCopyWith<$Res> {
  _$InboxConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InboxConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? customerId = null,
    Object? channel = null,
    Object? platformUserId = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? customerEmail = freezed,
    Object? lastMessage = freezed,
    Object? unreadCount = null,
    Object? status = null,
    Object? assignedTo = freezed,
    Object? assignedToName = freezed,
    Object? takeoverMode = null,
    Object? messageCount = null,
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
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            channel: null == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as InboxChannel,
            platformUserId: null == platformUserId
                ? _value.platformUserId
                : platformUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            customerPhone: freezed == customerPhone
                ? _value.customerPhone
                : customerPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerEmail: freezed == customerEmail
                ? _value.customerEmail
                : customerEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            unreadCount: null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as InboxStatus,
            assignedTo: freezed == assignedTo
                ? _value.assignedTo
                : assignedTo // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedToName: freezed == assignedToName
                ? _value.assignedToName
                : assignedToName // ignore: cast_nullable_to_non_nullable
                      as String?,
            takeoverMode: null == takeoverMode
                ? _value.takeoverMode
                : takeoverMode // ignore: cast_nullable_to_non_nullable
                      as TakeoverMode,
            messageCount: null == messageCount
                ? _value.messageCount
                : messageCount // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$InboxConversationImplCopyWith<$Res>
    implements $InboxConversationCopyWith<$Res> {
  factory _$$InboxConversationImplCopyWith(
    _$InboxConversationImpl value,
    $Res Function(_$InboxConversationImpl) then,
  ) = __$$InboxConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String customerId,
    InboxChannel channel,
    String platformUserId,
    String customerName,
    String? customerPhone,
    String? customerEmail,
    String? lastMessage,
    int unreadCount,
    InboxStatus status,
    String? assignedTo,
    String? assignedToName,
    TakeoverMode takeoverMode,
    int messageCount,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$InboxConversationImplCopyWithImpl<$Res>
    extends _$InboxConversationCopyWithImpl<$Res, _$InboxConversationImpl>
    implements _$$InboxConversationImplCopyWith<$Res> {
  __$$InboxConversationImplCopyWithImpl(
    _$InboxConversationImpl _value,
    $Res Function(_$InboxConversationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InboxConversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? customerId = null,
    Object? channel = null,
    Object? platformUserId = null,
    Object? customerName = null,
    Object? customerPhone = freezed,
    Object? customerEmail = freezed,
    Object? lastMessage = freezed,
    Object? unreadCount = null,
    Object? status = null,
    Object? assignedTo = freezed,
    Object? assignedToName = freezed,
    Object? takeoverMode = null,
    Object? messageCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$InboxConversationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        channel: null == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as InboxChannel,
        platformUserId: null == platformUserId
            ? _value.platformUserId
            : platformUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        customerPhone: freezed == customerPhone
            ? _value.customerPhone
            : customerPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerEmail: freezed == customerEmail
            ? _value.customerEmail
            : customerEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        unreadCount: null == unreadCount
            ? _value.unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as InboxStatus,
        assignedTo: freezed == assignedTo
            ? _value.assignedTo
            : assignedTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedToName: freezed == assignedToName
            ? _value.assignedToName
            : assignedToName // ignore: cast_nullable_to_non_nullable
                  as String?,
        takeoverMode: null == takeoverMode
            ? _value.takeoverMode
            : takeoverMode // ignore: cast_nullable_to_non_nullable
                  as TakeoverMode,
        messageCount: null == messageCount
            ? _value.messageCount
            : messageCount // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$InboxConversationImpl implements _InboxConversation {
  const _$InboxConversationImpl({
    required this.id,
    required this.orgId,
    required this.customerId,
    required this.channel,
    required this.platformUserId,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.lastMessage,
    this.unreadCount = 0,
    required this.status,
    this.assignedTo,
    this.assignedToName,
    required this.takeoverMode,
    this.messageCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$InboxConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$InboxConversationImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String customerId;
  @override
  final InboxChannel channel;
  @override
  final String platformUserId;
  @override
  final String customerName;
  @override
  final String? customerPhone;
  @override
  final String? customerEmail;
  @override
  final String? lastMessage;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  final InboxStatus status;
  @override
  final String? assignedTo;
  @override
  final String? assignedToName;
  @override
  final TakeoverMode takeoverMode;
  @override
  @JsonKey()
  final int messageCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'InboxConversation(id: $id, orgId: $orgId, customerId: $customerId, channel: $channel, platformUserId: $platformUserId, customerName: $customerName, customerPhone: $customerPhone, customerEmail: $customerEmail, lastMessage: $lastMessage, unreadCount: $unreadCount, status: $status, assignedTo: $assignedTo, assignedToName: $assignedToName, takeoverMode: $takeoverMode, messageCount: $messageCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InboxConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.platformUserId, platformUserId) ||
                other.platformUserId == platformUserId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.customerEmail, customerEmail) ||
                other.customerEmail == customerEmail) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.assignedToName, assignedToName) ||
                other.assignedToName == assignedToName) &&
            (identical(other.takeoverMode, takeoverMode) ||
                other.takeoverMode == takeoverMode) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
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
    customerId,
    channel,
    platformUserId,
    customerName,
    customerPhone,
    customerEmail,
    lastMessage,
    unreadCount,
    status,
    assignedTo,
    assignedToName,
    takeoverMode,
    messageCount,
    createdAt,
    updatedAt,
  );

  /// Create a copy of InboxConversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InboxConversationImplCopyWith<_$InboxConversationImpl> get copyWith =>
      __$$InboxConversationImplCopyWithImpl<_$InboxConversationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InboxConversationImplToJson(this);
  }
}

abstract class _InboxConversation implements InboxConversation {
  const factory _InboxConversation({
    required final String id,
    required final String orgId,
    required final String customerId,
    required final InboxChannel channel,
    required final String platformUserId,
    required final String customerName,
    final String? customerPhone,
    final String? customerEmail,
    final String? lastMessage,
    final int unreadCount,
    required final InboxStatus status,
    final String? assignedTo,
    final String? assignedToName,
    required final TakeoverMode takeoverMode,
    final int messageCount,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$InboxConversationImpl;

  factory _InboxConversation.fromJson(Map<String, dynamic> json) =
      _$InboxConversationImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get customerId;
  @override
  InboxChannel get channel;
  @override
  String get platformUserId;
  @override
  String get customerName;
  @override
  String? get customerPhone;
  @override
  String? get customerEmail;
  @override
  String? get lastMessage;
  @override
  int get unreadCount;
  @override
  InboxStatus get status;
  @override
  String? get assignedTo;
  @override
  String? get assignedToName;
  @override
  TakeoverMode get takeoverMode;
  @override
  int get messageCount;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of InboxConversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InboxConversationImplCopyWith<_$InboxConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
