// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AgentSettings _$AgentSettingsFromJson(Map<String, dynamic> json) {
  return _AgentSettings.fromJson(json);
}

/// @nodoc
mixin _$AgentSettings {
  String get agentId => throw _privateConstructorUsedError;
  String get agentName => throw _privateConstructorUsedError;
  String get selectedModel => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  int get maxTokens => throw _privateConstructorUsedError;
  bool get streamingEnabled => throw _privateConstructorUsedError;
  int get timeoutSeconds => throw _privateConstructorUsedError;
  List<String>? get assignedKnowledgeBaseIds =>
      throw _privateConstructorUsedError;
  String get systemPrompt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customParameters =>
      throw _privateConstructorUsedError;

  /// Serializes this AgentSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AgentSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AgentSettingsCopyWith<AgentSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentSettingsCopyWith<$Res> {
  factory $AgentSettingsCopyWith(
    AgentSettings value,
    $Res Function(AgentSettings) then,
  ) = _$AgentSettingsCopyWithImpl<$Res, AgentSettings>;
  @useResult
  $Res call({
    String agentId,
    String agentName,
    String selectedModel,
    double temperature,
    int maxTokens,
    bool streamingEnabled,
    int timeoutSeconds,
    List<String>? assignedKnowledgeBaseIds,
    String systemPrompt,
    Map<String, dynamic>? customParameters,
  });
}

/// @nodoc
class _$AgentSettingsCopyWithImpl<$Res, $Val extends AgentSettings>
    implements $AgentSettingsCopyWith<$Res> {
  _$AgentSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AgentSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agentId = null,
    Object? agentName = null,
    Object? selectedModel = null,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? streamingEnabled = null,
    Object? timeoutSeconds = null,
    Object? assignedKnowledgeBaseIds = freezed,
    Object? systemPrompt = null,
    Object? customParameters = freezed,
  }) {
    return _then(
      _value.copyWith(
            agentId: null == agentId
                ? _value.agentId
                : agentId // ignore: cast_nullable_to_non_nullable
                      as String,
            agentName: null == agentName
                ? _value.agentName
                : agentName // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedModel: null == selectedModel
                ? _value.selectedModel
                : selectedModel // ignore: cast_nullable_to_non_nullable
                      as String,
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            maxTokens: null == maxTokens
                ? _value.maxTokens
                : maxTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            streamingEnabled: null == streamingEnabled
                ? _value.streamingEnabled
                : streamingEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            timeoutSeconds: null == timeoutSeconds
                ? _value.timeoutSeconds
                : timeoutSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            assignedKnowledgeBaseIds: freezed == assignedKnowledgeBaseIds
                ? _value.assignedKnowledgeBaseIds
                : assignedKnowledgeBaseIds // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            systemPrompt: null == systemPrompt
                ? _value.systemPrompt
                : systemPrompt // ignore: cast_nullable_to_non_nullable
                      as String,
            customParameters: freezed == customParameters
                ? _value.customParameters
                : customParameters // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AgentSettingsImplCopyWith<$Res>
    implements $AgentSettingsCopyWith<$Res> {
  factory _$$AgentSettingsImplCopyWith(
    _$AgentSettingsImpl value,
    $Res Function(_$AgentSettingsImpl) then,
  ) = __$$AgentSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String agentId,
    String agentName,
    String selectedModel,
    double temperature,
    int maxTokens,
    bool streamingEnabled,
    int timeoutSeconds,
    List<String>? assignedKnowledgeBaseIds,
    String systemPrompt,
    Map<String, dynamic>? customParameters,
  });
}

/// @nodoc
class __$$AgentSettingsImplCopyWithImpl<$Res>
    extends _$AgentSettingsCopyWithImpl<$Res, _$AgentSettingsImpl>
    implements _$$AgentSettingsImplCopyWith<$Res> {
  __$$AgentSettingsImplCopyWithImpl(
    _$AgentSettingsImpl _value,
    $Res Function(_$AgentSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AgentSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? agentId = null,
    Object? agentName = null,
    Object? selectedModel = null,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? streamingEnabled = null,
    Object? timeoutSeconds = null,
    Object? assignedKnowledgeBaseIds = freezed,
    Object? systemPrompt = null,
    Object? customParameters = freezed,
  }) {
    return _then(
      _$AgentSettingsImpl(
        agentId: null == agentId
            ? _value.agentId
            : agentId // ignore: cast_nullable_to_non_nullable
                  as String,
        agentName: null == agentName
            ? _value.agentName
            : agentName // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedModel: null == selectedModel
            ? _value.selectedModel
            : selectedModel // ignore: cast_nullable_to_non_nullable
                  as String,
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        maxTokens: null == maxTokens
            ? _value.maxTokens
            : maxTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        streamingEnabled: null == streamingEnabled
            ? _value.streamingEnabled
            : streamingEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        timeoutSeconds: null == timeoutSeconds
            ? _value.timeoutSeconds
            : timeoutSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        assignedKnowledgeBaseIds: freezed == assignedKnowledgeBaseIds
            ? _value._assignedKnowledgeBaseIds
            : assignedKnowledgeBaseIds // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        systemPrompt: null == systemPrompt
            ? _value.systemPrompt
            : systemPrompt // ignore: cast_nullable_to_non_nullable
                  as String,
        customParameters: freezed == customParameters
            ? _value._customParameters
            : customParameters // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AgentSettingsImpl implements _AgentSettings {
  const _$AgentSettingsImpl({
    required this.agentId,
    required this.agentName,
    this.selectedModel = 'llama3',
    this.temperature = 0.7,
    this.maxTokens = 1024,
    this.streamingEnabled = true,
    this.timeoutSeconds = 30,
    final List<String>? assignedKnowledgeBaseIds,
    this.systemPrompt = 'You are a helpful assistant.',
    final Map<String, dynamic>? customParameters,
  }) : _assignedKnowledgeBaseIds = assignedKnowledgeBaseIds,
       _customParameters = customParameters;

  factory _$AgentSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentSettingsImplFromJson(json);

  @override
  final String agentId;
  @override
  final String agentName;
  @override
  @JsonKey()
  final String selectedModel;
  @override
  @JsonKey()
  final double temperature;
  @override
  @JsonKey()
  final int maxTokens;
  @override
  @JsonKey()
  final bool streamingEnabled;
  @override
  @JsonKey()
  final int timeoutSeconds;
  final List<String>? _assignedKnowledgeBaseIds;
  @override
  List<String>? get assignedKnowledgeBaseIds {
    final value = _assignedKnowledgeBaseIds;
    if (value == null) return null;
    if (_assignedKnowledgeBaseIds is EqualUnmodifiableListView)
      return _assignedKnowledgeBaseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final String systemPrompt;
  final Map<String, dynamic>? _customParameters;
  @override
  Map<String, dynamic>? get customParameters {
    final value = _customParameters;
    if (value == null) return null;
    if (_customParameters is EqualUnmodifiableMapView) return _customParameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AgentSettings(agentId: $agentId, agentName: $agentName, selectedModel: $selectedModel, temperature: $temperature, maxTokens: $maxTokens, streamingEnabled: $streamingEnabled, timeoutSeconds: $timeoutSeconds, assignedKnowledgeBaseIds: $assignedKnowledgeBaseIds, systemPrompt: $systemPrompt, customParameters: $customParameters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentSettingsImpl &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.agentName, agentName) ||
                other.agentName == agentName) &&
            (identical(other.selectedModel, selectedModel) ||
                other.selectedModel == selectedModel) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.streamingEnabled, streamingEnabled) ||
                other.streamingEnabled == streamingEnabled) &&
            (identical(other.timeoutSeconds, timeoutSeconds) ||
                other.timeoutSeconds == timeoutSeconds) &&
            const DeepCollectionEquality().equals(
              other._assignedKnowledgeBaseIds,
              _assignedKnowledgeBaseIds,
            ) &&
            (identical(other.systemPrompt, systemPrompt) ||
                other.systemPrompt == systemPrompt) &&
            const DeepCollectionEquality().equals(
              other._customParameters,
              _customParameters,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    agentId,
    agentName,
    selectedModel,
    temperature,
    maxTokens,
    streamingEnabled,
    timeoutSeconds,
    const DeepCollectionEquality().hash(_assignedKnowledgeBaseIds),
    systemPrompt,
    const DeepCollectionEquality().hash(_customParameters),
  );

  /// Create a copy of AgentSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentSettingsImplCopyWith<_$AgentSettingsImpl> get copyWith =>
      __$$AgentSettingsImplCopyWithImpl<_$AgentSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentSettingsImplToJson(this);
  }
}

abstract class _AgentSettings implements AgentSettings {
  const factory _AgentSettings({
    required final String agentId,
    required final String agentName,
    final String selectedModel,
    final double temperature,
    final int maxTokens,
    final bool streamingEnabled,
    final int timeoutSeconds,
    final List<String>? assignedKnowledgeBaseIds,
    final String systemPrompt,
    final Map<String, dynamic>? customParameters,
  }) = _$AgentSettingsImpl;

  factory _AgentSettings.fromJson(Map<String, dynamic> json) =
      _$AgentSettingsImpl.fromJson;

  @override
  String get agentId;
  @override
  String get agentName;
  @override
  String get selectedModel;
  @override
  double get temperature;
  @override
  int get maxTokens;
  @override
  bool get streamingEnabled;
  @override
  int get timeoutSeconds;
  @override
  List<String>? get assignedKnowledgeBaseIds;
  @override
  String get systemPrompt;
  @override
  Map<String, dynamic>? get customParameters;

  /// Create a copy of AgentSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AgentSettingsImplCopyWith<_$AgentSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
