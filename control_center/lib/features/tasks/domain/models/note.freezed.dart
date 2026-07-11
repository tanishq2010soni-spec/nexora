// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TaskNote _$TaskNoteFromJson(Map<String, dynamic> json) {
  return _TaskNote.fromJson(json);
}

/// @nodoc
mixin _$TaskNote {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TaskNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskNoteCopyWith<TaskNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskNoteCopyWith<$Res> {
  factory $TaskNoteCopyWith(TaskNote value, $Res Function(TaskNote) then) =
      _$TaskNoteCopyWithImpl<$Res, TaskNote>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String entityType,
    String entityId,
    String content,
    String? createdBy,
    DateTime createdAt,
  });
}

/// @nodoc
class _$TaskNoteCopyWithImpl<$Res, $Val extends TaskNote>
    implements $TaskNoteCopyWith<$Res> {
  _$TaskNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? content = null,
    Object? createdBy = freezed,
    Object? createdAt = null,
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
            entityType: null == entityType
                ? _value.entityType
                : entityType // ignore: cast_nullable_to_non_nullable
                      as String,
            entityId: null == entityId
                ? _value.entityId
                : entityId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$TaskNoteImplCopyWith<$Res>
    implements $TaskNoteCopyWith<$Res> {
  factory _$$TaskNoteImplCopyWith(
    _$TaskNoteImpl value,
    $Res Function(_$TaskNoteImpl) then,
  ) = __$$TaskNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String entityType,
    String entityId,
    String content,
    String? createdBy,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$TaskNoteImplCopyWithImpl<$Res>
    extends _$TaskNoteCopyWithImpl<$Res, _$TaskNoteImpl>
    implements _$$TaskNoteImplCopyWith<$Res> {
  __$$TaskNoteImplCopyWithImpl(
    _$TaskNoteImpl _value,
    $Res Function(_$TaskNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaskNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? content = null,
    Object? createdBy = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$TaskNoteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orgId: null == orgId
            ? _value.orgId
            : orgId // ignore: cast_nullable_to_non_nullable
                  as String,
        entityType: null == entityType
            ? _value.entityType
            : entityType // ignore: cast_nullable_to_non_nullable
                  as String,
        entityId: null == entityId
            ? _value.entityId
            : entityId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$TaskNoteImpl implements _TaskNote {
  const _$TaskNoteImpl({
    required this.id,
    required this.orgId,
    required this.entityType,
    required this.entityId,
    required this.content,
    this.createdBy,
    required this.createdAt,
  });

  factory _$TaskNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskNoteImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String entityType;
  @override
  final String entityId;
  @override
  final String content;
  @override
  final String? createdBy;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'TaskNote(id: $id, orgId: $orgId, entityType: $entityType, entityId: $entityId, content: $content, createdBy: $createdBy, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskNoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orgId,
    entityType,
    entityId,
    content,
    createdBy,
    createdAt,
  );

  /// Create a copy of TaskNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskNoteImplCopyWith<_$TaskNoteImpl> get copyWith =>
      __$$TaskNoteImplCopyWithImpl<_$TaskNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskNoteImplToJson(this);
  }
}

abstract class _TaskNote implements TaskNote {
  const factory _TaskNote({
    required final String id,
    required final String orgId,
    required final String entityType,
    required final String entityId,
    required final String content,
    final String? createdBy,
    required final DateTime createdAt,
  }) = _$TaskNoteImpl;

  factory _TaskNote.fromJson(Map<String, dynamic> json) =
      _$TaskNoteImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get entityType;
  @override
  String get entityId;
  @override
  String get content;
  @override
  String? get createdBy;
  @override
  DateTime get createdAt;

  /// Create a copy of TaskNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskNoteImplCopyWith<_$TaskNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
