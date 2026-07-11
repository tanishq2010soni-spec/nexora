// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VoiceConfig _$VoiceConfigFromJson(Map<String, dynamic> json) {
  return _VoiceConfig.fromJson(json);
}

/// @nodoc
mixin _$VoiceConfig {
  String get voiceId => throw _privateConstructorUsedError;
  String? get twilioAccountSid => throw _privateConstructorUsedError;
  String? get twilioAuthToken => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  int get sampleRate => throw _privateConstructorUsedError;
  bool get recordCalls => throw _privateConstructorUsedError;

  /// Serializes this VoiceConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceConfigCopyWith<VoiceConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceConfigCopyWith<$Res> {
  factory $VoiceConfigCopyWith(
    VoiceConfig value,
    $Res Function(VoiceConfig) then,
  ) = _$VoiceConfigCopyWithImpl<$Res, VoiceConfig>;
  @useResult
  $Res call({
    String voiceId,
    String? twilioAccountSid,
    String? twilioAuthToken,
    String? phoneNumber,
    int sampleRate,
    bool recordCalls,
  });
}

/// @nodoc
class _$VoiceConfigCopyWithImpl<$Res, $Val extends VoiceConfig>
    implements $VoiceConfigCopyWith<$Res> {
  _$VoiceConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? voiceId = null,
    Object? twilioAccountSid = freezed,
    Object? twilioAuthToken = freezed,
    Object? phoneNumber = freezed,
    Object? sampleRate = null,
    Object? recordCalls = null,
  }) {
    return _then(
      _value.copyWith(
            voiceId: null == voiceId
                ? _value.voiceId
                : voiceId // ignore: cast_nullable_to_non_nullable
                      as String,
            twilioAccountSid: freezed == twilioAccountSid
                ? _value.twilioAccountSid
                : twilioAccountSid // ignore: cast_nullable_to_non_nullable
                      as String?,
            twilioAuthToken: freezed == twilioAuthToken
                ? _value.twilioAuthToken
                : twilioAuthToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            sampleRate: null == sampleRate
                ? _value.sampleRate
                : sampleRate // ignore: cast_nullable_to_non_nullable
                      as int,
            recordCalls: null == recordCalls
                ? _value.recordCalls
                : recordCalls // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VoiceConfigImplCopyWith<$Res>
    implements $VoiceConfigCopyWith<$Res> {
  factory _$$VoiceConfigImplCopyWith(
    _$VoiceConfigImpl value,
    $Res Function(_$VoiceConfigImpl) then,
  ) = __$$VoiceConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String voiceId,
    String? twilioAccountSid,
    String? twilioAuthToken,
    String? phoneNumber,
    int sampleRate,
    bool recordCalls,
  });
}

/// @nodoc
class __$$VoiceConfigImplCopyWithImpl<$Res>
    extends _$VoiceConfigCopyWithImpl<$Res, _$VoiceConfigImpl>
    implements _$$VoiceConfigImplCopyWith<$Res> {
  __$$VoiceConfigImplCopyWithImpl(
    _$VoiceConfigImpl _value,
    $Res Function(_$VoiceConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VoiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? voiceId = null,
    Object? twilioAccountSid = freezed,
    Object? twilioAuthToken = freezed,
    Object? phoneNumber = freezed,
    Object? sampleRate = null,
    Object? recordCalls = null,
  }) {
    return _then(
      _$VoiceConfigImpl(
        voiceId: null == voiceId
            ? _value.voiceId
            : voiceId // ignore: cast_nullable_to_non_nullable
                  as String,
        twilioAccountSid: freezed == twilioAccountSid
            ? _value.twilioAccountSid
            : twilioAccountSid // ignore: cast_nullable_to_non_nullable
                  as String?,
        twilioAuthToken: freezed == twilioAuthToken
            ? _value.twilioAuthToken
            : twilioAuthToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        sampleRate: null == sampleRate
            ? _value.sampleRate
            : sampleRate // ignore: cast_nullable_to_non_nullable
                  as int,
        recordCalls: null == recordCalls
            ? _value.recordCalls
            : recordCalls // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceConfigImpl implements _VoiceConfig {
  const _$VoiceConfigImpl({
    this.voiceId = 'alloy',
    this.twilioAccountSid,
    this.twilioAuthToken,
    this.phoneNumber,
    this.sampleRate = 16000,
    this.recordCalls = true,
  });

  factory _$VoiceConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceConfigImplFromJson(json);

  @override
  @JsonKey()
  final String voiceId;
  @override
  final String? twilioAccountSid;
  @override
  final String? twilioAuthToken;
  @override
  final String? phoneNumber;
  @override
  @JsonKey()
  final int sampleRate;
  @override
  @JsonKey()
  final bool recordCalls;

  @override
  String toString() {
    return 'VoiceConfig(voiceId: $voiceId, twilioAccountSid: $twilioAccountSid, twilioAuthToken: $twilioAuthToken, phoneNumber: $phoneNumber, sampleRate: $sampleRate, recordCalls: $recordCalls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceConfigImpl &&
            (identical(other.voiceId, voiceId) || other.voiceId == voiceId) &&
            (identical(other.twilioAccountSid, twilioAccountSid) ||
                other.twilioAccountSid == twilioAccountSid) &&
            (identical(other.twilioAuthToken, twilioAuthToken) ||
                other.twilioAuthToken == twilioAuthToken) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.sampleRate, sampleRate) ||
                other.sampleRate == sampleRate) &&
            (identical(other.recordCalls, recordCalls) ||
                other.recordCalls == recordCalls));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    voiceId,
    twilioAccountSid,
    twilioAuthToken,
    phoneNumber,
    sampleRate,
    recordCalls,
  );

  /// Create a copy of VoiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceConfigImplCopyWith<_$VoiceConfigImpl> get copyWith =>
      __$$VoiceConfigImplCopyWithImpl<_$VoiceConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceConfigImplToJson(this);
  }
}

abstract class _VoiceConfig implements VoiceConfig {
  const factory _VoiceConfig({
    final String voiceId,
    final String? twilioAccountSid,
    final String? twilioAuthToken,
    final String? phoneNumber,
    final int sampleRate,
    final bool recordCalls,
  }) = _$VoiceConfigImpl;

  factory _VoiceConfig.fromJson(Map<String, dynamic> json) =
      _$VoiceConfigImpl.fromJson;

  @override
  String get voiceId;
  @override
  String? get twilioAccountSid;
  @override
  String? get twilioAuthToken;
  @override
  String? get phoneNumber;
  @override
  int get sampleRate;
  @override
  bool get recordCalls;

  /// Create a copy of VoiceConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceConfigImplCopyWith<_$VoiceConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
