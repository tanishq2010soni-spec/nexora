// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'executive_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExecutiveSummary _$ExecutiveSummaryFromJson(Map<String, dynamic> json) {
  return _ExecutiveSummary.fromJson(json);
}

/// @nodoc
mixin _$ExecutiveSummary {
  SummaryData get summary => throw _privateConstructorUsedError;
  KpiData get kpis => throw _privateConstructorUsedError;

  /// Serializes this ExecutiveSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExecutiveSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExecutiveSummaryCopyWith<ExecutiveSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExecutiveSummaryCopyWith<$Res> {
  factory $ExecutiveSummaryCopyWith(
    ExecutiveSummary value,
    $Res Function(ExecutiveSummary) then,
  ) = _$ExecutiveSummaryCopyWithImpl<$Res, ExecutiveSummary>;
  @useResult
  $Res call({SummaryData summary, KpiData kpis});

  $SummaryDataCopyWith<$Res> get summary;
  $KpiDataCopyWith<$Res> get kpis;
}

/// @nodoc
class _$ExecutiveSummaryCopyWithImpl<$Res, $Val extends ExecutiveSummary>
    implements $ExecutiveSummaryCopyWith<$Res> {
  _$ExecutiveSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExecutiveSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? summary = null, Object? kpis = null}) {
    return _then(
      _value.copyWith(
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as SummaryData,
            kpis: null == kpis
                ? _value.kpis
                : kpis // ignore: cast_nullable_to_non_nullable
                      as KpiData,
          )
          as $Val,
    );
  }

  /// Create a copy of ExecutiveSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SummaryDataCopyWith<$Res> get summary {
    return $SummaryDataCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  /// Create a copy of ExecutiveSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $KpiDataCopyWith<$Res> get kpis {
    return $KpiDataCopyWith<$Res>(_value.kpis, (value) {
      return _then(_value.copyWith(kpis: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExecutiveSummaryImplCopyWith<$Res>
    implements $ExecutiveSummaryCopyWith<$Res> {
  factory _$$ExecutiveSummaryImplCopyWith(
    _$ExecutiveSummaryImpl value,
    $Res Function(_$ExecutiveSummaryImpl) then,
  ) = __$$ExecutiveSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SummaryData summary, KpiData kpis});

  @override
  $SummaryDataCopyWith<$Res> get summary;
  @override
  $KpiDataCopyWith<$Res> get kpis;
}

/// @nodoc
class __$$ExecutiveSummaryImplCopyWithImpl<$Res>
    extends _$ExecutiveSummaryCopyWithImpl<$Res, _$ExecutiveSummaryImpl>
    implements _$$ExecutiveSummaryImplCopyWith<$Res> {
  __$$ExecutiveSummaryImplCopyWithImpl(
    _$ExecutiveSummaryImpl _value,
    $Res Function(_$ExecutiveSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExecutiveSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? summary = null, Object? kpis = null}) {
    return _then(
      _$ExecutiveSummaryImpl(
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as SummaryData,
        kpis: null == kpis
            ? _value.kpis
            : kpis // ignore: cast_nullable_to_non_nullable
                  as KpiData,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExecutiveSummaryImpl implements _ExecutiveSummary {
  const _$ExecutiveSummaryImpl({required this.summary, required this.kpis});

  factory _$ExecutiveSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExecutiveSummaryImplFromJson(json);

  @override
  final SummaryData summary;
  @override
  final KpiData kpis;

  @override
  String toString() {
    return 'ExecutiveSummary(summary: $summary, kpis: $kpis)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExecutiveSummaryImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.kpis, kpis) || other.kpis == kpis));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, summary, kpis);

  /// Create a copy of ExecutiveSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExecutiveSummaryImplCopyWith<_$ExecutiveSummaryImpl> get copyWith =>
      __$$ExecutiveSummaryImplCopyWithImpl<_$ExecutiveSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExecutiveSummaryImplToJson(this);
  }
}

abstract class _ExecutiveSummary implements ExecutiveSummary {
  const factory _ExecutiveSummary({
    required final SummaryData summary,
    required final KpiData kpis,
  }) = _$ExecutiveSummaryImpl;

  factory _ExecutiveSummary.fromJson(Map<String, dynamic> json) =
      _$ExecutiveSummaryImpl.fromJson;

  @override
  SummaryData get summary;
  @override
  KpiData get kpis;

  /// Create a copy of ExecutiveSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExecutiveSummaryImplCopyWith<_$ExecutiveSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SummaryData _$SummaryDataFromJson(Map<String, dynamic> json) {
  return _SummaryData.fromJson(json);
}

/// @nodoc
mixin _$SummaryData {
  int get totalLeads => throw _privateConstructorUsedError;
  int get leadsThisMonth => throw _privateConstructorUsedError;
  int get leadsConverted => throw _privateConstructorUsedError;
  int get totalCustomers => throw _privateConstructorUsedError;
  int get totalAgents => throw _privateConstructorUsedError;
  int get totalConversations => throw _privateConstructorUsedError;
  int get openConversations => throw _privateConstructorUsedError;
  int get messagesToday => throw _privateConstructorUsedError;
  int get totalCalls => throw _privateConstructorUsedError;
  int get callsThisWeek => throw _privateConstructorUsedError;
  int get totalTasks => throw _privateConstructorUsedError;
  int get pendingTasks => throw _privateConstructorUsedError;
  int get completedTasks => throw _privateConstructorUsedError;
  int get activeWorkflows => throw _privateConstructorUsedError;

  /// Serializes this SummaryData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SummaryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SummaryDataCopyWith<SummaryData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryDataCopyWith<$Res> {
  factory $SummaryDataCopyWith(
    SummaryData value,
    $Res Function(SummaryData) then,
  ) = _$SummaryDataCopyWithImpl<$Res, SummaryData>;
  @useResult
  $Res call({
    int totalLeads,
    int leadsThisMonth,
    int leadsConverted,
    int totalCustomers,
    int totalAgents,
    int totalConversations,
    int openConversations,
    int messagesToday,
    int totalCalls,
    int callsThisWeek,
    int totalTasks,
    int pendingTasks,
    int completedTasks,
    int activeWorkflows,
  });
}

/// @nodoc
class _$SummaryDataCopyWithImpl<$Res, $Val extends SummaryData>
    implements $SummaryDataCopyWith<$Res> {
  _$SummaryDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SummaryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalLeads = null,
    Object? leadsThisMonth = null,
    Object? leadsConverted = null,
    Object? totalCustomers = null,
    Object? totalAgents = null,
    Object? totalConversations = null,
    Object? openConversations = null,
    Object? messagesToday = null,
    Object? totalCalls = null,
    Object? callsThisWeek = null,
    Object? totalTasks = null,
    Object? pendingTasks = null,
    Object? completedTasks = null,
    Object? activeWorkflows = null,
  }) {
    return _then(
      _value.copyWith(
            totalLeads: null == totalLeads
                ? _value.totalLeads
                : totalLeads // ignore: cast_nullable_to_non_nullable
                      as int,
            leadsThisMonth: null == leadsThisMonth
                ? _value.leadsThisMonth
                : leadsThisMonth // ignore: cast_nullable_to_non_nullable
                      as int,
            leadsConverted: null == leadsConverted
                ? _value.leadsConverted
                : leadsConverted // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCustomers: null == totalCustomers
                ? _value.totalCustomers
                : totalCustomers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalAgents: null == totalAgents
                ? _value.totalAgents
                : totalAgents // ignore: cast_nullable_to_non_nullable
                      as int,
            totalConversations: null == totalConversations
                ? _value.totalConversations
                : totalConversations // ignore: cast_nullable_to_non_nullable
                      as int,
            openConversations: null == openConversations
                ? _value.openConversations
                : openConversations // ignore: cast_nullable_to_non_nullable
                      as int,
            messagesToday: null == messagesToday
                ? _value.messagesToday
                : messagesToday // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCalls: null == totalCalls
                ? _value.totalCalls
                : totalCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            callsThisWeek: null == callsThisWeek
                ? _value.callsThisWeek
                : callsThisWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            totalTasks: null == totalTasks
                ? _value.totalTasks
                : totalTasks // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingTasks: null == pendingTasks
                ? _value.pendingTasks
                : pendingTasks // ignore: cast_nullable_to_non_nullable
                      as int,
            completedTasks: null == completedTasks
                ? _value.completedTasks
                : completedTasks // ignore: cast_nullable_to_non_nullable
                      as int,
            activeWorkflows: null == activeWorkflows
                ? _value.activeWorkflows
                : activeWorkflows // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SummaryDataImplCopyWith<$Res>
    implements $SummaryDataCopyWith<$Res> {
  factory _$$SummaryDataImplCopyWith(
    _$SummaryDataImpl value,
    $Res Function(_$SummaryDataImpl) then,
  ) = __$$SummaryDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalLeads,
    int leadsThisMonth,
    int leadsConverted,
    int totalCustomers,
    int totalAgents,
    int totalConversations,
    int openConversations,
    int messagesToday,
    int totalCalls,
    int callsThisWeek,
    int totalTasks,
    int pendingTasks,
    int completedTasks,
    int activeWorkflows,
  });
}

/// @nodoc
class __$$SummaryDataImplCopyWithImpl<$Res>
    extends _$SummaryDataCopyWithImpl<$Res, _$SummaryDataImpl>
    implements _$$SummaryDataImplCopyWith<$Res> {
  __$$SummaryDataImplCopyWithImpl(
    _$SummaryDataImpl _value,
    $Res Function(_$SummaryDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SummaryData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalLeads = null,
    Object? leadsThisMonth = null,
    Object? leadsConverted = null,
    Object? totalCustomers = null,
    Object? totalAgents = null,
    Object? totalConversations = null,
    Object? openConversations = null,
    Object? messagesToday = null,
    Object? totalCalls = null,
    Object? callsThisWeek = null,
    Object? totalTasks = null,
    Object? pendingTasks = null,
    Object? completedTasks = null,
    Object? activeWorkflows = null,
  }) {
    return _then(
      _$SummaryDataImpl(
        totalLeads: null == totalLeads
            ? _value.totalLeads
            : totalLeads // ignore: cast_nullable_to_non_nullable
                  as int,
        leadsThisMonth: null == leadsThisMonth
            ? _value.leadsThisMonth
            : leadsThisMonth // ignore: cast_nullable_to_non_nullable
                  as int,
        leadsConverted: null == leadsConverted
            ? _value.leadsConverted
            : leadsConverted // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCustomers: null == totalCustomers
            ? _value.totalCustomers
            : totalCustomers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalAgents: null == totalAgents
            ? _value.totalAgents
            : totalAgents // ignore: cast_nullable_to_non_nullable
                  as int,
        totalConversations: null == totalConversations
            ? _value.totalConversations
            : totalConversations // ignore: cast_nullable_to_non_nullable
                  as int,
        openConversations: null == openConversations
            ? _value.openConversations
            : openConversations // ignore: cast_nullable_to_non_nullable
                  as int,
        messagesToday: null == messagesToday
            ? _value.messagesToday
            : messagesToday // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCalls: null == totalCalls
            ? _value.totalCalls
            : totalCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        callsThisWeek: null == callsThisWeek
            ? _value.callsThisWeek
            : callsThisWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        totalTasks: null == totalTasks
            ? _value.totalTasks
            : totalTasks // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingTasks: null == pendingTasks
            ? _value.pendingTasks
            : pendingTasks // ignore: cast_nullable_to_non_nullable
                  as int,
        completedTasks: null == completedTasks
            ? _value.completedTasks
            : completedTasks // ignore: cast_nullable_to_non_nullable
                  as int,
        activeWorkflows: null == activeWorkflows
            ? _value.activeWorkflows
            : activeWorkflows // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SummaryDataImpl implements _SummaryData {
  const _$SummaryDataImpl({
    this.totalLeads = 0,
    this.leadsThisMonth = 0,
    this.leadsConverted = 0,
    this.totalCustomers = 0,
    this.totalAgents = 0,
    this.totalConversations = 0,
    this.openConversations = 0,
    this.messagesToday = 0,
    this.totalCalls = 0,
    this.callsThisWeek = 0,
    this.totalTasks = 0,
    this.pendingTasks = 0,
    this.completedTasks = 0,
    this.activeWorkflows = 0,
  });

  factory _$SummaryDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$SummaryDataImplFromJson(json);

  @override
  @JsonKey()
  final int totalLeads;
  @override
  @JsonKey()
  final int leadsThisMonth;
  @override
  @JsonKey()
  final int leadsConverted;
  @override
  @JsonKey()
  final int totalCustomers;
  @override
  @JsonKey()
  final int totalAgents;
  @override
  @JsonKey()
  final int totalConversations;
  @override
  @JsonKey()
  final int openConversations;
  @override
  @JsonKey()
  final int messagesToday;
  @override
  @JsonKey()
  final int totalCalls;
  @override
  @JsonKey()
  final int callsThisWeek;
  @override
  @JsonKey()
  final int totalTasks;
  @override
  @JsonKey()
  final int pendingTasks;
  @override
  @JsonKey()
  final int completedTasks;
  @override
  @JsonKey()
  final int activeWorkflows;

  @override
  String toString() {
    return 'SummaryData(totalLeads: $totalLeads, leadsThisMonth: $leadsThisMonth, leadsConverted: $leadsConverted, totalCustomers: $totalCustomers, totalAgents: $totalAgents, totalConversations: $totalConversations, openConversations: $openConversations, messagesToday: $messagesToday, totalCalls: $totalCalls, callsThisWeek: $callsThisWeek, totalTasks: $totalTasks, pendingTasks: $pendingTasks, completedTasks: $completedTasks, activeWorkflows: $activeWorkflows)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryDataImpl &&
            (identical(other.totalLeads, totalLeads) ||
                other.totalLeads == totalLeads) &&
            (identical(other.leadsThisMonth, leadsThisMonth) ||
                other.leadsThisMonth == leadsThisMonth) &&
            (identical(other.leadsConverted, leadsConverted) ||
                other.leadsConverted == leadsConverted) &&
            (identical(other.totalCustomers, totalCustomers) ||
                other.totalCustomers == totalCustomers) &&
            (identical(other.totalAgents, totalAgents) ||
                other.totalAgents == totalAgents) &&
            (identical(other.totalConversations, totalConversations) ||
                other.totalConversations == totalConversations) &&
            (identical(other.openConversations, openConversations) ||
                other.openConversations == openConversations) &&
            (identical(other.messagesToday, messagesToday) ||
                other.messagesToday == messagesToday) &&
            (identical(other.totalCalls, totalCalls) ||
                other.totalCalls == totalCalls) &&
            (identical(other.callsThisWeek, callsThisWeek) ||
                other.callsThisWeek == callsThisWeek) &&
            (identical(other.totalTasks, totalTasks) ||
                other.totalTasks == totalTasks) &&
            (identical(other.pendingTasks, pendingTasks) ||
                other.pendingTasks == pendingTasks) &&
            (identical(other.completedTasks, completedTasks) ||
                other.completedTasks == completedTasks) &&
            (identical(other.activeWorkflows, activeWorkflows) ||
                other.activeWorkflows == activeWorkflows));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalLeads,
    leadsThisMonth,
    leadsConverted,
    totalCustomers,
    totalAgents,
    totalConversations,
    openConversations,
    messagesToday,
    totalCalls,
    callsThisWeek,
    totalTasks,
    pendingTasks,
    completedTasks,
    activeWorkflows,
  );

  /// Create a copy of SummaryData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryDataImplCopyWith<_$SummaryDataImpl> get copyWith =>
      __$$SummaryDataImplCopyWithImpl<_$SummaryDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SummaryDataImplToJson(this);
  }
}

abstract class _SummaryData implements SummaryData {
  const factory _SummaryData({
    final int totalLeads,
    final int leadsThisMonth,
    final int leadsConverted,
    final int totalCustomers,
    final int totalAgents,
    final int totalConversations,
    final int openConversations,
    final int messagesToday,
    final int totalCalls,
    final int callsThisWeek,
    final int totalTasks,
    final int pendingTasks,
    final int completedTasks,
    final int activeWorkflows,
  }) = _$SummaryDataImpl;

  factory _SummaryData.fromJson(Map<String, dynamic> json) =
      _$SummaryDataImpl.fromJson;

  @override
  int get totalLeads;
  @override
  int get leadsThisMonth;
  @override
  int get leadsConverted;
  @override
  int get totalCustomers;
  @override
  int get totalAgents;
  @override
  int get totalConversations;
  @override
  int get openConversations;
  @override
  int get messagesToday;
  @override
  int get totalCalls;
  @override
  int get callsThisWeek;
  @override
  int get totalTasks;
  @override
  int get pendingTasks;
  @override
  int get completedTasks;
  @override
  int get activeWorkflows;

  /// Create a copy of SummaryData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SummaryDataImplCopyWith<_$SummaryDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KpiData _$KpiDataFromJson(Map<String, dynamic> json) {
  return _KpiData.fromJson(json);
}

/// @nodoc
mixin _$KpiData {
  double get leadConversionRate => throw _privateConstructorUsedError;
  int get avgResponseTimeSeconds => throw _privateConstructorUsedError;
  double get agentUtilizationRate => throw _privateConstructorUsedError;
  double get aiResolutionRate => throw _privateConstructorUsedError;

  /// Serializes this KpiData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KpiDataCopyWith<KpiData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KpiDataCopyWith<$Res> {
  factory $KpiDataCopyWith(KpiData value, $Res Function(KpiData) then) =
      _$KpiDataCopyWithImpl<$Res, KpiData>;
  @useResult
  $Res call({
    double leadConversionRate,
    int avgResponseTimeSeconds,
    double agentUtilizationRate,
    double aiResolutionRate,
  });
}

/// @nodoc
class _$KpiDataCopyWithImpl<$Res, $Val extends KpiData>
    implements $KpiDataCopyWith<$Res> {
  _$KpiDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leadConversionRate = null,
    Object? avgResponseTimeSeconds = null,
    Object? agentUtilizationRate = null,
    Object? aiResolutionRate = null,
  }) {
    return _then(
      _value.copyWith(
            leadConversionRate: null == leadConversionRate
                ? _value.leadConversionRate
                : leadConversionRate // ignore: cast_nullable_to_non_nullable
                      as double,
            avgResponseTimeSeconds: null == avgResponseTimeSeconds
                ? _value.avgResponseTimeSeconds
                : avgResponseTimeSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            agentUtilizationRate: null == agentUtilizationRate
                ? _value.agentUtilizationRate
                : agentUtilizationRate // ignore: cast_nullable_to_non_nullable
                      as double,
            aiResolutionRate: null == aiResolutionRate
                ? _value.aiResolutionRate
                : aiResolutionRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KpiDataImplCopyWith<$Res> implements $KpiDataCopyWith<$Res> {
  factory _$$KpiDataImplCopyWith(
    _$KpiDataImpl value,
    $Res Function(_$KpiDataImpl) then,
  ) = __$$KpiDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double leadConversionRate,
    int avgResponseTimeSeconds,
    double agentUtilizationRate,
    double aiResolutionRate,
  });
}

/// @nodoc
class __$$KpiDataImplCopyWithImpl<$Res>
    extends _$KpiDataCopyWithImpl<$Res, _$KpiDataImpl>
    implements _$$KpiDataImplCopyWith<$Res> {
  __$$KpiDataImplCopyWithImpl(
    _$KpiDataImpl _value,
    $Res Function(_$KpiDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leadConversionRate = null,
    Object? avgResponseTimeSeconds = null,
    Object? agentUtilizationRate = null,
    Object? aiResolutionRate = null,
  }) {
    return _then(
      _$KpiDataImpl(
        leadConversionRate: null == leadConversionRate
            ? _value.leadConversionRate
            : leadConversionRate // ignore: cast_nullable_to_non_nullable
                  as double,
        avgResponseTimeSeconds: null == avgResponseTimeSeconds
            ? _value.avgResponseTimeSeconds
            : avgResponseTimeSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        agentUtilizationRate: null == agentUtilizationRate
            ? _value.agentUtilizationRate
            : agentUtilizationRate // ignore: cast_nullable_to_non_nullable
                  as double,
        aiResolutionRate: null == aiResolutionRate
            ? _value.aiResolutionRate
            : aiResolutionRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KpiDataImpl implements _KpiData {
  const _$KpiDataImpl({
    this.leadConversionRate = 0.0,
    this.avgResponseTimeSeconds = 0,
    this.agentUtilizationRate = 0.0,
    this.aiResolutionRate = 0.0,
  });

  factory _$KpiDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$KpiDataImplFromJson(json);

  @override
  @JsonKey()
  final double leadConversionRate;
  @override
  @JsonKey()
  final int avgResponseTimeSeconds;
  @override
  @JsonKey()
  final double agentUtilizationRate;
  @override
  @JsonKey()
  final double aiResolutionRate;

  @override
  String toString() {
    return 'KpiData(leadConversionRate: $leadConversionRate, avgResponseTimeSeconds: $avgResponseTimeSeconds, agentUtilizationRate: $agentUtilizationRate, aiResolutionRate: $aiResolutionRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KpiDataImpl &&
            (identical(other.leadConversionRate, leadConversionRate) ||
                other.leadConversionRate == leadConversionRate) &&
            (identical(other.avgResponseTimeSeconds, avgResponseTimeSeconds) ||
                other.avgResponseTimeSeconds == avgResponseTimeSeconds) &&
            (identical(other.agentUtilizationRate, agentUtilizationRate) ||
                other.agentUtilizationRate == agentUtilizationRate) &&
            (identical(other.aiResolutionRate, aiResolutionRate) ||
                other.aiResolutionRate == aiResolutionRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    leadConversionRate,
    avgResponseTimeSeconds,
    agentUtilizationRate,
    aiResolutionRate,
  );

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KpiDataImplCopyWith<_$KpiDataImpl> get copyWith =>
      __$$KpiDataImplCopyWithImpl<_$KpiDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KpiDataImplToJson(this);
  }
}

abstract class _KpiData implements KpiData {
  const factory _KpiData({
    final double leadConversionRate,
    final int avgResponseTimeSeconds,
    final double agentUtilizationRate,
    final double aiResolutionRate,
  }) = _$KpiDataImpl;

  factory _KpiData.fromJson(Map<String, dynamic> json) = _$KpiDataImpl.fromJson;

  @override
  double get leadConversionRate;
  @override
  int get avgResponseTimeSeconds;
  @override
  double get agentUtilizationRate;
  @override
  double get aiResolutionRate;

  /// Create a copy of KpiData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KpiDataImplCopyWith<_$KpiDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
