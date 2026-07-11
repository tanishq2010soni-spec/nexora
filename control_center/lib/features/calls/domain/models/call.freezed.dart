// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VoiceCall _$VoiceCallFromJson(Map<String, dynamic> json) {
  return _VoiceCall.fromJson(json);
}

/// @nodoc
mixin _$VoiceCall {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  CallDirection get direction => throw _privateConstructorUsedError;
  String get callerNumber => throw _privateConstructorUsedError;
  String get calleeNumber => throw _privateConstructorUsedError;
  CallStatus get status => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get answeredAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  String? get recordingUrl => throw _privateConstructorUsedError;
  String? get transcription => throw _privateConstructorUsedError;
  CallSentiment? get sentiment => throw _privateConstructorUsedError;
  CallOutcome? get outcome => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VoiceCall to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceCall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceCallCopyWith<VoiceCall> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceCallCopyWith<$Res> {
  factory $VoiceCallCopyWith(VoiceCall value, $Res Function(VoiceCall) then) =
      _$VoiceCallCopyWithImpl<$Res, VoiceCall>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String agentId,
    CallDirection direction,
    String callerNumber,
    String calleeNumber,
    CallStatus status,
    DateTime? startedAt,
    DateTime? answeredAt,
    DateTime? endedAt,
    int durationSeconds,
    String? recordingUrl,
    String? transcription,
    CallSentiment? sentiment,
    CallOutcome? outcome,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$VoiceCallCopyWithImpl<$Res, $Val extends VoiceCall>
    implements $VoiceCallCopyWith<$Res> {
  _$VoiceCallCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceCall
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? agentId = null,
    Object? direction = null,
    Object? callerNumber = null,
    Object? calleeNumber = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? answeredAt = freezed,
    Object? endedAt = freezed,
    Object? durationSeconds = null,
    Object? recordingUrl = freezed,
    Object? transcription = freezed,
    Object? sentiment = freezed,
    Object? outcome = freezed,
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
            agentId: null == agentId
                ? _value.agentId
                : agentId // ignore: cast_nullable_to_non_nullable
                      as String,
            direction: null == direction
                ? _value.direction
                : direction // ignore: cast_nullable_to_non_nullable
                      as CallDirection,
            callerNumber: null == callerNumber
                ? _value.callerNumber
                : callerNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            calleeNumber: null == calleeNumber
                ? _value.calleeNumber
                : calleeNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as CallStatus,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            answeredAt: freezed == answeredAt
                ? _value.answeredAt
                : answeredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            durationSeconds: null == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            recordingUrl: freezed == recordingUrl
                ? _value.recordingUrl
                : recordingUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            transcription: freezed == transcription
                ? _value.transcription
                : transcription // ignore: cast_nullable_to_non_nullable
                      as String?,
            sentiment: freezed == sentiment
                ? _value.sentiment
                : sentiment // ignore: cast_nullable_to_non_nullable
                      as CallSentiment?,
            outcome: freezed == outcome
                ? _value.outcome
                : outcome // ignore: cast_nullable_to_non_nullable
                      as CallOutcome?,
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
abstract class _$$VoiceCallImplCopyWith<$Res>
    implements $VoiceCallCopyWith<$Res> {
  factory _$$VoiceCallImplCopyWith(
    _$VoiceCallImpl value,
    $Res Function(_$VoiceCallImpl) then,
  ) = __$$VoiceCallImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String agentId,
    CallDirection direction,
    String callerNumber,
    String calleeNumber,
    CallStatus status,
    DateTime? startedAt,
    DateTime? answeredAt,
    DateTime? endedAt,
    int durationSeconds,
    String? recordingUrl,
    String? transcription,
    CallSentiment? sentiment,
    CallOutcome? outcome,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$VoiceCallImplCopyWithImpl<$Res>
    extends _$VoiceCallCopyWithImpl<$Res, _$VoiceCallImpl>
    implements _$$VoiceCallImplCopyWith<$Res> {
  __$$VoiceCallImplCopyWithImpl(
    _$VoiceCallImpl _value,
    $Res Function(_$VoiceCallImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VoiceCall
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? agentId = null,
    Object? direction = null,
    Object? callerNumber = null,
    Object? calleeNumber = null,
    Object? status = null,
    Object? startedAt = freezed,
    Object? answeredAt = freezed,
    Object? endedAt = freezed,
    Object? durationSeconds = null,
    Object? recordingUrl = freezed,
    Object? transcription = freezed,
    Object? sentiment = freezed,
    Object? outcome = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$VoiceCallImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        agentId: null == agentId
            ? _value.agentId
            : agentId // ignore: cast_nullable_to_non_nullable
                  as String,
        direction: null == direction
            ? _value.direction
            : direction // ignore: cast_nullable_to_non_nullable
                  as CallDirection,
        callerNumber: null == callerNumber
            ? _value.callerNumber
            : callerNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        calleeNumber: null == calleeNumber
            ? _value.calleeNumber
            : calleeNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as CallStatus,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        answeredAt: freezed == answeredAt
            ? _value.answeredAt
            : answeredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        recordingUrl: freezed == recordingUrl
            ? _value.recordingUrl
            : recordingUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        transcription: freezed == transcription
            ? _value.transcription
            : transcription // ignore: cast_nullable_to_non_nullable
                  as String?,
        sentiment: freezed == sentiment
            ? _value.sentiment
            : sentiment // ignore: cast_nullable_to_non_nullable
                  as CallSentiment?,
        outcome: freezed == outcome
            ? _value.outcome
            : outcome // ignore: cast_nullable_to_non_nullable
                  as CallOutcome?,
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
class _$VoiceCallImpl implements _VoiceCall {
  const _$VoiceCallImpl({
    required this.id,
    required this.orgId,
    required this.agentId,
    required this.direction,
    required this.callerNumber,
    required this.calleeNumber,
    required this.status,
    this.startedAt,
    this.answeredAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.recordingUrl,
    this.transcription,
    this.sentiment,
    this.outcome,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$VoiceCallImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceCallImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String agentId;
  @override
  final CallDirection direction;
  @override
  final String callerNumber;
  @override
  final String calleeNumber;
  @override
  final CallStatus status;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? answeredAt;
  @override
  final DateTime? endedAt;
  @override
  @JsonKey()
  final int durationSeconds;
  @override
  final String? recordingUrl;
  @override
  final String? transcription;
  @override
  final CallSentiment? sentiment;
  @override
  final CallOutcome? outcome;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'VoiceCall(id: $id, orgId: $orgId, agentId: $agentId, direction: $direction, callerNumber: $callerNumber, calleeNumber: $calleeNumber, status: $status, startedAt: $startedAt, answeredAt: $answeredAt, endedAt: $endedAt, durationSeconds: $durationSeconds, recordingUrl: $recordingUrl, transcription: $transcription, sentiment: $sentiment, outcome: $outcome, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceCallImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.callerNumber, callerNumber) ||
                other.callerNumber == callerNumber) &&
            (identical(other.calleeNumber, calleeNumber) ||
                other.calleeNumber == calleeNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.answeredAt, answeredAt) ||
                other.answeredAt == answeredAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.recordingUrl, recordingUrl) ||
                other.recordingUrl == recordingUrl) &&
            (identical(other.transcription, transcription) ||
                other.transcription == transcription) &&
            (identical(other.sentiment, sentiment) ||
                other.sentiment == sentiment) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
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
    agentId,
    direction,
    callerNumber,
    calleeNumber,
    status,
    startedAt,
    answeredAt,
    endedAt,
    durationSeconds,
    recordingUrl,
    transcription,
    sentiment,
    outcome,
    createdAt,
    updatedAt,
  );

  /// Create a copy of VoiceCall
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceCallImplCopyWith<_$VoiceCallImpl> get copyWith =>
      __$$VoiceCallImplCopyWithImpl<_$VoiceCallImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceCallImplToJson(this);
  }
}

abstract class _VoiceCall implements VoiceCall {
  const factory _VoiceCall({
    required final String id,
    required final String orgId,
    required final String agentId,
    required final CallDirection direction,
    required final String callerNumber,
    required final String calleeNumber,
    required final CallStatus status,
    final DateTime? startedAt,
    final DateTime? answeredAt,
    final DateTime? endedAt,
    final int durationSeconds,
    final String? recordingUrl,
    final String? transcription,
    final CallSentiment? sentiment,
    final CallOutcome? outcome,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$VoiceCallImpl;

  factory _VoiceCall.fromJson(Map<String, dynamic> json) =
      _$VoiceCallImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get agentId;
  @override
  CallDirection get direction;
  @override
  String get callerNumber;
  @override
  String get calleeNumber;
  @override
  CallStatus get status;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get answeredAt;
  @override
  DateTime? get endedAt;
  @override
  int get durationSeconds;
  @override
  String? get recordingUrl;
  @override
  String? get transcription;
  @override
  CallSentiment? get sentiment;
  @override
  CallOutcome? get outcome;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of VoiceCall
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceCallImplCopyWith<_$VoiceCallImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
