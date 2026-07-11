// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CallLog _$CallLogFromJson(Map<String, dynamic> json) {
  return _CallLog.fromJson(json);
}

/// @nodoc
mixin _$CallLog {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  CallOutcome get outcome => throw _privateConstructorUsedError;
  RecordingStatus get recordingStatus => throw _privateConstructorUsedError;
  String? get transcript => throw _privateConstructorUsedError;
  String? get recordingUrl => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CallLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CallLogCopyWith<CallLog> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CallLogCopyWith<$Res> {
  factory $CallLogCopyWith(CallLog value, $Res Function(CallLog) then) =
      _$CallLogCopyWithImpl<$Res, CallLog>;
  @useResult
  $Res call({
    String id,
    String conversationId,
    String agentId,
    String phoneNumber,
    int durationSeconds,
    CallOutcome outcome,
    RecordingStatus recordingStatus,
    String? transcript,
    String? recordingUrl,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CallLogCopyWithImpl<$Res, $Val extends CallLog>
    implements $CallLogCopyWith<$Res> {
  _$CallLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? agentId = null,
    Object? phoneNumber = null,
    Object? durationSeconds = null,
    Object? outcome = null,
    Object? recordingStatus = null,
    Object? transcript = freezed,
    Object? recordingUrl = freezed,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
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
            agentId: null == agentId
                ? _value.agentId
                : agentId // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: null == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            durationSeconds: null == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            outcome: null == outcome
                ? _value.outcome
                : outcome // ignore: cast_nullable_to_non_nullable
                      as CallOutcome,
            recordingStatus: null == recordingStatus
                ? _value.recordingStatus
                : recordingStatus // ignore: cast_nullable_to_non_nullable
                      as RecordingStatus,
            transcript: freezed == transcript
                ? _value.transcript
                : transcript // ignore: cast_nullable_to_non_nullable
                      as String?,
            recordingUrl: freezed == recordingUrl
                ? _value.recordingUrl
                : recordingUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$CallLogImplCopyWith<$Res> implements $CallLogCopyWith<$Res> {
  factory _$$CallLogImplCopyWith(
    _$CallLogImpl value,
    $Res Function(_$CallLogImpl) then,
  ) = __$$CallLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String conversationId,
    String agentId,
    String phoneNumber,
    int durationSeconds,
    CallOutcome outcome,
    RecordingStatus recordingStatus,
    String? transcript,
    String? recordingUrl,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CallLogImplCopyWithImpl<$Res>
    extends _$CallLogCopyWithImpl<$Res, _$CallLogImpl>
    implements _$$CallLogImplCopyWith<$Res> {
  __$$CallLogImplCopyWithImpl(
    _$CallLogImpl _value,
    $Res Function(_$CallLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? agentId = null,
    Object? phoneNumber = null,
    Object? durationSeconds = null,
    Object? outcome = null,
    Object? recordingStatus = null,
    Object? transcript = freezed,
    Object? recordingUrl = freezed,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$CallLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        conversationId: null == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String,
        agentId: null == agentId
            ? _value.agentId
            : agentId // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: null == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        outcome: null == outcome
            ? _value.outcome
            : outcome // ignore: cast_nullable_to_non_nullable
                  as CallOutcome,
        recordingStatus: null == recordingStatus
            ? _value.recordingStatus
            : recordingStatus // ignore: cast_nullable_to_non_nullable
                  as RecordingStatus,
        transcript: freezed == transcript
            ? _value.transcript
            : transcript // ignore: cast_nullable_to_non_nullable
                  as String?,
        recordingUrl: freezed == recordingUrl
            ? _value.recordingUrl
            : recordingUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$CallLogImpl implements _CallLog {
  const _$CallLogImpl({
    required this.id,
    required this.conversationId,
    required this.agentId,
    required this.phoneNumber,
    required this.durationSeconds,
    required this.outcome,
    required this.recordingStatus,
    this.transcript,
    this.recordingUrl,
    this.startedAt,
    this.endedAt,
    required this.createdAt,
  });

  factory _$CallLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$CallLogImplFromJson(json);

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final String agentId;
  @override
  final String phoneNumber;
  @override
  final int durationSeconds;
  @override
  final CallOutcome outcome;
  @override
  final RecordingStatus recordingStatus;
  @override
  final String? transcript;
  @override
  final String? recordingUrl;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CallLog(id: $id, conversationId: $conversationId, agentId: $agentId, phoneNumber: $phoneNumber, durationSeconds: $durationSeconds, outcome: $outcome, recordingStatus: $recordingStatus, transcript: $transcript, recordingUrl: $recordingUrl, startedAt: $startedAt, endedAt: $endedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CallLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.recordingStatus, recordingStatus) ||
                other.recordingStatus == recordingStatus) &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript) &&
            (identical(other.recordingUrl, recordingUrl) ||
                other.recordingUrl == recordingUrl) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    conversationId,
    agentId,
    phoneNumber,
    durationSeconds,
    outcome,
    recordingStatus,
    transcript,
    recordingUrl,
    startedAt,
    endedAt,
    createdAt,
  );

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CallLogImplCopyWith<_$CallLogImpl> get copyWith =>
      __$$CallLogImplCopyWithImpl<_$CallLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CallLogImplToJson(this);
  }
}

abstract class _CallLog implements CallLog {
  const factory _CallLog({
    required final String id,
    required final String conversationId,
    required final String agentId,
    required final String phoneNumber,
    required final int durationSeconds,
    required final CallOutcome outcome,
    required final RecordingStatus recordingStatus,
    final String? transcript,
    final String? recordingUrl,
    final DateTime? startedAt,
    final DateTime? endedAt,
    required final DateTime createdAt,
  }) = _$CallLogImpl;

  factory _CallLog.fromJson(Map<String, dynamic> json) = _$CallLogImpl.fromJson;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  String get agentId;
  @override
  String get phoneNumber;
  @override
  int get durationSeconds;
  @override
  CallOutcome get outcome;
  @override
  RecordingStatus get recordingStatus;
  @override
  String? get transcript;
  @override
  String? get recordingUrl;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get endedAt;
  @override
  DateTime get createdAt;

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CallLogImplCopyWith<_$CallLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
