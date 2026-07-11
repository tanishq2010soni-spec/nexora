// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  int get activeAgents => throw _privateConstructorUsedError;
  int get messagesToday => throw _privateConstructorUsedError;
  int get callsToday => throw _privateConstructorUsedError;
  int get leadsGenerated => throw _privateConstructorUsedError;
  int get customersManaged => throw _privateConstructorUsedError;
  String get systemHealth => throw _privateConstructorUsedError;

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
    DashboardStats value,
    $Res Function(DashboardStats) then,
  ) = _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call({
    int activeAgents,
    int messagesToday,
    int callsToday,
    int leadsGenerated,
    int customersManaged,
    String systemHealth,
  });
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeAgents = null,
    Object? messagesToday = null,
    Object? callsToday = null,
    Object? leadsGenerated = null,
    Object? customersManaged = null,
    Object? systemHealth = null,
  }) {
    return _then(
      _value.copyWith(
            activeAgents: null == activeAgents
                ? _value.activeAgents
                : activeAgents // ignore: cast_nullable_to_non_nullable
                      as int,
            messagesToday: null == messagesToday
                ? _value.messagesToday
                : messagesToday // ignore: cast_nullable_to_non_nullable
                      as int,
            callsToday: null == callsToday
                ? _value.callsToday
                : callsToday // ignore: cast_nullable_to_non_nullable
                      as int,
            leadsGenerated: null == leadsGenerated
                ? _value.leadsGenerated
                : leadsGenerated // ignore: cast_nullable_to_non_nullable
                      as int,
            customersManaged: null == customersManaged
                ? _value.customersManaged
                : customersManaged // ignore: cast_nullable_to_non_nullable
                      as int,
            systemHealth: null == systemHealth
                ? _value.systemHealth
                : systemHealth // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(
    _$DashboardStatsImpl value,
    $Res Function(_$DashboardStatsImpl) then,
  ) = __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int activeAgents,
    int messagesToday,
    int callsToday,
    int leadsGenerated,
    int customersManaged,
    String systemHealth,
  });
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
    _$DashboardStatsImpl _value,
    $Res Function(_$DashboardStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeAgents = null,
    Object? messagesToday = null,
    Object? callsToday = null,
    Object? leadsGenerated = null,
    Object? customersManaged = null,
    Object? systemHealth = null,
  }) {
    return _then(
      _$DashboardStatsImpl(
        activeAgents: null == activeAgents
            ? _value.activeAgents
            : activeAgents // ignore: cast_nullable_to_non_nullable
                  as int,
        messagesToday: null == messagesToday
            ? _value.messagesToday
            : messagesToday // ignore: cast_nullable_to_non_nullable
                  as int,
        callsToday: null == callsToday
            ? _value.callsToday
            : callsToday // ignore: cast_nullable_to_non_nullable
                  as int,
        leadsGenerated: null == leadsGenerated
            ? _value.leadsGenerated
            : leadsGenerated // ignore: cast_nullable_to_non_nullable
                  as int,
        customersManaged: null == customersManaged
            ? _value.customersManaged
            : customersManaged // ignore: cast_nullable_to_non_nullable
                  as int,
        systemHealth: null == systemHealth
            ? _value.systemHealth
            : systemHealth // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl({
    this.activeAgents = 0,
    this.messagesToday = 0,
    this.callsToday = 0,
    this.leadsGenerated = 0,
    this.customersManaged = 0,
    this.systemHealth = 'healthy',
  });

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  @override
  @JsonKey()
  final int activeAgents;
  @override
  @JsonKey()
  final int messagesToday;
  @override
  @JsonKey()
  final int callsToday;
  @override
  @JsonKey()
  final int leadsGenerated;
  @override
  @JsonKey()
  final int customersManaged;
  @override
  @JsonKey()
  final String systemHealth;

  @override
  String toString() {
    return 'DashboardStats(activeAgents: $activeAgents, messagesToday: $messagesToday, callsToday: $callsToday, leadsGenerated: $leadsGenerated, customersManaged: $customersManaged, systemHealth: $systemHealth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(other.activeAgents, activeAgents) ||
                other.activeAgents == activeAgents) &&
            (identical(other.messagesToday, messagesToday) ||
                other.messagesToday == messagesToday) &&
            (identical(other.callsToday, callsToday) ||
                other.callsToday == callsToday) &&
            (identical(other.leadsGenerated, leadsGenerated) ||
                other.leadsGenerated == leadsGenerated) &&
            (identical(other.customersManaged, customersManaged) ||
                other.customersManaged == customersManaged) &&
            (identical(other.systemHealth, systemHealth) ||
                other.systemHealth == systemHealth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    activeAgents,
    messagesToday,
    callsToday,
    leadsGenerated,
    customersManaged,
    systemHealth,
  );

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(this);
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats({
    final int activeAgents,
    final int messagesToday,
    final int callsToday,
    final int leadsGenerated,
    final int customersManaged,
    final String systemHealth,
  }) = _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  @override
  int get activeAgents;
  @override
  int get messagesToday;
  @override
  int get callsToday;
  @override
  int get leadsGenerated;
  @override
  int get customersManaged;
  @override
  String get systemHealth;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
