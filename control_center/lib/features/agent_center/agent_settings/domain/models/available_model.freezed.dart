// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'available_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AvailableModel _$AvailableModelFromJson(Map<String, dynamic> json) {
  return _AvailableModel.fromJson(json);
}

/// @nodoc
mixin _$AvailableModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;

  /// Serializes this AvailableModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AvailableModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AvailableModelCopyWith<AvailableModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AvailableModelCopyWith<$Res> {
  factory $AvailableModelCopyWith(
    AvailableModel value,
    $Res Function(AvailableModel) then,
  ) = _$AvailableModelCopyWithImpl<$Res, AvailableModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String provider,
    String? description,
    String? size,
    bool isAvailable,
  });
}

/// @nodoc
class _$AvailableModelCopyWithImpl<$Res, $Val extends AvailableModel>
    implements $AvailableModelCopyWith<$Res> {
  _$AvailableModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AvailableModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? provider = null,
    Object? description = freezed,
    Object? size = freezed,
    Object? isAvailable = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            size: freezed == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as String?,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AvailableModelImplCopyWith<$Res>
    implements $AvailableModelCopyWith<$Res> {
  factory _$$AvailableModelImplCopyWith(
    _$AvailableModelImpl value,
    $Res Function(_$AvailableModelImpl) then,
  ) = __$$AvailableModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String provider,
    String? description,
    String? size,
    bool isAvailable,
  });
}

/// @nodoc
class __$$AvailableModelImplCopyWithImpl<$Res>
    extends _$AvailableModelCopyWithImpl<$Res, _$AvailableModelImpl>
    implements _$$AvailableModelImplCopyWith<$Res> {
  __$$AvailableModelImplCopyWithImpl(
    _$AvailableModelImpl _value,
    $Res Function(_$AvailableModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AvailableModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? provider = null,
    Object? description = freezed,
    Object? size = freezed,
    Object? isAvailable = null,
  }) {
    return _then(
      _$AvailableModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        size: freezed == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as String?,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AvailableModelImpl implements _AvailableModel {
  const _$AvailableModelImpl({
    required this.id,
    required this.name,
    required this.provider,
    this.description,
    this.size,
    this.isAvailable = true,
  });

  factory _$AvailableModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AvailableModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String provider;
  @override
  final String? description;
  @override
  final String? size;
  @override
  @JsonKey()
  final bool isAvailable;

  @override
  String toString() {
    return 'AvailableModel(id: $id, name: $name, provider: $provider, description: $description, size: $size, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AvailableModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    provider,
    description,
    size,
    isAvailable,
  );

  /// Create a copy of AvailableModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AvailableModelImplCopyWith<_$AvailableModelImpl> get copyWith =>
      __$$AvailableModelImplCopyWithImpl<_$AvailableModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AvailableModelImplToJson(this);
  }
}

abstract class _AvailableModel implements AvailableModel {
  const factory _AvailableModel({
    required final String id,
    required final String name,
    required final String provider,
    final String? description,
    final String? size,
    final bool isAvailable,
  }) = _$AvailableModelImpl;

  factory _AvailableModel.fromJson(Map<String, dynamic> json) =
      _$AvailableModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get provider;
  @override
  String? get description;
  @override
  String? get size;
  @override
  bool get isAvailable;

  /// Create a copy of AvailableModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AvailableModelImplCopyWith<_$AvailableModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
