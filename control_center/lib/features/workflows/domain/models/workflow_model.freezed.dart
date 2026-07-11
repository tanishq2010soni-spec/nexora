// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workflow_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkflowModel _$WorkflowModelFromJson(Map<String, dynamic> json) {
  return _WorkflowModel.fromJson(json);
}

/// @nodoc
mixin _$WorkflowModel {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  WorkflowTriggerType get triggerType => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get nodesJson => throw _privateConstructorUsedError;
  String get edgesJson => throw _privateConstructorUsedError;
  int get executionCount => throw _privateConstructorUsedError;
  DateTime? get lastExecutedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WorkflowModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkflowModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkflowModelCopyWith<WorkflowModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkflowModelCopyWith<$Res> {
  factory $WorkflowModelCopyWith(
    WorkflowModel value,
    $Res Function(WorkflowModel) then,
  ) = _$WorkflowModelCopyWithImpl<$Res, WorkflowModel>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String? description,
    WorkflowTriggerType triggerType,
    bool isActive,
    String nodesJson,
    String edgesJson,
    int executionCount,
    DateTime? lastExecutedAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$WorkflowModelCopyWithImpl<$Res, $Val extends WorkflowModel>
    implements $WorkflowModelCopyWith<$Res> {
  _$WorkflowModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkflowModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? description = freezed,
    Object? triggerType = null,
    Object? isActive = null,
    Object? nodesJson = null,
    Object? edgesJson = null,
    Object? executionCount = null,
    Object? lastExecutedAt = freezed,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            triggerType: null == triggerType
                ? _value.triggerType
                : triggerType // ignore: cast_nullable_to_non_nullable
                      as WorkflowTriggerType,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            nodesJson: null == nodesJson
                ? _value.nodesJson
                : nodesJson // ignore: cast_nullable_to_non_nullable
                      as String,
            edgesJson: null == edgesJson
                ? _value.edgesJson
                : edgesJson // ignore: cast_nullable_to_non_nullable
                      as String,
            executionCount: null == executionCount
                ? _value.executionCount
                : executionCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastExecutedAt: freezed == lastExecutedAt
                ? _value.lastExecutedAt
                : lastExecutedAt // ignore: cast_nullable_to_non_nullable
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
}

/// @nodoc
abstract class _$$WorkflowModelImplCopyWith<$Res>
    implements $WorkflowModelCopyWith<$Res> {
  factory _$$WorkflowModelImplCopyWith(
    _$WorkflowModelImpl value,
    $Res Function(_$WorkflowModelImpl) then,
  ) = __$$WorkflowModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String? description,
    WorkflowTriggerType triggerType,
    bool isActive,
    String nodesJson,
    String edgesJson,
    int executionCount,
    DateTime? lastExecutedAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$WorkflowModelImplCopyWithImpl<$Res>
    extends _$WorkflowModelCopyWithImpl<$Res, _$WorkflowModelImpl>
    implements _$$WorkflowModelImplCopyWith<$Res> {
  __$$WorkflowModelImplCopyWithImpl(
    _$WorkflowModelImpl _value,
    $Res Function(_$WorkflowModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkflowModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? description = freezed,
    Object? triggerType = null,
    Object? isActive = null,
    Object? nodesJson = null,
    Object? edgesJson = null,
    Object? executionCount = null,
    Object? lastExecutedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$WorkflowModelImpl(
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
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        triggerType: null == triggerType
            ? _value.triggerType
            : triggerType // ignore: cast_nullable_to_non_nullable
                  as WorkflowTriggerType,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        nodesJson: null == nodesJson
            ? _value.nodesJson
            : nodesJson // ignore: cast_nullable_to_non_nullable
                  as String,
        edgesJson: null == edgesJson
            ? _value.edgesJson
            : edgesJson // ignore: cast_nullable_to_non_nullable
                  as String,
        executionCount: null == executionCount
            ? _value.executionCount
            : executionCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastExecutedAt: freezed == lastExecutedAt
            ? _value.lastExecutedAt
            : lastExecutedAt // ignore: cast_nullable_to_non_nullable
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
class _$WorkflowModelImpl implements _WorkflowModel {
  const _$WorkflowModelImpl({
    required this.id,
    required this.orgId,
    required this.name,
    this.description,
    this.triggerType = WorkflowTriggerType.manual,
    this.isActive = true,
    this.nodesJson = '[]',
    this.edgesJson = '[]',
    this.executionCount = 0,
    this.lastExecutedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$WorkflowModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkflowModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final WorkflowTriggerType triggerType;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final String nodesJson;
  @override
  @JsonKey()
  final String edgesJson;
  @override
  @JsonKey()
  final int executionCount;
  @override
  final DateTime? lastExecutedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'WorkflowModel(id: $id, orgId: $orgId, name: $name, description: $description, triggerType: $triggerType, isActive: $isActive, nodesJson: $nodesJson, edgesJson: $edgesJson, executionCount: $executionCount, lastExecutedAt: $lastExecutedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkflowModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.triggerType, triggerType) ||
                other.triggerType == triggerType) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.nodesJson, nodesJson) ||
                other.nodesJson == nodesJson) &&
            (identical(other.edgesJson, edgesJson) ||
                other.edgesJson == edgesJson) &&
            (identical(other.executionCount, executionCount) ||
                other.executionCount == executionCount) &&
            (identical(other.lastExecutedAt, lastExecutedAt) ||
                other.lastExecutedAt == lastExecutedAt) &&
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
    description,
    triggerType,
    isActive,
    nodesJson,
    edgesJson,
    executionCount,
    lastExecutedAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of WorkflowModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkflowModelImplCopyWith<_$WorkflowModelImpl> get copyWith =>
      __$$WorkflowModelImplCopyWithImpl<_$WorkflowModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkflowModelImplToJson(this);
  }
}

abstract class _WorkflowModel implements WorkflowModel {
  const factory _WorkflowModel({
    required final String id,
    required final String orgId,
    required final String name,
    final String? description,
    final WorkflowTriggerType triggerType,
    final bool isActive,
    final String nodesJson,
    final String edgesJson,
    final int executionCount,
    final DateTime? lastExecutedAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$WorkflowModelImpl;

  factory _WorkflowModel.fromJson(Map<String, dynamic> json) =
      _$WorkflowModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get name;
  @override
  String? get description;
  @override
  WorkflowTriggerType get triggerType;
  @override
  bool get isActive;
  @override
  String get nodesJson;
  @override
  String get edgesJson;
  @override
  int get executionCount;
  @override
  DateTime? get lastExecutedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of WorkflowModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkflowModelImplCopyWith<_$WorkflowModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
