// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Agent _$AgentFromJson(Map<String, dynamic> json) {
  return _Agent.fromJson(json);
}

/// @nodoc
mixin _$Agent {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  AgentPlatform get platform => throw _privateConstructorUsedError;
  String get systemPrompt => throw _privateConstructorUsedError;
  String get llmModel => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  AgentStatus get status => throw _privateConstructorUsedError;
  List<String>? get knowledgeBaseIds => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Agent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Agent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgentCopyWith<Agent> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentCopyWith<$Res> {
  factory $AgentCopyWith(Agent value, $Res Function(Agent) then) =
      _$AgentCopyWithImpl<$Res, Agent>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    AgentPlatform platform,
    String systemPrompt,
    String llmModel,
    double temperature,
    AgentStatus status,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$AgentCopyWithImpl<$Res, $Val extends Agent>
    implements $AgentCopyWith<$Res> {
  _$AgentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Agent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? platform = null,
    Object? systemPrompt = null,
    Object? llmModel = null,
    Object? temperature = null,
    Object? status = null,
    Object? knowledgeBaseIds = freezed,
    Object? lastActiveAt = freezed,
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
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as AgentPlatform,
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
            knowledgeBaseIds: freezed == knowledgeBaseIds
                ? _value.knowledgeBaseIds
                : knowledgeBaseIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            lastActiveAt: freezed == lastActiveAt
                ? _value.lastActiveAt
                : lastActiveAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AgentImplCopyWith<$Res> implements $AgentCopyWith<$Res> {
  factory _$$AgentImplCopyWith(
    _$AgentImpl value,
    $Res Function(_$AgentImpl) then,
  ) = __$$AgentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    AgentPlatform platform,
    String systemPrompt,
    String llmModel,
    double temperature,
    AgentStatus status,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$AgentImplCopyWithImpl<$Res>
    extends _$AgentCopyWithImpl<$Res, _$AgentImpl>
    implements _$$AgentImplCopyWith<$Res> {
  __$$AgentImplCopyWithImpl(
    _$AgentImpl _value,
    $Res Function(_$AgentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Agent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? platform = null,
    Object? systemPrompt = null,
    Object? llmModel = null,
    Object? temperature = null,
    Object? status = null,
    Object? knowledgeBaseIds = freezed,
    Object? lastActiveAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$AgentImpl(
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
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as AgentPlatform,
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
        knowledgeBaseIds: freezed == knowledgeBaseIds
            ? _value._knowledgeBaseIds
            : knowledgeBaseIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        lastActiveAt: freezed == lastActiveAt
            ? _value.lastActiveAt
            : lastActiveAt // ignore: cast_nullable_to_non_nullable
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
class _$AgentImpl implements _Agent {
  const _$AgentImpl({
    required this.id,
    required this.orgId,
    required this.name,
    required this.platform,
    required this.systemPrompt,
    this.llmModel = 'llama3',
    this.temperature = 0.7,
    required this.status,
    final List<String>? knowledgeBaseIds,
    this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  }) : _knowledgeBaseIds = knowledgeBaseIds;

  factory _$AgentImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String name;
  @override
  final AgentPlatform platform;
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
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Agent(id: $id, orgId: $orgId, name: $name, platform: $platform, systemPrompt: $systemPrompt, llmModel: $llmModel, temperature: $temperature, status: $status, knowledgeBaseIds: $knowledgeBaseIds, lastActiveAt: $lastActiveAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.systemPrompt, systemPrompt) ||
                other.systemPrompt == systemPrompt) &&
            (identical(other.llmModel, llmModel) ||
                other.llmModel == llmModel) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._knowledgeBaseIds,
              _knowledgeBaseIds,
            ) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
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
    platform,
    systemPrompt,
    llmModel,
    temperature,
    status,
    const DeepCollectionEquality().hash(_knowledgeBaseIds),
    lastActiveAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Agent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentImplCopyWith<_$AgentImpl> get copyWith =>
      __$$AgentImplCopyWithImpl<_$AgentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentImplToJson(this);
  }
}

abstract class _Agent implements Agent {
  const factory _Agent({
    required final String id,
    required final String orgId,
    required final String name,
    required final AgentPlatform platform,
    required final String systemPrompt,
    final String llmModel,
    final double temperature,
    required final AgentStatus status,
    final List<String>? knowledgeBaseIds,
    final DateTime? lastActiveAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$AgentImpl;

  factory _Agent.fromJson(Map<String, dynamic> json) = _$AgentImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get name;
  @override
  AgentPlatform get platform;
  @override
  String get systemPrompt;
  @override
  String get llmModel;
  @override
  double get temperature;
  @override
  AgentStatus get status;
  @override
  List<String>? get knowledgeBaseIds;
  @override
  DateTime? get lastActiveAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Agent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgentImplCopyWith<_$AgentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
