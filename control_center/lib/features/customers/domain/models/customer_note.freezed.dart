// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CustomerNote _$CustomerNoteFromJson(Map<String, dynamic> json) {
  return _CustomerNote.fromJson(json);
}

/// @nodoc
mixin _$CustomerNote {
  String get id => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get authorId => throw _privateConstructorUsedError;
  String? get authorName => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CustomerNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomerNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerNoteCopyWith<CustomerNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerNoteCopyWith<$Res> {
  factory $CustomerNoteCopyWith(
    CustomerNote value,
    $Res Function(CustomerNote) then,
  ) = _$CustomerNoteCopyWithImpl<$Res, CustomerNote>;
  @useResult
  $Res call({
    String id,
    String customerId,
    String content,
    String? authorId,
    String? authorName,
    List<String> tags,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CustomerNoteCopyWithImpl<$Res, $Val extends CustomerNote>
    implements $CustomerNoteCopyWith<$Res> {
  _$CustomerNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? content = null,
    Object? authorId = freezed,
    Object? authorName = freezed,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            authorId: freezed == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            authorName: freezed == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$CustomerNoteImplCopyWith<$Res>
    implements $CustomerNoteCopyWith<$Res> {
  factory _$$CustomerNoteImplCopyWith(
    _$CustomerNoteImpl value,
    $Res Function(_$CustomerNoteImpl) then,
  ) = __$$CustomerNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String customerId,
    String content,
    String? authorId,
    String? authorName,
    List<String> tags,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CustomerNoteImplCopyWithImpl<$Res>
    extends _$CustomerNoteCopyWithImpl<$Res, _$CustomerNoteImpl>
    implements _$$CustomerNoteImplCopyWith<$Res> {
  __$$CustomerNoteImplCopyWithImpl(
    _$CustomerNoteImpl _value,
    $Res Function(_$CustomerNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? content = null,
    Object? authorId = freezed,
    Object? authorName = freezed,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CustomerNoteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        authorId: freezed == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        authorName: freezed == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
class _$CustomerNoteImpl implements _CustomerNote {
  const _$CustomerNoteImpl({
    required this.id,
    required this.customerId,
    required this.content,
    this.authorId,
    this.authorName,
    final List<String> tags = const [],
    required this.createdAt,
    required this.updatedAt,
  }) : _tags = tags;

  factory _$CustomerNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerNoteImplFromJson(json);

  @override
  final String id;
  @override
  final String customerId;
  @override
  final String content;
  @override
  final String? authorId;
  @override
  final String? authorName;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CustomerNote(id: $id, customerId: $customerId, content: $content, authorId: $authorId, authorName: $authorName, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerNoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
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
    customerId,
    content,
    authorId,
    authorName,
    const DeepCollectionEquality().hash(_tags),
    createdAt,
    updatedAt,
  );

  /// Create a copy of CustomerNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerNoteImplCopyWith<_$CustomerNoteImpl> get copyWith =>
      __$$CustomerNoteImplCopyWithImpl<_$CustomerNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerNoteImplToJson(this);
  }
}

abstract class _CustomerNote implements CustomerNote {
  const factory _CustomerNote({
    required final String id,
    required final String customerId,
    required final String content,
    final String? authorId,
    final String? authorName,
    final List<String> tags,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CustomerNoteImpl;

  factory _CustomerNote.fromJson(Map<String, dynamic> json) =
      _$CustomerNoteImpl.fromJson;

  @override
  String get id;
  @override
  String get customerId;
  @override
  String get content;
  @override
  String? get authorId;
  @override
  String? get authorName;
  @override
  List<String> get tags;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CustomerNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerNoteImplCopyWith<_$CustomerNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
