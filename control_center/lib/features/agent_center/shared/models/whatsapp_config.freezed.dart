// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'whatsapp_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WhatsAppConfig _$WhatsAppConfigFromJson(Map<String, dynamic> json) {
  return _WhatsAppConfig.fromJson(json);
}

/// @nodoc
mixin _$WhatsAppConfig {
  String? get phoneNumberId => throw _privateConstructorUsedError;
  String? get businessAccountId => throw _privateConstructorUsedError;
  String? get accessToken => throw _privateConstructorUsedError;
  bool get autoReply => throw _privateConstructorUsedError;
  bool get leadExtraction => throw _privateConstructorUsedError;
  Map<String, String>? get quickReplies => throw _privateConstructorUsedError;

  /// Serializes this WhatsAppConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WhatsAppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WhatsAppConfigCopyWith<WhatsAppConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WhatsAppConfigCopyWith<$Res> {
  factory $WhatsAppConfigCopyWith(
    WhatsAppConfig value,
    $Res Function(WhatsAppConfig) then,
  ) = _$WhatsAppConfigCopyWithImpl<$Res, WhatsAppConfig>;
  @useResult
  $Res call({
    String? phoneNumberId,
    String? businessAccountId,
    String? accessToken,
    bool autoReply,
    bool leadExtraction,
    Map<String, String>? quickReplies,
  });
}

/// @nodoc
class _$WhatsAppConfigCopyWithImpl<$Res, $Val extends WhatsAppConfig>
    implements $WhatsAppConfigCopyWith<$Res> {
  _$WhatsAppConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WhatsAppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneNumberId = freezed,
    Object? businessAccountId = freezed,
    Object? accessToken = freezed,
    Object? autoReply = null,
    Object? leadExtraction = null,
    Object? quickReplies = freezed,
  }) {
    return _then(
      _value.copyWith(
            phoneNumberId: freezed == phoneNumberId
                ? _value.phoneNumberId
                : phoneNumberId // ignore: cast_nullable_to_non_nullable
                      as String?,
            businessAccountId: freezed == businessAccountId
                ? _value.businessAccountId
                : businessAccountId // ignore: cast_nullable_to_non_nullable
                      as String?,
            accessToken: freezed == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            autoReply: null == autoReply
                ? _value.autoReply
                : autoReply // ignore: cast_nullable_to_non_nullable
                      as bool,
            leadExtraction: null == leadExtraction
                ? _value.leadExtraction
                : leadExtraction // ignore: cast_nullable_to_non_nullable
                      as bool,
            quickReplies: freezed == quickReplies
                ? _value.quickReplies
                : quickReplies // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WhatsAppConfigImplCopyWith<$Res>
    implements $WhatsAppConfigCopyWith<$Res> {
  factory _$$WhatsAppConfigImplCopyWith(
    _$WhatsAppConfigImpl value,
    $Res Function(_$WhatsAppConfigImpl) then,
  ) = __$$WhatsAppConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? phoneNumberId,
    String? businessAccountId,
    String? accessToken,
    bool autoReply,
    bool leadExtraction,
    Map<String, String>? quickReplies,
  });
}

/// @nodoc
class __$$WhatsAppConfigImplCopyWithImpl<$Res>
    extends _$WhatsAppConfigCopyWithImpl<$Res, _$WhatsAppConfigImpl>
    implements _$$WhatsAppConfigImplCopyWith<$Res> {
  __$$WhatsAppConfigImplCopyWithImpl(
    _$WhatsAppConfigImpl _value,
    $Res Function(_$WhatsAppConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WhatsAppConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneNumberId = freezed,
    Object? businessAccountId = freezed,
    Object? accessToken = freezed,
    Object? autoReply = null,
    Object? leadExtraction = null,
    Object? quickReplies = freezed,
  }) {
    return _then(
      _$WhatsAppConfigImpl(
        phoneNumberId: freezed == phoneNumberId
            ? _value.phoneNumberId
            : phoneNumberId // ignore: cast_nullable_to_non_nullable
                  as String?,
        businessAccountId: freezed == businessAccountId
            ? _value.businessAccountId
            : businessAccountId // ignore: cast_nullable_to_non_nullable
                  as String?,
        accessToken: freezed == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        autoReply: null == autoReply
            ? _value.autoReply
            : autoReply // ignore: cast_nullable_to_non_nullable
                  as bool,
        leadExtraction: null == leadExtraction
            ? _value.leadExtraction
            : leadExtraction // ignore: cast_nullable_to_non_nullable
                  as bool,
        quickReplies: freezed == quickReplies
            ? _value._quickReplies
            : quickReplies // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WhatsAppConfigImpl implements _WhatsAppConfig {
  const _$WhatsAppConfigImpl({
    this.phoneNumberId,
    this.businessAccountId,
    this.accessToken,
    this.autoReply = true,
    this.leadExtraction = true,
    final Map<String, String>? quickReplies,
  }) : _quickReplies = quickReplies;

  factory _$WhatsAppConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$WhatsAppConfigImplFromJson(json);

  @override
  final String? phoneNumberId;
  @override
  final String? businessAccountId;
  @override
  final String? accessToken;
  @override
  @JsonKey()
  final bool autoReply;
  @override
  @JsonKey()
  final bool leadExtraction;
  final Map<String, String>? _quickReplies;
  @override
  Map<String, String>? get quickReplies {
    final value = _quickReplies;
    if (value == null) return null;
    if (_quickReplies is EqualUnmodifiableMapView) return _quickReplies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'WhatsAppConfig(phoneNumberId: $phoneNumberId, businessAccountId: $businessAccountId, accessToken: $accessToken, autoReply: $autoReply, leadExtraction: $leadExtraction, quickReplies: $quickReplies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WhatsAppConfigImpl &&
            (identical(other.phoneNumberId, phoneNumberId) ||
                other.phoneNumberId == phoneNumberId) &&
            (identical(other.businessAccountId, businessAccountId) ||
                other.businessAccountId == businessAccountId) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.autoReply, autoReply) ||
                other.autoReply == autoReply) &&
            (identical(other.leadExtraction, leadExtraction) ||
                other.leadExtraction == leadExtraction) &&
            const DeepCollectionEquality().equals(
              other._quickReplies,
              _quickReplies,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    phoneNumberId,
    businessAccountId,
    accessToken,
    autoReply,
    leadExtraction,
    const DeepCollectionEquality().hash(_quickReplies),
  );

  /// Create a copy of WhatsAppConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WhatsAppConfigImplCopyWith<_$WhatsAppConfigImpl> get copyWith =>
      __$$WhatsAppConfigImplCopyWithImpl<_$WhatsAppConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WhatsAppConfigImplToJson(this);
  }
}

abstract class _WhatsAppConfig implements WhatsAppConfig {
  const factory _WhatsAppConfig({
    final String? phoneNumberId,
    final String? businessAccountId,
    final String? accessToken,
    final bool autoReply,
    final bool leadExtraction,
    final Map<String, String>? quickReplies,
  }) = _$WhatsAppConfigImpl;

  factory _WhatsAppConfig.fromJson(Map<String, dynamic> json) =
      _$WhatsAppConfigImpl.fromJson;

  @override
  String? get phoneNumberId;
  @override
  String? get businessAccountId;
  @override
  String? get accessToken;
  @override
  bool get autoReply;
  @override
  bool get leadExtraction;
  @override
  Map<String, String>? get quickReplies;

  /// Create a copy of WhatsAppConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WhatsAppConfigImplCopyWith<_$WhatsAppConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
