// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CallAnalytics _$CallAnalyticsFromJson(Map<String, dynamic> json) {
  return _CallAnalytics.fromJson(json);
}

/// @nodoc
mixin _$CallAnalytics {
  int get totalCalls => throw _privateConstructorUsedError;
  int get inboundCalls => throw _privateConstructorUsedError;
  int get outboundCalls => throw _privateConstructorUsedError;
  int get completedCalls => throw _privateConstructorUsedError;
  int get missedCalls => throw _privateConstructorUsedError;
  int get totalDurationSeconds => throw _privateConstructorUsedError;
  double get avgDurationSeconds => throw _privateConstructorUsedError;
  double get answerRate => throw _privateConstructorUsedError;
  Map<String, int> get sentimentBreakdown => throw _privateConstructorUsedError;
  Map<String, int> get outcomeBreakdown => throw _privateConstructorUsedError;

  /// Serializes this CallAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CallAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CallAnalyticsCopyWith<CallAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CallAnalyticsCopyWith<$Res> {
  factory $CallAnalyticsCopyWith(
    CallAnalytics value,
    $Res Function(CallAnalytics) then,
  ) = _$CallAnalyticsCopyWithImpl<$Res, CallAnalytics>;
  @useResult
  $Res call({
    int totalCalls,
    int inboundCalls,
    int outboundCalls,
    int completedCalls,
    int missedCalls,
    int totalDurationSeconds,
    double avgDurationSeconds,
    double answerRate,
    Map<String, int> sentimentBreakdown,
    Map<String, int> outcomeBreakdown,
  });
}

/// @nodoc
class _$CallAnalyticsCopyWithImpl<$Res, $Val extends CallAnalytics>
    implements $CallAnalyticsCopyWith<$Res> {
  _$CallAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CallAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCalls = null,
    Object? inboundCalls = null,
    Object? outboundCalls = null,
    Object? completedCalls = null,
    Object? missedCalls = null,
    Object? totalDurationSeconds = null,
    Object? avgDurationSeconds = null,
    Object? answerRate = null,
    Object? sentimentBreakdown = null,
    Object? outcomeBreakdown = null,
  }) {
    return _then(
      _value.copyWith(
            totalCalls: null == totalCalls
                ? _value.totalCalls
                : totalCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            inboundCalls: null == inboundCalls
                ? _value.inboundCalls
                : inboundCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            outboundCalls: null == outboundCalls
                ? _value.outboundCalls
                : outboundCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            completedCalls: null == completedCalls
                ? _value.completedCalls
                : completedCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            missedCalls: null == missedCalls
                ? _value.missedCalls
                : missedCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDurationSeconds: null == totalDurationSeconds
                ? _value.totalDurationSeconds
                : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            avgDurationSeconds: null == avgDurationSeconds
                ? _value.avgDurationSeconds
                : avgDurationSeconds // ignore: cast_nullable_to_non_nullable
                      as double,
            answerRate: null == answerRate
                ? _value.answerRate
                : answerRate // ignore: cast_nullable_to_non_nullable
                      as double,
            sentimentBreakdown: null == sentimentBreakdown
                ? _value.sentimentBreakdown
                : sentimentBreakdown // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            outcomeBreakdown: null == outcomeBreakdown
                ? _value.outcomeBreakdown
                : outcomeBreakdown // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CallAnalyticsImplCopyWith<$Res>
    implements $CallAnalyticsCopyWith<$Res> {
  factory _$$CallAnalyticsImplCopyWith(
    _$CallAnalyticsImpl value,
    $Res Function(_$CallAnalyticsImpl) then,
  ) = __$$CallAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalCalls,
    int inboundCalls,
    int outboundCalls,
    int completedCalls,
    int missedCalls,
    int totalDurationSeconds,
    double avgDurationSeconds,
    double answerRate,
    Map<String, int> sentimentBreakdown,
    Map<String, int> outcomeBreakdown,
  });
}

/// @nodoc
class __$$CallAnalyticsImplCopyWithImpl<$Res>
    extends _$CallAnalyticsCopyWithImpl<$Res, _$CallAnalyticsImpl>
    implements _$$CallAnalyticsImplCopyWith<$Res> {
  __$$CallAnalyticsImplCopyWithImpl(
    _$CallAnalyticsImpl _value,
    $Res Function(_$CallAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CallAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCalls = null,
    Object? inboundCalls = null,
    Object? outboundCalls = null,
    Object? completedCalls = null,
    Object? missedCalls = null,
    Object? totalDurationSeconds = null,
    Object? avgDurationSeconds = null,
    Object? answerRate = null,
    Object? sentimentBreakdown = null,
    Object? outcomeBreakdown = null,
  }) {
    return _then(
      _$CallAnalyticsImpl(
        totalCalls: null == totalCalls
            ? _value.totalCalls
            : totalCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        inboundCalls: null == inboundCalls
            ? _value.inboundCalls
            : inboundCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        outboundCalls: null == outboundCalls
            ? _value.outboundCalls
            : outboundCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        completedCalls: null == completedCalls
            ? _value.completedCalls
            : completedCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        missedCalls: null == missedCalls
            ? _value.missedCalls
            : missedCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDurationSeconds: null == totalDurationSeconds
            ? _value.totalDurationSeconds
            : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        avgDurationSeconds: null == avgDurationSeconds
            ? _value.avgDurationSeconds
            : avgDurationSeconds // ignore: cast_nullable_to_non_nullable
                  as double,
        answerRate: null == answerRate
            ? _value.answerRate
            : answerRate // ignore: cast_nullable_to_non_nullable
                  as double,
        sentimentBreakdown: null == sentimentBreakdown
            ? _value._sentimentBreakdown
            : sentimentBreakdown // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        outcomeBreakdown: null == outcomeBreakdown
            ? _value._outcomeBreakdown
            : outcomeBreakdown // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CallAnalyticsImpl implements _CallAnalytics {
  const _$CallAnalyticsImpl({
    this.totalCalls = 0,
    this.inboundCalls = 0,
    this.outboundCalls = 0,
    this.completedCalls = 0,
    this.missedCalls = 0,
    this.totalDurationSeconds = 0,
    this.avgDurationSeconds = 0.0,
    this.answerRate = 0.0,
    final Map<String, int> sentimentBreakdown = const {},
    final Map<String, int> outcomeBreakdown = const {},
  }) : _sentimentBreakdown = sentimentBreakdown,
       _outcomeBreakdown = outcomeBreakdown;

  factory _$CallAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CallAnalyticsImplFromJson(json);

  @override
  @JsonKey()
  final int totalCalls;
  @override
  @JsonKey()
  final int inboundCalls;
  @override
  @JsonKey()
  final int outboundCalls;
  @override
  @JsonKey()
  final int completedCalls;
  @override
  @JsonKey()
  final int missedCalls;
  @override
  @JsonKey()
  final int totalDurationSeconds;
  @override
  @JsonKey()
  final double avgDurationSeconds;
  @override
  @JsonKey()
  final double answerRate;
  final Map<String, int> _sentimentBreakdown;
  @override
  @JsonKey()
  Map<String, int> get sentimentBreakdown {
    if (_sentimentBreakdown is EqualUnmodifiableMapView)
      return _sentimentBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sentimentBreakdown);
  }

  final Map<String, int> _outcomeBreakdown;
  @override
  @JsonKey()
  Map<String, int> get outcomeBreakdown {
    if (_outcomeBreakdown is EqualUnmodifiableMapView) return _outcomeBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_outcomeBreakdown);
  }

  @override
  String toString() {
    return 'CallAnalytics(totalCalls: $totalCalls, inboundCalls: $inboundCalls, outboundCalls: $outboundCalls, completedCalls: $completedCalls, missedCalls: $missedCalls, totalDurationSeconds: $totalDurationSeconds, avgDurationSeconds: $avgDurationSeconds, answerRate: $answerRate, sentimentBreakdown: $sentimentBreakdown, outcomeBreakdown: $outcomeBreakdown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CallAnalyticsImpl &&
            (identical(other.totalCalls, totalCalls) ||
                other.totalCalls == totalCalls) &&
            (identical(other.inboundCalls, inboundCalls) ||
                other.inboundCalls == inboundCalls) &&
            (identical(other.outboundCalls, outboundCalls) ||
                other.outboundCalls == outboundCalls) &&
            (identical(other.completedCalls, completedCalls) ||
                other.completedCalls == completedCalls) &&
            (identical(other.missedCalls, missedCalls) ||
                other.missedCalls == missedCalls) &&
            (identical(other.totalDurationSeconds, totalDurationSeconds) ||
                other.totalDurationSeconds == totalDurationSeconds) &&
            (identical(other.avgDurationSeconds, avgDurationSeconds) ||
                other.avgDurationSeconds == avgDurationSeconds) &&
            (identical(other.answerRate, answerRate) ||
                other.answerRate == answerRate) &&
            const DeepCollectionEquality().equals(
              other._sentimentBreakdown,
              _sentimentBreakdown,
            ) &&
            const DeepCollectionEquality().equals(
              other._outcomeBreakdown,
              _outcomeBreakdown,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalCalls,
    inboundCalls,
    outboundCalls,
    completedCalls,
    missedCalls,
    totalDurationSeconds,
    avgDurationSeconds,
    answerRate,
    const DeepCollectionEquality().hash(_sentimentBreakdown),
    const DeepCollectionEquality().hash(_outcomeBreakdown),
  );

  /// Create a copy of CallAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CallAnalyticsImplCopyWith<_$CallAnalyticsImpl> get copyWith =>
      __$$CallAnalyticsImplCopyWithImpl<_$CallAnalyticsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CallAnalyticsImplToJson(this);
  }
}

abstract class _CallAnalytics implements CallAnalytics {
  const factory _CallAnalytics({
    final int totalCalls,
    final int inboundCalls,
    final int outboundCalls,
    final int completedCalls,
    final int missedCalls,
    final int totalDurationSeconds,
    final double avgDurationSeconds,
    final double answerRate,
    final Map<String, int> sentimentBreakdown,
    final Map<String, int> outcomeBreakdown,
  }) = _$CallAnalyticsImpl;

  factory _CallAnalytics.fromJson(Map<String, dynamic> json) =
      _$CallAnalyticsImpl.fromJson;

  @override
  int get totalCalls;
  @override
  int get inboundCalls;
  @override
  int get outboundCalls;
  @override
  int get completedCalls;
  @override
  int get missedCalls;
  @override
  int get totalDurationSeconds;
  @override
  double get avgDurationSeconds;
  @override
  double get answerRate;
  @override
  Map<String, int> get sentimentBreakdown;
  @override
  Map<String, int> get outcomeBreakdown;

  /// Create a copy of CallAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CallAnalyticsImplCopyWith<_$CallAnalyticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
