// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'knowledge_base.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

KnowledgeBase _$KnowledgeBaseFromJson(Map<String, dynamic> json) {
  return _KnowledgeBase.fromJson(json);
}

/// @nodoc
mixin _$KnowledgeBase {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get documentCount => throw _privateConstructorUsedError;
  int get totalChunks => throw _privateConstructorUsedError;
  int get totalEmbeddings => throw _privateConstructorUsedError;
  String get qdrantSyncStatus => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this KnowledgeBase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KnowledgeBase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KnowledgeBaseCopyWith<KnowledgeBase> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KnowledgeBaseCopyWith<$Res> {
  factory $KnowledgeBaseCopyWith(
    KnowledgeBase value,
    $Res Function(KnowledgeBase) then,
  ) = _$KnowledgeBaseCopyWithImpl<$Res, KnowledgeBase>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String? description,
    int documentCount,
    int totalChunks,
    int totalEmbeddings,
    String qdrantSyncStatus,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$KnowledgeBaseCopyWithImpl<$Res, $Val extends KnowledgeBase>
    implements $KnowledgeBaseCopyWith<$Res> {
  _$KnowledgeBaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KnowledgeBase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? description = freezed,
    Object? documentCount = null,
    Object? totalChunks = null,
    Object? totalEmbeddings = null,
    Object? qdrantSyncStatus = null,
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
            documentCount: null == documentCount
                ? _value.documentCount
                : documentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalChunks: null == totalChunks
                ? _value.totalChunks
                : totalChunks // ignore: cast_nullable_to_non_nullable
                      as int,
            totalEmbeddings: null == totalEmbeddings
                ? _value.totalEmbeddings
                : totalEmbeddings // ignore: cast_nullable_to_non_nullable
                      as int,
            qdrantSyncStatus: null == qdrantSyncStatus
                ? _value.qdrantSyncStatus
                : qdrantSyncStatus // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$KnowledgeBaseImplCopyWith<$Res>
    implements $KnowledgeBaseCopyWith<$Res> {
  factory _$$KnowledgeBaseImplCopyWith(
    _$KnowledgeBaseImpl value,
    $Res Function(_$KnowledgeBaseImpl) then,
  ) = __$$KnowledgeBaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String? description,
    int documentCount,
    int totalChunks,
    int totalEmbeddings,
    String qdrantSyncStatus,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$KnowledgeBaseImplCopyWithImpl<$Res>
    extends _$KnowledgeBaseCopyWithImpl<$Res, _$KnowledgeBaseImpl>
    implements _$$KnowledgeBaseImplCopyWith<$Res> {
  __$$KnowledgeBaseImplCopyWithImpl(
    _$KnowledgeBaseImpl _value,
    $Res Function(_$KnowledgeBaseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KnowledgeBase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? description = freezed,
    Object? documentCount = null,
    Object? totalChunks = null,
    Object? totalEmbeddings = null,
    Object? qdrantSyncStatus = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$KnowledgeBaseImpl(
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
        documentCount: null == documentCount
            ? _value.documentCount
            : documentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalChunks: null == totalChunks
            ? _value.totalChunks
            : totalChunks // ignore: cast_nullable_to_non_nullable
                  as int,
        totalEmbeddings: null == totalEmbeddings
            ? _value.totalEmbeddings
            : totalEmbeddings // ignore: cast_nullable_to_non_nullable
                  as int,
        qdrantSyncStatus: null == qdrantSyncStatus
            ? _value.qdrantSyncStatus
            : qdrantSyncStatus // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$KnowledgeBaseImpl implements _KnowledgeBase {
  const _$KnowledgeBaseImpl({
    required this.id,
    required this.orgId,
    required this.name,
    this.description,
    this.documentCount = 0,
    this.totalChunks = 0,
    this.totalEmbeddings = 0,
    this.qdrantSyncStatus = 'healthy',
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$KnowledgeBaseImpl.fromJson(Map<String, dynamic> json) =>
      _$$KnowledgeBaseImplFromJson(json);

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
  final int documentCount;
  @override
  @JsonKey()
  final int totalChunks;
  @override
  @JsonKey()
  final int totalEmbeddings;
  @override
  @JsonKey()
  final String qdrantSyncStatus;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'KnowledgeBase(id: $id, orgId: $orgId, name: $name, description: $description, documentCount: $documentCount, totalChunks: $totalChunks, totalEmbeddings: $totalEmbeddings, qdrantSyncStatus: $qdrantSyncStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KnowledgeBaseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.documentCount, documentCount) ||
                other.documentCount == documentCount) &&
            (identical(other.totalChunks, totalChunks) ||
                other.totalChunks == totalChunks) &&
            (identical(other.totalEmbeddings, totalEmbeddings) ||
                other.totalEmbeddings == totalEmbeddings) &&
            (identical(other.qdrantSyncStatus, qdrantSyncStatus) ||
                other.qdrantSyncStatus == qdrantSyncStatus) &&
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
    documentCount,
    totalChunks,
    totalEmbeddings,
    qdrantSyncStatus,
    createdAt,
    updatedAt,
  );

  /// Create a copy of KnowledgeBase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KnowledgeBaseImplCopyWith<_$KnowledgeBaseImpl> get copyWith =>
      __$$KnowledgeBaseImplCopyWithImpl<_$KnowledgeBaseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KnowledgeBaseImplToJson(this);
  }
}

abstract class _KnowledgeBase implements KnowledgeBase {
  const factory _KnowledgeBase({
    required final String id,
    required final String orgId,
    required final String name,
    final String? description,
    final int documentCount,
    final int totalChunks,
    final int totalEmbeddings,
    final String qdrantSyncStatus,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$KnowledgeBaseImpl;

  factory _KnowledgeBase.fromJson(Map<String, dynamic> json) =
      _$KnowledgeBaseImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get name;
  @override
  String? get description;
  @override
  int get documentCount;
  @override
  int get totalChunks;
  @override
  int get totalEmbeddings;
  @override
  String get qdrantSyncStatus;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of KnowledgeBase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KnowledgeBaseImplCopyWith<_$KnowledgeBaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
