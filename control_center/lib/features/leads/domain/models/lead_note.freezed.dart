// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeadNote _$LeadNoteFromJson(Map<String, dynamic> json) {
  return _LeadNote.fromJson(json);
}

/// @nodoc
mixin _$LeadNote {
  String get id => throw _privateConstructorUsedError;
  String get leadId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get authorName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LeadNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeadNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadNoteCopyWith<LeadNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadNoteCopyWith<$Res> {
  factory $LeadNoteCopyWith(LeadNote value, $Res Function(LeadNote) then) =
      _$LeadNoteCopyWithImpl<$Res, LeadNote>;
  @useResult
  $Res call({
    String id,
    String leadId,
    String content,
    String authorName,
    DateTime createdAt,
  });
}

/// @nodoc
class _$LeadNoteCopyWithImpl<$Res, $Val extends LeadNote>
    implements $LeadNoteCopyWith<$Res> {
  _$LeadNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeadNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? leadId = null,
    Object? content = null,
    Object? authorName = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            leadId: null == leadId
                ? _value.leadId
                : leadId // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            authorName: null == authorName
                ? _value.authorName
                : authorName // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$LeadNoteImplCopyWith<$Res>
    implements $LeadNoteCopyWith<$Res> {
  factory _$$LeadNoteImplCopyWith(
    _$LeadNoteImpl value,
    $Res Function(_$LeadNoteImpl) then,
  ) = __$$LeadNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String leadId,
    String content,
    String authorName,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$LeadNoteImplCopyWithImpl<$Res>
    extends _$LeadNoteCopyWithImpl<$Res, _$LeadNoteImpl>
    implements _$$LeadNoteImplCopyWith<$Res> {
  __$$LeadNoteImplCopyWithImpl(
    _$LeadNoteImpl _value,
    $Res Function(_$LeadNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeadNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? leadId = null,
    Object? content = null,
    Object? authorName = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LeadNoteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        leadId: null == leadId
            ? _value.leadId
            : leadId // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        authorName: null == authorName
            ? _value.authorName
            : authorName // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$LeadNoteImpl implements _LeadNote {
  const _$LeadNoteImpl({
    required this.id,
    required this.leadId,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  factory _$LeadNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadNoteImplFromJson(json);

  @override
  final String id;
  @override
  final String leadId;
  @override
  final String content;
  @override
  final String authorName;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LeadNote(id: $id, leadId: $leadId, content: $content, authorName: $authorName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadNoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.leadId, leadId) || other.leadId == leadId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, leadId, content, authorName, createdAt);

  /// Create a copy of LeadNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadNoteImplCopyWith<_$LeadNoteImpl> get copyWith =>
      __$$LeadNoteImplCopyWithImpl<_$LeadNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadNoteImplToJson(this);
  }
}

abstract class _LeadNote implements LeadNote {
  const factory _LeadNote({
    required final String id,
    required final String leadId,
    required final String content,
    required final String authorName,
    required final DateTime createdAt,
  }) = _$LeadNoteImpl;

  factory _LeadNote.fromJson(Map<String, dynamic> json) =
      _$LeadNoteImpl.fromJson;

  @override
  String get id;
  @override
  String get leadId;
  @override
  String get content;
  @override
  String get authorName;
  @override
  DateTime get createdAt;

  /// Create a copy of LeadNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadNoteImplCopyWith<_$LeadNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
