// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whatsapp_agent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WhatsAppAgent _$WhatsAppAgentFromJson(Map<String, dynamic> json) {
  return _WhatsAppAgent.fromJson(json);
}

/// @nodoc
mixin _$WhatsAppAgent {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get systemPrompt => throw _privateConstructorUsedError;
  String get llmModel => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  AgentStatus get status => throw _privateConstructorUsedError;
  WhatsAppConfig get config => throw _privateConstructorUsedError;
  List<String>? get knowledgeBaseIds => throw _privateConstructorUsedError;
  DateTime? get lastActiveAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WhatsAppAgent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WhatsAppAgent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WhatsAppAgentCopyWith<WhatsAppAgent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhatsAppAgentCopyWith<$Res> {
  factory $WhatsAppAgentCopyWith(
    WhatsAppAgent value,
    $Res Function(WhatsAppAgent) then,
  ) = _$WhatsAppAgentCopyWithImpl<$Res, WhatsAppAgent>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String systemPrompt,
    String llmModel,
    double temperature,
    AgentStatus status,
    WhatsAppConfig config,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $WhatsAppConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$WhatsAppAgentCopyWithImpl<$Res, $Val extends WhatsAppAgent>
    implements $WhatsAppAgentCopyWith<$Res> {
  _$WhatsAppAgentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WhatsAppAgent
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
    Object? config = null,
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
            config: null == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                      as WhatsAppConfig,
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

  /// Create a copy of WhatsAppAgent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WhatsAppConfigCopyWith<$Res> get config {
    return $WhatsAppConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WhatsAppAgentImplCopyWith<$Res>
    implements $WhatsAppAgentCopyWith<$Res> {
  factory _$$WhatsAppAgentImplCopyWith(
    _$WhatsAppAgentImpl value,
    $Res Function(_$WhatsAppAgentImpl) then,
  ) = __$$WhatsAppAgentImplCopyWithImpl<$Res>;
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
    WhatsAppConfig config,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $WhatsAppConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$WhatsAppAgentImplCopyWithImpl<$Res>
    extends _$WhatsAppAgentCopyWithImpl<$Res, _$WhatsAppAgentImpl>
    implements _$$WhatsAppAgentImplCopyWith<$Res> {
  __$$WhatsAppAgentImplCopyWithImpl(
    _$WhatsAppAgentImpl _value,
    $Res Function(_$WhatsAppAgentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WhatsAppAgent
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
    Object? config = null,
    Object? knowledgeBaseIds = freezed,
    Object? lastActiveAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$WhatsAppAgentImpl(
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
        config: null == config
            ? _value.config
            : config // ignore: cast_nullable_to_non_nullable
                  as WhatsAppConfig,
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
class _$WhatsAppAgentImpl implements _WhatsAppAgent {
  const _$WhatsAppAgentImpl({
    required this.id,
    required this.orgId,
    required this.name,
    required this.systemPrompt,
    this.llmModel = 'llama3',
    this.temperature = 0.7,
    required this.status,
    required this.config,
    final List<String>? knowledgeBaseIds,
    this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  }) : _knowledgeBaseIds = knowledgeBaseIds;

  factory _$WhatsAppAgentImpl.fromJson(Map<String, dynamic> json) =>
      _$$WhatsAppAgentImplFromJson(json);

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
  final WhatsAppConfig config;
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
    return 'WhatsAppAgent(id: $id, orgId: $orgId, name: $name, systemPrompt: $systemPrompt, llmModel: $llmModel, temperature: $temperature, status: $status, config: $config, knowledgeBaseIds: $knowledgeBaseIds, lastActiveAt: $lastActiveAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WhatsAppAgentImpl &&
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
            (identical(other.config, config) || other.config == config) &&
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
    systemPrompt,
    llmModel,
    temperature,
    status,
    config,
    const DeepCollectionEquality().hash(_knowledgeBaseIds),
    lastActiveAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of WhatsAppAgent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WhatsAppAgentImplCopyWith<_$WhatsAppAgentImpl> get copyWith =>
      __$$WhatsAppAgentImplCopyWithImpl<_$WhatsAppAgentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WhatsAppAgentImplToJson(this);
  }
}

abstract class _WhatsAppAgent implements WhatsAppAgent {
  const factory _WhatsAppAgent({
    required final String id,
    required final String orgId,
    required final String name,
    required final String systemPrompt,
    final String llmModel,
    final double temperature,
    required final AgentStatus status,
    required final WhatsAppConfig config,
    final List<String>? knowledgeBaseIds,
    final DateTime? lastActiveAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$WhatsAppAgentImpl;

  factory _WhatsAppAgent.fromJson(Map<String, dynamic> json) =
      _$WhatsAppAgentImpl.fromJson;

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
  WhatsAppConfig get config;
  @override
  List<String>? get knowledgeBaseIds;
  @override
  DateTime? get lastActiveAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of WhatsAppAgent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WhatsAppAgentImplCopyWith<_$WhatsAppAgentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
