// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workflow_execution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkflowExecution _$WorkflowExecutionFromJson(Map<String, dynamic> json) {
  return _WorkflowExecution.fromJson(json);
}

/// @nodoc
mixin _$WorkflowExecution {
  String get id => throw _privateConstructorUsedError;
  String get workflowId => throw _privateConstructorUsedError;
  String? get triggerEvent => throw _privateConstructorUsedError;
  WorkflowExecutionStatus get status => throw _privateConstructorUsedError;
  String? get inputJson => throw _privateConstructorUsedError;
  String? get outputJson => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this WorkflowExecution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkflowExecution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkflowExecutionCopyWith<WorkflowExecution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkflowExecutionCopyWith<$Res> {
  factory $WorkflowExecutionCopyWith(
    WorkflowExecution value,
    $Res Function(WorkflowExecution) then,
  ) = _$WorkflowExecutionCopyWithImpl<$Res, WorkflowExecution>;
  @useResult
  $Res call({
    String id,
    String workflowId,
    String? triggerEvent,
    WorkflowExecutionStatus status,
    String? inputJson,
    String? outputJson,
    String? errorMessage,
    DateTime startedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$WorkflowExecutionCopyWithImpl<$Res, $Val extends WorkflowExecution>
    implements $WorkflowExecutionCopyWith<$Res> {
  _$WorkflowExecutionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkflowExecution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workflowId = null,
    Object? triggerEvent = freezed,
    Object? status = null,
    Object? inputJson = freezed,
    Object? outputJson = freezed,
    Object? errorMessage = freezed,
    Object? startedAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            workflowId: null == workflowId
                ? _value.workflowId
                : workflowId // ignore: cast_nullable_to_non_nullable
                      as String,
            triggerEvent: freezed == triggerEvent
                ? _value.triggerEvent
                : triggerEvent // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as WorkflowExecutionStatus,
            inputJson: freezed == inputJson
                ? _value.inputJson
                : inputJson // ignore: cast_nullable_to_non_nullable
                      as String?,
            outputJson: freezed == outputJson
                ? _value.outputJson
                : outputJson // ignore: cast_nullable_to_non_nullable
                      as String?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkflowExecutionImplCopyWith<$Res>
    implements $WorkflowExecutionCopyWith<$Res> {
  factory _$$WorkflowExecutionImplCopyWith(
    _$WorkflowExecutionImpl value,
    $Res Function(_$WorkflowExecutionImpl) then,
  ) = __$$WorkflowExecutionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String workflowId,
    String? triggerEvent,
    WorkflowExecutionStatus status,
    String? inputJson,
    String? outputJson,
    String? errorMessage,
    DateTime startedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$WorkflowExecutionImplCopyWithImpl<$Res>
    extends _$WorkflowExecutionCopyWithImpl<$Res, _$WorkflowExecutionImpl>
    implements _$$WorkflowExecutionImplCopyWith<$Res> {
  __$$WorkflowExecutionImplCopyWithImpl(
    _$WorkflowExecutionImpl _value,
    $Res Function(_$WorkflowExecutionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkflowExecution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workflowId = null,
    Object? triggerEvent = freezed,
    Object? status = null,
    Object? inputJson = freezed,
    Object? outputJson = freezed,
    Object? errorMessage = freezed,
    Object? startedAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$WorkflowExecutionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        workflowId: null == workflowId
            ? _value.workflowId
            : workflowId // ignore: cast_nullable_to_non_nullable
                  as String,
        triggerEvent: freezed == triggerEvent
            ? _value.triggerEvent
            : triggerEvent // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as WorkflowExecutionStatus,
        inputJson: freezed == inputJson
            ? _value.inputJson
            : inputJson // ignore: cast_nullable_to_non_nullable
                  as String?,
        outputJson: freezed == outputJson
            ? _value.outputJson
            : outputJson // ignore: cast_nullable_to_non_nullable
                  as String?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkflowExecutionImpl implements _WorkflowExecution {
  const _$WorkflowExecutionImpl({
    required this.id,
    required this.workflowId,
    this.triggerEvent,
    this.status = WorkflowExecutionStatus.running,
    this.inputJson,
    this.outputJson,
    this.errorMessage,
    required this.startedAt,
    this.completedAt,
  });

  factory _$WorkflowExecutionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkflowExecutionImplFromJson(json);

  @override
  final String id;
  @override
  final String workflowId;
  @override
  final String? triggerEvent;
  @override
  @JsonKey()
  final WorkflowExecutionStatus status;
  @override
  final String? inputJson;
  @override
  final String? outputJson;
  @override
  final String? errorMessage;
  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'WorkflowExecution(id: $id, workflowId: $workflowId, triggerEvent: $triggerEvent, status: $status, inputJson: $inputJson, outputJson: $outputJson, errorMessage: $errorMessage, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkflowExecutionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workflowId, workflowId) ||
                other.workflowId == workflowId) &&
            (identical(other.triggerEvent, triggerEvent) ||
                other.triggerEvent == triggerEvent) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.inputJson, inputJson) ||
                other.inputJson == inputJson) &&
            (identical(other.outputJson, outputJson) ||
                other.outputJson == outputJson) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    workflowId,
    triggerEvent,
    status,
    inputJson,
    outputJson,
    errorMessage,
    startedAt,
    completedAt,
  );

  /// Create a copy of WorkflowExecution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkflowExecutionImplCopyWith<_$WorkflowExecutionImpl> get copyWith =>
      __$$WorkflowExecutionImplCopyWithImpl<_$WorkflowExecutionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkflowExecutionImplToJson(this);
  }
}

abstract class _WorkflowExecution implements WorkflowExecution {
  const factory _WorkflowExecution({
    required final String id,
    required final String workflowId,
    final String? triggerEvent,
    final WorkflowExecutionStatus status,
    final String? inputJson,
    final String? outputJson,
    final String? errorMessage,
    required final DateTime startedAt,
    final DateTime? completedAt,
  }) = _$WorkflowExecutionImpl;

  factory _WorkflowExecution.fromJson(Map<String, dynamic> json) =
      _$WorkflowExecutionImpl.fromJson;

  @override
  String get id;
  @override
  String get workflowId;
  @override
  String? get triggerEvent;
  @override
  WorkflowExecutionStatus get status;
  @override
  String? get inputJson;
  @override
  String? get outputJson;
  @override
  String? get errorMessage;
  @override
  DateTime get startedAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of WorkflowExecution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkflowExecutionImplCopyWith<_$WorkflowExecutionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
