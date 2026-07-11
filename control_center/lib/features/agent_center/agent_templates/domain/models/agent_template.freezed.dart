// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AgentTemplate _$AgentTemplateFromJson(Map<String, dynamic> json) {
  return _AgentTemplate.fromJson(json);
}

/// @nodoc
mixin _$AgentTemplate {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  AgentPlatform get platform => throw _privateConstructorUsedError;
  String get systemPrompt => throw _privateConstructorUsedError;
  String get llmModel => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  Map<String, dynamic>? get platformConfig =>
      throw _privateConstructorUsedError;
  bool get isSystemTemplate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AgentTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgentTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgentTemplateCopyWith<AgentTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentTemplateCopyWith<$Res> {
  factory $AgentTemplateCopyWith(
    AgentTemplate value,
    $Res Function(AgentTemplate) then,
  ) = _$AgentTemplateCopyWithImpl<$Res, AgentTemplate>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    AgentPlatform platform,
    String systemPrompt,
    String llmModel,
    double temperature,
    Map<String, dynamic>? platformConfig,
    bool isSystemTemplate,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AgentTemplateCopyWithImpl<$Res, $Val extends AgentTemplate>
    implements $AgentTemplateCopyWith<$Res> {
  _$AgentTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgentTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? platform = null,
    Object? systemPrompt = null,
    Object? llmModel = null,
    Object? temperature = null,
    Object? platformConfig = freezed,
    Object? isSystemTemplate = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            platformConfig: freezed == platformConfig
                ? _value.platformConfig
                : platformConfig // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            isSystemTemplate: null == isSystemTemplate
                ? _value.isSystemTemplate
                : isSystemTemplate // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AgentTemplateImplCopyWith<$Res>
    implements $AgentTemplateCopyWith<$Res> {
  factory _$$AgentTemplateImplCopyWith(
    _$AgentTemplateImpl value,
    $Res Function(_$AgentTemplateImpl) then,
  ) = __$$AgentTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    AgentPlatform platform,
    String systemPrompt,
    String llmModel,
    double temperature,
    Map<String, dynamic>? platformConfig,
    bool isSystemTemplate,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AgentTemplateImplCopyWithImpl<$Res>
    extends _$AgentTemplateCopyWithImpl<$Res, _$AgentTemplateImpl>
    implements _$$AgentTemplateImplCopyWith<$Res> {
  __$$AgentTemplateImplCopyWithImpl(
    _$AgentTemplateImpl _value,
    $Res Function(_$AgentTemplateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgentTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? platform = null,
    Object? systemPrompt = null,
    Object? llmModel = null,
    Object? temperature = null,
    Object? platformConfig = freezed,
    Object? isSystemTemplate = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$AgentTemplateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        platformConfig: freezed == platformConfig
            ? _value._platformConfig
            : platformConfig // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        isSystemTemplate: null == isSystemTemplate
            ? _value.isSystemTemplate
            : isSystemTemplate // ignore: cast_nullable_to_non_nullable
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
class _$AgentTemplateImpl implements _AgentTemplate {
  const _$AgentTemplateImpl({
    required this.id,
    required this.name,
    this.description,
    required this.platform,
    required this.systemPrompt,
    this.llmModel = 'llama3',
    this.temperature = 0.7,
    final Map<String, dynamic>? platformConfig,
    this.isSystemTemplate = false,
    required this.createdAt,
  }) : _platformConfig = platformConfig;

  factory _$AgentTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
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
  final Map<String, dynamic>? _platformConfig;
  @override
  Map<String, dynamic>? get platformConfig {
    final value = _platformConfig;
    if (value == null) return null;
    if (_platformConfig is EqualUnmodifiableMapView) return _platformConfig;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isSystemTemplate;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AgentTemplate(id: $id, name: $name, description: $description, platform: $platform, systemPrompt: $systemPrompt, llmModel: $llmModel, temperature: $temperature, platformConfig: $platformConfig, isSystemTemplate: $isSystemTemplate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.systemPrompt, systemPrompt) ||
                other.systemPrompt == systemPrompt) &&
            (identical(other.llmModel, llmModel) ||
                other.llmModel == llmModel) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            const DeepCollectionEquality().equals(
              other._platformConfig,
              _platformConfig,
            ) &&
            (identical(other.isSystemTemplate, isSystemTemplate) ||
                other.isSystemTemplate == isSystemTemplate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    platform,
    systemPrompt,
    llmModel,
    temperature,
    const DeepCollectionEquality().hash(_platformConfig),
    isSystemTemplate,
    createdAt,
  );

  /// Create a copy of AgentTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentTemplateImplCopyWith<_$AgentTemplateImpl> get copyWith =>
      __$$AgentTemplateImplCopyWithImpl<_$AgentTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentTemplateImplToJson(this);
  }
}

abstract class _AgentTemplate implements AgentTemplate {
  const factory _AgentTemplate({
    required final String id,
    required final String name,
    final String? description,
    required final AgentPlatform platform,
    required final String systemPrompt,
    final String llmModel,
    final double temperature,
    final Map<String, dynamic>? platformConfig,
    final bool isSystemTemplate,
    required final DateTime createdAt,
  }) = _$AgentTemplateImpl;

  factory _AgentTemplate.fromJson(Map<String, dynamic> json) =
      _$AgentTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  AgentPlatform get platform;
  @override
  String get systemPrompt;
  @override
  String get llmModel;
  @override
  double get temperature;
  @override
  Map<String, dynamic>? get platformConfig;
  @override
  bool get isSystemTemplate;
  @override
  DateTime get createdAt;

  /// Create a copy of AgentTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgentTemplateImplCopyWith<_$AgentTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
