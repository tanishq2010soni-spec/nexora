// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_index.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SearchEntry {
  String get id => throw _privateConstructorUsedError;
  SearchModule get module => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  String get route => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  double get relevanceScore => throw _privateConstructorUsedError;

  /// Create a copy of SearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchEntryCopyWith<SearchEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchEntryCopyWith<$Res> {
  factory $SearchEntryCopyWith(
    SearchEntry value,
    $Res Function(SearchEntry) then,
  ) = _$SearchEntryCopyWithImpl<$Res, SearchEntry>;
  @useResult
  $Res call({
    String id,
    SearchModule module,
    String title,
    String? subtitle,
    String route,
    Map<String, dynamic>? metadata,
    double relevanceScore,
  });
}

/// @nodoc
class _$SearchEntryCopyWithImpl<$Res, $Val extends SearchEntry>
    implements $SearchEntryCopyWith<$Res> {
  _$SearchEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? module = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? route = null,
    Object? metadata = freezed,
    Object? relevanceScore = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            module: null == module
                ? _value.module
                : module // ignore: cast_nullable_to_non_nullable
                      as SearchModule,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            subtitle: freezed == subtitle
                ? _value.subtitle
                : subtitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            route: null == route
                ? _value.route
                : route // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            relevanceScore: null == relevanceScore
                ? _value.relevanceScore
                : relevanceScore // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchEntryImplCopyWith<$Res>
    implements $SearchEntryCopyWith<$Res> {
  factory _$$SearchEntryImplCopyWith(
    _$SearchEntryImpl value,
    $Res Function(_$SearchEntryImpl) then,
  ) = __$$SearchEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    SearchModule module,
    String title,
    String? subtitle,
    String route,
    Map<String, dynamic>? metadata,
    double relevanceScore,
  });
}

/// @nodoc
class __$$SearchEntryImplCopyWithImpl<$Res>
    extends _$SearchEntryCopyWithImpl<$Res, _$SearchEntryImpl>
    implements _$$SearchEntryImplCopyWith<$Res> {
  __$$SearchEntryImplCopyWithImpl(
    _$SearchEntryImpl _value,
    $Res Function(_$SearchEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? module = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? route = null,
    Object? metadata = freezed,
    Object? relevanceScore = null,
  }) {
    return _then(
      _$SearchEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        module: null == module
            ? _value.module
            : module // ignore: cast_nullable_to_non_nullable
                  as SearchModule,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        subtitle: freezed == subtitle
            ? _value.subtitle
            : subtitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        route: null == route
            ? _value.route
            : route // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        relevanceScore: null == relevanceScore
            ? _value.relevanceScore
            : relevanceScore // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$SearchEntryImpl implements _SearchEntry {
  const _$SearchEntryImpl({
    required this.id,
    required this.module,
    required this.title,
    this.subtitle,
    required this.route,
    final Map<String, dynamic>? metadata,
    this.relevanceScore = 0.0,
  }) : _metadata = metadata;

  @override
  final String id;
  @override
  final SearchModule module;
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final String route;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final double relevanceScore;

  @override
  String toString() {
    return 'SearchEntry(id: $id, module: $module, title: $title, subtitle: $subtitle, route: $route, metadata: $metadata, relevanceScore: $relevanceScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.route, route) || other.route == route) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.relevanceScore, relevanceScore) ||
                other.relevanceScore == relevanceScore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    module,
    title,
    subtitle,
    route,
    const DeepCollectionEquality().hash(_metadata),
    relevanceScore,
  );

  /// Create a copy of SearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchEntryImplCopyWith<_$SearchEntryImpl> get copyWith =>
      __$$SearchEntryImplCopyWithImpl<_$SearchEntryImpl>(this, _$identity);
}

abstract class _SearchEntry implements SearchEntry {
  const factory _SearchEntry({
    required final String id,
    required final SearchModule module,
    required final String title,
    final String? subtitle,
    required final String route,
    final Map<String, dynamic>? metadata,
    final double relevanceScore,
  }) = _$SearchEntryImpl;

  @override
  String get id;
  @override
  SearchModule get module;
  @override
  String get title;
  @override
  String? get subtitle;
  @override
  String get route;
  @override
  Map<String, dynamic>? get metadata;
  @override
  double get relevanceScore;

  /// Create a copy of SearchEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchEntryImplCopyWith<_$SearchEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
