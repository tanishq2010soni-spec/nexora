// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

KbDocument _$KbDocumentFromJson(Map<String, dynamic> json) {
  return _KbDocument.fromJson(json);
}

/// @nodoc
mixin _$KbDocument {
  String get id => throw _privateConstructorUsedError;
  String get knowledgeBaseId => throw _privateConstructorUsedError;
  String get filename => throw _privateConstructorUsedError;
  DocumentType get fileType => throw _privateConstructorUsedError;
  DocumentStatus get status => throw _privateConstructorUsedError;
  int get chunkCount => throw _privateConstructorUsedError;
  int get embeddingCount => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime? get indexedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this KbDocument to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KbDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KbDocumentCopyWith<KbDocument> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KbDocumentCopyWith<$Res> {
  factory $KbDocumentCopyWith(
    KbDocument value,
    $Res Function(KbDocument) then,
  ) = _$KbDocumentCopyWithImpl<$Res, KbDocument>;
  @useResult
  $Res call({
    String id,
    String knowledgeBaseId,
    String filename,
    DocumentType fileType,
    DocumentStatus status,
    int chunkCount,
    int embeddingCount,
    int fileSizeBytes,
    String? errorMessage,
    DateTime? indexedAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$KbDocumentCopyWithImpl<$Res, $Val extends KbDocument>
    implements $KbDocumentCopyWith<$Res> {
  _$KbDocumentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KbDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? knowledgeBaseId = null,
    Object? filename = null,
    Object? fileType = null,
    Object? status = null,
    Object? chunkCount = null,
    Object? embeddingCount = null,
    Object? fileSizeBytes = null,
    Object? errorMessage = freezed,
    Object? indexedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            knowledgeBaseId: null == knowledgeBaseId
                ? _value.knowledgeBaseId
                : knowledgeBaseId // ignore: cast_nullable_to_non_nullable
                      as String,
            filename: null == filename
                ? _value.filename
                : filename // ignore: cast_nullable_to_non_nullable
                      as String,
            fileType: null == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                      as DocumentType,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as DocumentStatus,
            chunkCount: null == chunkCount
                ? _value.chunkCount
                : chunkCount // ignore: cast_nullable_to_non_nullable
                      as int,
            embeddingCount: null == embeddingCount
                ? _value.embeddingCount
                : embeddingCount // ignore: cast_nullable_to_non_nullable
                      as int,
            fileSizeBytes: null == fileSizeBytes
                ? _value.fileSizeBytes
                : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                      as int,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            indexedAt: freezed == indexedAt
                ? _value.indexedAt
                : indexedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$KbDocumentImplCopyWith<$Res>
    implements $KbDocumentCopyWith<$Res> {
  factory _$$KbDocumentImplCopyWith(
    _$KbDocumentImpl value,
    $Res Function(_$KbDocumentImpl) then,
  ) = __$$KbDocumentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String knowledgeBaseId,
    String filename,
    DocumentType fileType,
    DocumentStatus status,
    int chunkCount,
    int embeddingCount,
    int fileSizeBytes,
    String? errorMessage,
    DateTime? indexedAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$KbDocumentImplCopyWithImpl<$Res>
    extends _$KbDocumentCopyWithImpl<$Res, _$KbDocumentImpl>
    implements _$$KbDocumentImplCopyWith<$Res> {
  __$$KbDocumentImplCopyWithImpl(
    _$KbDocumentImpl _value,
    $Res Function(_$KbDocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KbDocument
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? knowledgeBaseId = null,
    Object? filename = null,
    Object? fileType = null,
    Object? status = null,
    Object? chunkCount = null,
    Object? embeddingCount = null,
    Object? fileSizeBytes = null,
    Object? errorMessage = freezed,
    Object? indexedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$KbDocumentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        knowledgeBaseId: null == knowledgeBaseId
            ? _value.knowledgeBaseId
            : knowledgeBaseId // ignore: cast_nullable_to_non_nullable
                  as String,
        filename: null == filename
            ? _value.filename
            : filename // ignore: cast_nullable_to_non_nullable
                  as String,
        fileType: null == fileType
            ? _value.fileType
            : fileType // ignore: cast_nullable_to_non_nullable
                  as DocumentType,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as DocumentStatus,
        chunkCount: null == chunkCount
            ? _value.chunkCount
            : chunkCount // ignore: cast_nullable_to_non_nullable
                  as int,
        embeddingCount: null == embeddingCount
            ? _value.embeddingCount
            : embeddingCount // ignore: cast_nullable_to_non_nullable
                  as int,
        fileSizeBytes: null == fileSizeBytes
            ? _value.fileSizeBytes
            : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                  as int,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        indexedAt: freezed == indexedAt
            ? _value.indexedAt
            : indexedAt // ignore: cast_nullable_to_non_nullable
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
class _$KbDocumentImpl implements _KbDocument {
  const _$KbDocumentImpl({
    required this.id,
    required this.knowledgeBaseId,
    required this.filename,
    required this.fileType,
    required this.status,
    this.chunkCount = 0,
    this.embeddingCount = 0,
    this.fileSizeBytes = 0,
    this.errorMessage,
    this.indexedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$KbDocumentImpl.fromJson(Map<String, dynamic> json) =>
      _$$KbDocumentImplFromJson(json);

  @override
  final String id;
  @override
  final String knowledgeBaseId;
  @override
  final String filename;
  @override
  final DocumentType fileType;
  @override
  final DocumentStatus status;
  @override
  @JsonKey()
  final int chunkCount;
  @override
  @JsonKey()
  final int embeddingCount;
  @override
  @JsonKey()
  final int fileSizeBytes;
  @override
  final String? errorMessage;
  @override
  final DateTime? indexedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'KbDocument(id: $id, knowledgeBaseId: $knowledgeBaseId, filename: $filename, fileType: $fileType, status: $status, chunkCount: $chunkCount, embeddingCount: $embeddingCount, fileSizeBytes: $fileSizeBytes, errorMessage: $errorMessage, indexedAt: $indexedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KbDocumentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.knowledgeBaseId, knowledgeBaseId) ||
                other.knowledgeBaseId == knowledgeBaseId) &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.chunkCount, chunkCount) ||
                other.chunkCount == chunkCount) &&
            (identical(other.embeddingCount, embeddingCount) ||
                other.embeddingCount == embeddingCount) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.indexedAt, indexedAt) ||
                other.indexedAt == indexedAt) &&
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
    knowledgeBaseId,
    filename,
    fileType,
    status,
    chunkCount,
    embeddingCount,
    fileSizeBytes,
    errorMessage,
    indexedAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of KbDocument
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KbDocumentImplCopyWith<_$KbDocumentImpl> get copyWith =>
      __$$KbDocumentImplCopyWithImpl<_$KbDocumentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KbDocumentImplToJson(this);
  }
}

abstract class _KbDocument implements KbDocument {
  const factory _KbDocument({
    required final String id,
    required final String knowledgeBaseId,
    required final String filename,
    required final DocumentType fileType,
    required final DocumentStatus status,
    final int chunkCount,
    final int embeddingCount,
    final int fileSizeBytes,
    final String? errorMessage,
    final DateTime? indexedAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$KbDocumentImpl;

  factory _KbDocument.fromJson(Map<String, dynamic> json) =
      _$KbDocumentImpl.fromJson;

  @override
  String get id;
  @override
  String get knowledgeBaseId;
  @override
  String get filename;
  @override
  DocumentType get fileType;
  @override
  DocumentStatus get status;
  @override
  int get chunkCount;
  @override
  int get embeddingCount;
  @override
  int get fileSizeBytes;
  @override
  String? get errorMessage;
  @override
  DateTime? get indexedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of KbDocument
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KbDocumentImplCopyWith<_$KbDocumentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
