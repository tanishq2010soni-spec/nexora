// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeadAnalytics _$LeadAnalyticsFromJson(Map<String, dynamic> json) {
  return _LeadAnalytics.fromJson(json);
}

/// @nodoc
mixin _$LeadAnalytics {
  int get totalLeads => throw _privateConstructorUsedError;
  int get qualifiedLeads => throw _privateConstructorUsedError;
  int get wonLeads => throw _privateConstructorUsedError;
  int get lostLeads => throw _privateConstructorUsedError;
  double get conversionRate => throw _privateConstructorUsedError;
  double get avgLeadScore => throw _privateConstructorUsedError;
  int get newLeadsToday => throw _privateConstructorUsedError;
  int get qualifiedToday => throw _privateConstructorUsedError;
  int get wonToday => throw _privateConstructorUsedError;
  Map<String, int>? get sourceBreakdown => throw _privateConstructorUsedError;
  Map<String, int>? get statusBreakdown => throw _privateConstructorUsedError;

  /// Serializes this LeadAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadAnalyticsCopyWith<LeadAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadAnalyticsCopyWith<$Res> {
  factory $LeadAnalyticsCopyWith(
    LeadAnalytics value,
    $Res Function(LeadAnalytics) then,
  ) = _$LeadAnalyticsCopyWithImpl<$Res, LeadAnalytics>;
  @useResult
  $Res call({
    int totalLeads,
    int qualifiedLeads,
    int wonLeads,
    int lostLeads,
    double conversionRate,
    double avgLeadScore,
    int newLeadsToday,
    int qualifiedToday,
    int wonToday,
    Map<String, int>? sourceBreakdown,
    Map<String, int>? statusBreakdown,
  });
}

/// @nodoc
class _$LeadAnalyticsCopyWithImpl<$Res, $Val extends LeadAnalytics>
    implements $LeadAnalyticsCopyWith<$Res> {
  _$LeadAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalLeads = null,
    Object? qualifiedLeads = null,
    Object? wonLeads = null,
    Object? lostLeads = null,
    Object? conversionRate = null,
    Object? avgLeadScore = null,
    Object? newLeadsToday = null,
    Object? qualifiedToday = null,
    Object? wonToday = null,
    Object? sourceBreakdown = freezed,
    Object? statusBreakdown = freezed,
  }) {
    return _then(
      _value.copyWith(
            totalLeads: null == totalLeads
                ? _value.totalLeads
                : totalLeads // ignore: cast_nullable_to_non_nullable
                      as int,
            qualifiedLeads: null == qualifiedLeads
                ? _value.qualifiedLeads
                : qualifiedLeads // ignore: cast_nullable_to_non_nullable
                      as int,
            wonLeads: null == wonLeads
                ? _value.wonLeads
                : wonLeads // ignore: cast_nullable_to_non_nullable
                      as int,
            lostLeads: null == lostLeads
                ? _value.lostLeads
                : lostLeads // ignore: cast_nullable_to_non_nullable
                      as int,
            conversionRate: null == conversionRate
                ? _value.conversionRate
                : conversionRate // ignore: cast_nullable_to_non_nullable
                      as double,
            avgLeadScore: null == avgLeadScore
                ? _value.avgLeadScore
                : avgLeadScore // ignore: cast_nullable_to_non_nullable
                      as double,
            newLeadsToday: null == newLeadsToday
                ? _value.newLeadsToday
                : newLeadsToday // ignore: cast_nullable_to_non_nullable
                      as int,
            qualifiedToday: null == qualifiedToday
                ? _value.qualifiedToday
                : qualifiedToday // ignore: cast_nullable_to_non_nullable
                      as int,
            wonToday: null == wonToday
                ? _value.wonToday
                : wonToday // ignore: cast_nullable_to_non_nullable
                      as int,
            sourceBreakdown: freezed == sourceBreakdown
                ? _value.sourceBreakdown
                : sourceBreakdown // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>?,
            statusBreakdown: freezed == statusBreakdown
                ? _value.statusBreakdown
                : statusBreakdown // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeadAnalyticsImplCopyWith<$Res>
    implements $LeadAnalyticsCopyWith<$Res> {
  factory _$$LeadAnalyticsImplCopyWith(
    _$LeadAnalyticsImpl value,
    $Res Function(_$LeadAnalyticsImpl) then,
  ) = __$$LeadAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalLeads,
    int qualifiedLeads,
    int wonLeads,
    int lostLeads,
    double conversionRate,
    double avgLeadScore,
    int newLeadsToday,
    int qualifiedToday,
    int wonToday,
    Map<String, int>? sourceBreakdown,
    Map<String, int>? statusBreakdown,
  });
}

/// @nodoc
class __$$LeadAnalyticsImplCopyWithImpl<$Res>
    extends _$LeadAnalyticsCopyWithImpl<$Res, _$LeadAnalyticsImpl>
    implements _$$LeadAnalyticsImplCopyWith<$Res> {
  __$$LeadAnalyticsImplCopyWithImpl(
    _$LeadAnalyticsImpl _value,
    $Res Function(_$LeadAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalLeads = null,
    Object? qualifiedLeads = null,
    Object? wonLeads = null,
    Object? lostLeads = null,
    Object? conversionRate = null,
    Object? avgLeadScore = null,
    Object? newLeadsToday = null,
    Object? qualifiedToday = null,
    Object? wonToday = null,
    Object? sourceBreakdown = freezed,
    Object? statusBreakdown = freezed,
  }) {
    return _then(
      _$LeadAnalyticsImpl(
        totalLeads: null == totalLeads
            ? _value.totalLeads
            : totalLeads // ignore: cast_nullable_to_non_nullable
                  as int,
        qualifiedLeads: null == qualifiedLeads
            ? _value.qualifiedLeads
            : qualifiedLeads // ignore: cast_nullable_to_non_nullable
                  as int,
        wonLeads: null == wonLeads
            ? _value.wonLeads
            : wonLeads // ignore: cast_nullable_to_non_nullable
                  as int,
        lostLeads: null == lostLeads
            ? _value.lostLeads
            : lostLeads // ignore: cast_nullable_to_non_nullable
                  as int,
        conversionRate: null == conversionRate
            ? _value.conversionRate
            : conversionRate // ignore: cast_nullable_to_non_nullable
                  as double,
        avgLeadScore: null == avgLeadScore
            ? _value.avgLeadScore
            : avgLeadScore // ignore: cast_nullable_to_non_nullable
                  as double,
        newLeadsToday: null == newLeadsToday
            ? _value.newLeadsToday
            : newLeadsToday // ignore: cast_nullable_to_non_nullable
                  as int,
        qualifiedToday: null == qualifiedToday
            ? _value.qualifiedToday
            : qualifiedToday // ignore: cast_nullable_to_non_nullable
                  as int,
        wonToday: null == wonToday
            ? _value.wonToday
            : wonToday // ignore: cast_nullable_to_non_nullable
                  as int,
        sourceBreakdown: freezed == sourceBreakdown
            ? _value._sourceBreakdown
            : sourceBreakdown // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>?,
        statusBreakdown: freezed == statusBreakdown
            ? _value._statusBreakdown
            : statusBreakdown // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeadAnalyticsImpl implements _LeadAnalytics {
  const _$LeadAnalyticsImpl({
    this.totalLeads = 0,
    this.qualifiedLeads = 0,
    this.wonLeads = 0,
    this.lostLeads = 0,
    this.conversionRate = 0.0,
    this.avgLeadScore = 0.0,
    this.newLeadsToday = 0,
    this.qualifiedToday = 0,
    this.wonToday = 0,
    final Map<String, int>? sourceBreakdown,
    final Map<String, int>? statusBreakdown,
  }) : _sourceBreakdown = sourceBreakdown,
       _statusBreakdown = statusBreakdown;

  factory _$LeadAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadAnalyticsImplFromJson(json);

  @override
  @JsonKey()
  final int totalLeads;
  @override
  @JsonKey()
  final int qualifiedLeads;
  @override
  @JsonKey()
  final int wonLeads;
  @override
  @JsonKey()
  final int lostLeads;
  @override
  @JsonKey()
  final double conversionRate;
  @override
  @JsonKey()
  final double avgLeadScore;
  @override
  @JsonKey()
  final int newLeadsToday;
  @override
  @JsonKey()
  final int qualifiedToday;
  @override
  @JsonKey()
  final int wonToday;
  final Map<String, int>? _sourceBreakdown;
  @override
  Map<String, int>? get sourceBreakdown {
    final value = _sourceBreakdown;
    if (value == null) return null;
    if (_sourceBreakdown is EqualUnmodifiableMapView) return _sourceBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, int>? _statusBreakdown;
  @override
  Map<String, int>? get statusBreakdown {
    final value = _statusBreakdown;
    if (value == null) return null;
    if (_statusBreakdown is EqualUnmodifiableMapView) return _statusBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'LeadAnalytics(totalLeads: $totalLeads, qualifiedLeads: $qualifiedLeads, wonLeads: $wonLeads, lostLeads: $lostLeads, conversionRate: $conversionRate, avgLeadScore: $avgLeadScore, newLeadsToday: $newLeadsToday, qualifiedToday: $qualifiedToday, wonToday: $wonToday, sourceBreakdown: $sourceBreakdown, statusBreakdown: $statusBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadAnalyticsImpl &&
            (identical(other.totalLeads, totalLeads) ||
                other.totalLeads == totalLeads) &&
            (identical(other.qualifiedLeads, qualifiedLeads) ||
                other.qualifiedLeads == qualifiedLeads) &&
            (identical(other.wonLeads, wonLeads) ||
                other.wonLeads == wonLeads) &&
            (identical(other.lostLeads, lostLeads) ||
                other.lostLeads == lostLeads) &&
            (identical(other.conversionRate, conversionRate) ||
                other.conversionRate == conversionRate) &&
            (identical(other.avgLeadScore, avgLeadScore) ||
                other.avgLeadScore == avgLeadScore) &&
            (identical(other.newLeadsToday, newLeadsToday) ||
                other.newLeadsToday == newLeadsToday) &&
            (identical(other.qualifiedToday, qualifiedToday) ||
                other.qualifiedToday == qualifiedToday) &&
            (identical(other.wonToday, wonToday) ||
                other.wonToday == wonToday) &&
            const DeepCollectionEquality().equals(
              other._sourceBreakdown,
              _sourceBreakdown,
            ) &&
            const DeepCollectionEquality().equals(
              other._statusBreakdown,
              _statusBreakdown,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalLeads,
    qualifiedLeads,
    wonLeads,
    lostLeads,
    conversionRate,
    avgLeadScore,
    newLeadsToday,
    qualifiedToday,
    wonToday,
    const DeepCollectionEquality().hash(_sourceBreakdown),
    const DeepCollectionEquality().hash(_statusBreakdown),
  );

  /// Create a copy of LeadAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadAnalyticsImplCopyWith<_$LeadAnalyticsImpl> get copyWith =>
      __$$LeadAnalyticsImplCopyWithImpl<_$LeadAnalyticsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadAnalyticsImplToJson(this);
  }
}

abstract class _LeadAnalytics implements LeadAnalytics {
  const factory _LeadAnalytics({
    final int totalLeads,
    final int qualifiedLeads,
    final int wonLeads,
    final int lostLeads,
    final double conversionRate,
    final double avgLeadScore,
    final int newLeadsToday,
    final int qualifiedToday,
    final int wonToday,
    final Map<String, int>? sourceBreakdown,
    final Map<String, int>? statusBreakdown,
  }) = _$LeadAnalyticsImpl;

  factory _LeadAnalytics.fromJson(Map<String, dynamic> json) =
      _$LeadAnalyticsImpl.fromJson;

  @override
  int get totalLeads;
  @override
  int get qualifiedLeads;
  @override
  int get wonLeads;
  @override
  int get lostLeads;
  @override
  double get conversionRate;
  @override
  double get avgLeadScore;
  @override
  int get newLeadsToday;
  @override
  int get qualifiedToday;
  @override
  int get wonToday;
  @override
  Map<String, int>? get sourceBreakdown;
  @override
  Map<String, int>? get statusBreakdown;

  /// Create a copy of LeadAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadAnalyticsImplCopyWith<_$LeadAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
