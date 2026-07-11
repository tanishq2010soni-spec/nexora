// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbox_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InboxMessage _$InboxMessageFromJson(Map<String, dynamic> json) {
  return _InboxMessage.fromJson(json);
}

/// @nodoc
mixin _$InboxMessage {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  MessageSenderType get senderType => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get channel => throw _privateConstructorUsedError;
  String? get attachmentUrl => throw _privateConstructorUsedError;
  String? get attachmentType => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  String? get platformMessageId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this InboxMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InboxMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InboxMessageCopyWith<InboxMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InboxMessageCopyWith<$Res> {
  factory $InboxMessageCopyWith(
    InboxMessage value,
    $Res Function(InboxMessage) then,
  ) = _$InboxMessageCopyWithImpl<$Res, InboxMessage>;
  @useResult
  $Res call({
    String id,
    String conversationId,
    MessageSenderType senderType,
    String content,
    String channel,
    String? attachmentUrl,
    String? attachmentType,
    bool isRead,
    String? platformMessageId,
    DateTime createdAt,
  });
}

/// @nodoc
class _$InboxMessageCopyWithImpl<$Res, $Val extends InboxMessage>
    implements $InboxMessageCopyWith<$Res> {
  _$InboxMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InboxMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderType = null,
    Object? content = null,
    Object? channel = null,
    Object? attachmentUrl = freezed,
    Object? attachmentType = freezed,
    Object? isRead = null,
    Object? platformMessageId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            conversationId: null == conversationId
                ? _value.conversationId
                : conversationId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderType: null == senderType
                ? _value.senderType
                : senderType // ignore: cast_nullable_to_non_nullable
                      as MessageSenderType,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            channel: null == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as String,
            attachmentUrl: freezed == attachmentUrl
                ? _value.attachmentUrl
                : attachmentUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            attachmentType: freezed == attachmentType
                ? _value.attachmentType
                : attachmentType // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            platformMessageId: freezed == platformMessageId
                ? _value.platformMessageId
                : platformMessageId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$InboxMessageImplCopyWith<$Res>
    implements $InboxMessageCopyWith<$Res> {
  factory _$$InboxMessageImplCopyWith(
    _$InboxMessageImpl value,
    $Res Function(_$InboxMessageImpl) then,
  ) = __$$InboxMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String conversationId,
    MessageSenderType senderType,
    String content,
    String channel,
    String? attachmentUrl,
    String? attachmentType,
    bool isRead,
    String? platformMessageId,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$InboxMessageImplCopyWithImpl<$Res>
    extends _$InboxMessageCopyWithImpl<$Res, _$InboxMessageImpl>
    implements _$$InboxMessageImplCopyWith<$Res> {
  __$$InboxMessageImplCopyWithImpl(
    _$InboxMessageImpl _value,
    $Res Function(_$InboxMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InboxMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderType = null,
    Object? content = null,
    Object? channel = null,
    Object? attachmentUrl = freezed,
    Object? attachmentType = freezed,
    Object? isRead = null,
    Object? platformMessageId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$InboxMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        conversationId: null == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderType: null == senderType
            ? _value.senderType
            : senderType // ignore: cast_nullable_to_non_nullable
                  as MessageSenderType,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        channel: null == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as String,
        attachmentUrl: freezed == attachmentUrl
            ? _value.attachmentUrl
            : attachmentUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        attachmentType: freezed == attachmentType
            ? _value.attachmentType
            : attachmentType // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        platformMessageId: freezed == platformMessageId
            ? _value.platformMessageId
            : platformMessageId // ignore: cast_nullable_to_non_nullable
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
class _$InboxMessageImpl implements _InboxMessage {
  const _$InboxMessageImpl({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.content,
    required this.channel,
    this.attachmentUrl,
    this.attachmentType,
    this.isRead = false,
    this.platformMessageId,
    required this.createdAt,
  });

  factory _$InboxMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$InboxMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final MessageSenderType senderType;
  @override
  final String content;
  @override
  final String channel;
  @override
  final String? attachmentUrl;
  @override
  final String? attachmentType;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final String? platformMessageId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'InboxMessage(id: $id, conversationId: $conversationId, senderType: $senderType, content: $content, channel: $channel, attachmentUrl: $attachmentUrl, attachmentType: $attachmentType, isRead: $isRead, platformMessageId: $platformMessageId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InboxMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.senderType, senderType) ||
                other.senderType == senderType) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.attachmentUrl, attachmentUrl) ||
                other.attachmentUrl == attachmentUrl) &&
            (identical(other.attachmentType, attachmentType) ||
                other.attachmentType == attachmentType) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.platformMessageId, platformMessageId) ||
                other.platformMessageId == platformMessageId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    conversationId,
    senderType,
    content,
    channel,
    attachmentUrl,
    attachmentType,
    isRead,
    platformMessageId,
    createdAt,
  );

  /// Create a copy of InboxMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InboxMessageImplCopyWith<_$InboxMessageImpl> get copyWith =>
      __$$InboxMessageImplCopyWithImpl<_$InboxMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InboxMessageImplToJson(this);
  }
}

abstract class _InboxMessage implements InboxMessage {
  const factory _InboxMessage({
    required final String id,
    required final String conversationId,
    required final MessageSenderType senderType,
    required final String content,
    required final String channel,
    final String? attachmentUrl,
    final String? attachmentType,
    final bool isRead,
    final String? platformMessageId,
    required final DateTime createdAt,
  }) = _$InboxMessageImpl;

  factory _InboxMessage.fromJson(Map<String, dynamic> json) =
      _$InboxMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  MessageSenderType get senderType;
  @override
  String get content;
  @override
  String get channel;
  @override
  String? get attachmentUrl;
  @override
  String? get attachmentType;
  @override
  bool get isRead;
  @override
  String? get platformMessageId;
  @override
  DateTime get createdAt;

  /// Create a copy of InboxMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InboxMessageImplCopyWith<_$InboxMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
