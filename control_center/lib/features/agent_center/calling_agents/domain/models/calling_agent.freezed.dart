// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calling_agent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CallingAgent _$CallingAgentFromJson(Map<String, dynamic> json) {
  return _CallingAgent.fromJson(json);
}

/// @nodoc
mixin _$CallingAgent {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get systemPrompt => throw _privateConstructorUsedError;
  String get llmModel => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  AgentStatus get status => throw _privateConstructorUsedError;
  VoiceConfig get voiceConfig => throw _privateConstructorUsedError;
  List<String>? get knowledgeBaseIds => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;
  int get totalCalls => throw _privateConstructorUsedError;
  int get todayCalls => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CallingAgent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CallingAgent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CallingAgentCopyWith<CallingAgent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CallingAgentCopyWith<$Res> {
  factory $CallingAgentCopyWith(
    CallingAgent value,
    $Res Function(CallingAgent) then,
  ) = _$CallingAgentCopyWithImpl<$Res, CallingAgent>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String systemPrompt,
    String llmModel,
    double temperature,
    AgentStatus status,
    VoiceConfig voiceConfig,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    int totalCalls,
    int todayCalls,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $VoiceConfigCopyWith<$Res> get voiceConfig;
}

/// @nodoc
class _$CallingAgentCopyWithImpl<$Res, $Val extends CallingAgent>
    implements $CallingAgentCopyWith<$Res> {
  _$CallingAgentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CallingAgent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? systemPrompt = null,
    Object? llmModel = null,
    Object? temperature = null,
    Object? status = null,
    Object? voiceConfig = null,
    Object? knowledgeBaseIds = freezed,
    Object? lastActiveAt = freezed,
    Object? totalCalls = null,
    Object? todayCalls = null,
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            systemPrompt: null == systemPrompt
                ? _value.systemPrompt
                : systemPrompt // ignore: cast_nullable_to_non_nullable
                      as String,
            llmModel: null == llmModel
                ? _value.llmModel
                : llmModel // ignore: cast_nullable_to_non_nullable
                      as String,
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AgentStatus,
            voiceConfig: null == voiceConfig
                ? _value.voiceConfig
                : voiceConfig // ignore: cast_nullable_to_non_nullable
                      as VoiceConfig,
            knowledgeBaseIds: freezed == knowledgeBaseIds
                ? _value.knowledgeBaseIds
                : knowledgeBaseIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            lastActiveAt: freezed == lastActiveAt
                ? _value.lastActiveAt
                : lastActiveAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            totalCalls: null == totalCalls
                ? _value.totalCalls
                : totalCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            todayCalls: null == todayCalls
                ? _value.todayCalls
                : todayCalls // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of CallingAgent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VoiceConfigCopyWith<$Res> get voiceConfig {
    return $VoiceConfigCopyWith<$Res>(_value.voiceConfig, (value) {
      return _then(_value.copyWith(voiceConfig: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CallingAgentImplCopyWith<$Res>
    implements $CallingAgentCopyWith<$Res> {
  factory _$$CallingAgentImplCopyWith(
    _$CallingAgentImpl value,
    $Res Function(_$CallingAgentImpl) then,
  ) = __$$CallingAgentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String systemPrompt,
    String llmModel,
    double temperature,
    AgentStatus status,
    VoiceConfig voiceConfig,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    int totalCalls,
    int todayCalls,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $VoiceConfigCopyWith<$Res> get voiceConfig;
}

/// @nodoc
class __$$CallingAgentImplCopyWithImpl<$Res>
    extends _$CallingAgentCopyWithImpl<$Res, _$CallingAgentImpl>
    implements _$$CallingAgentImplCopyWith<$Res> {
  __$$CallingAgentImplCopyWithImpl(
    _$CallingAgentImpl _value,
    $Res Function(_$CallingAgentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CallingAgent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? systemPrompt = null,
    Object? llmModel = null,
    Object? temperature = null,
    Object? status = null,
    Object? voiceConfig = null,
    Object? knowledgeBaseIds = freezed,
    Object? lastActiveAt = freezed,
    Object? totalCalls = null,
    Object? todayCalls = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CallingAgentImpl(
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
        systemPrompt: null == systemPrompt
            ? _value.systemPrompt
            : systemPrompt // ignore: cast_nullable_to_non_nullable
                  as String,
        llmModel: null == llmModel
            ? _value.llmModel
            : llmModel // ignore: cast_nullable_to_non_nullable
                  as String,
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AgentStatus,
        voiceConfig: null == voiceConfig
            ? _value.voiceConfig
            : voiceConfig // ignore: cast_nullable_to_non_nullable
                  as VoiceConfig,
        knowledgeBaseIds: freezed == knowledgeBaseIds
            ? _value._knowledgeBaseIds
            : knowledgeBaseIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        lastActiveAt: freezed == lastActiveAt
            ? _value.lastActiveAt
            : lastActiveAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        totalCalls: null == totalCalls
            ? _value.totalCalls
            : totalCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        todayCalls: null == todayCalls
            ? _value.todayCalls
            : todayCalls // ignore: cast_nullable_to_non_nullable
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
class _$CallingAgentImpl implements _CallingAgent {
  const _$CallingAgentImpl({
    required this.id,
    required this.orgId,
    required this.name,
    required this.systemPrompt,
    this.llmModel = 'llama3',
    this.temperature = 0.7,
    required this.status,
    required this.voiceConfig,
    final List<String>? knowledgeBaseIds,
    this.lastActiveAt,
    this.totalCalls = 0,
    this.todayCalls = 0,
    required this.createdAt,
    required this.updatedAt,
  }) : _knowledgeBaseIds = knowledgeBaseIds;

  factory _$CallingAgentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CallingAgentImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String name;
  @override
  final String systemPrompt;
  @override
  @JsonKey()
  final String llmModel;
  @override
  @JsonKey()
  final double temperature;
  @override
  final AgentStatus status;
  @override
  final VoiceConfig voiceConfig;
  final List<String>? _knowledgeBaseIds;
  @override
  List<String>? get knowledgeBaseIds {
    final value = _knowledgeBaseIds;
    if (value == null) return null;
    if (_knowledgeBaseIds is EqualUnmodifiableListView)
      return _knowledgeBaseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? lastActiveAt;
  @override
  @JsonKey()
  final int totalCalls;
  @override
  @JsonKey()
  final int todayCalls;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CallingAgent(id: $id, orgId: $orgId, name: $name, systemPrompt: $systemPrompt, llmModel: $llmModel, temperature: $temperature, status: $status, voiceConfig: $voiceConfig, knowledgeBaseIds: $knowledgeBaseIds, lastActiveAt: $lastActiveAt, totalCalls: $totalCalls, todayCalls: $todayCalls, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CallingAgentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.systemPrompt, systemPrompt) ||
                other.systemPrompt == systemPrompt) &&
            (identical(other.llmModel, llmModel) ||
                other.llmModel == llmModel) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.voiceConfig, voiceConfig) ||
                other.voiceConfig == voiceConfig) &&
            const DeepCollectionEquality().equals(
              other._knowledgeBaseIds,
              _knowledgeBaseIds,
            ) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            (identical(other.totalCalls, totalCalls) ||
                other.totalCalls == totalCalls) &&
            (identical(other.todayCalls, todayCalls) ||
                other.todayCalls == todayCalls) &&
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
    name,
    systemPrompt,
    llmModel,
    temperature,
    status,
    voiceConfig,
    const DeepCollectionEquality().hash(_knowledgeBaseIds),
    lastActiveAt,
    totalCalls,
    todayCalls,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CallingAgent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CallingAgentImplCopyWith<_$CallingAgentImpl> get copyWith =>
      __$$CallingAgentImplCopyWithImpl<_$CallingAgentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CallingAgentImplToJson(this);
  }
}

abstract class _CallingAgent implements CallingAgent {
  const factory _CallingAgent({
    required final String id,
    required final String orgId,
    required final String name,
    required final String systemPrompt,
    final String llmModel,
    final double temperature,
    required final AgentStatus status,
    required final VoiceConfig voiceConfig,
    final List<String>? knowledgeBaseIds,
    final DateTime? lastActiveAt,
    final int totalCalls,
    final int todayCalls,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CallingAgentImpl;

  factory _CallingAgent.fromJson(Map<String, dynamic> json) =
      _$CallingAgentImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get name;
  @override
  String get systemPrompt;
  @override
  String get llmModel;
  @override
  double get temperature;
  @override
  AgentStatus get status;
  @override
  VoiceConfig get voiceConfig;
  @override
  List<String>? get knowledgeBaseIds;
  @override
  DateTime? get lastActiveAt;
  @override
  int get totalCalls;
  @override
  int get todayCalls;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CallingAgent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CallingAgentImplCopyWith<_$CallingAgentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
