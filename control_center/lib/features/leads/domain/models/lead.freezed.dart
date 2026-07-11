// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lead.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Lead _$LeadFromJson(Map<String, dynamic> json) {
  return _Lead.fromJson(json);
}

/// @nodoc
mixin _$Lead {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  String? get jobTitle => throw _privateConstructorUsedError;
  LeadStatus get status => throw _privateConstructorUsedError;
  LeadSource get source => throw _privateConstructorUsedError;
  String? get assignedTo => throw _privateConstructorUsedError;
  String? get assignedToName => throw _privateConstructorUsedError;
  int get aiScore => throw _privateConstructorUsedError;
  int get intentScore => throw _privateConstructorUsedError;
  int get budgetScore => throw _privateConstructorUsedError;
  int get engagementScore => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  String? get conversationId => throw _privateConstructorUsedError;
  DateTime? get lastContactedAt => throw _privateConstructorUsedError;
  DateTime? get qualifiedAt => throw _privateConstructorUsedError;
  DateTime? get wonAt => throw _privateConstructorUsedError;
  DateTime? get lostAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Lead to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeadCopyWith<Lead> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeadCopyWith<$Res> {
  factory $LeadCopyWith(Lead value, $Res Function(Lead) then) =
      _$LeadCopyWithImpl<$Res, Lead>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String? email,
    String? phone,
    String? company,
    String? jobTitle,
    LeadStatus status,
    LeadSource source,
    String? assignedTo,
    String? assignedToName,
    int aiScore,
    int intentScore,
    int budgetScore,
    int engagementScore,
    String? notes,
    Map<String, dynamic>? metadata,
    String? conversationId,
    DateTime? lastContactedAt,
    DateTime? qualifiedAt,
    DateTime? wonAt,
    DateTime? lostAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$LeadCopyWithImpl<$Res, $Val extends Lead>
    implements $LeadCopyWith<$Res> {
  _$LeadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? company = freezed,
    Object? jobTitle = freezed,
    Object? status = null,
    Object? source = null,
    Object? assignedTo = freezed,
    Object? assignedToName = freezed,
    Object? aiScore = null,
    Object? intentScore = null,
    Object? budgetScore = null,
    Object? engagementScore = null,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? conversationId = freezed,
    Object? lastContactedAt = freezed,
    Object? qualifiedAt = freezed,
    Object? wonAt = freezed,
    Object? lostAt = freezed,
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
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            company: freezed == company
                ? _value.company
                : company // ignore: cast_nullable_to_non_nullable
                      as String?,
            jobTitle: freezed == jobTitle
                ? _value.jobTitle
                : jobTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as LeadStatus,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as LeadSource,
            assignedTo: freezed == assignedTo
                ? _value.assignedTo
                : assignedTo // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedToName: freezed == assignedToName
                ? _value.assignedToName
                : assignedToName // ignore: cast_nullable_to_non_nullable
                      as String?,
            aiScore: null == aiScore
                ? _value.aiScore
                : aiScore // ignore: cast_nullable_to_non_nullable
                      as int,
            intentScore: null == intentScore
                ? _value.intentScore
                : intentScore // ignore: cast_nullable_to_non_nullable
                      as int,
            budgetScore: null == budgetScore
                ? _value.budgetScore
                : budgetScore // ignore: cast_nullable_to_non_nullable
                      as int,
            engagementScore: null == engagementScore
                ? _value.engagementScore
                : engagementScore // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            conversationId: freezed == conversationId
                ? _value.conversationId
                : conversationId // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastContactedAt: freezed == lastContactedAt
                ? _value.lastContactedAt
                : lastContactedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            qualifiedAt: freezed == qualifiedAt
                ? _value.qualifiedAt
                : qualifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            wonAt: freezed == wonAt
                ? _value.wonAt
                : wonAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lostAt: freezed == lostAt
                ? _value.lostAt
                : lostAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$LeadImplCopyWith<$Res> implements $LeadCopyWith<$Res> {
  factory _$$LeadImplCopyWith(
    _$LeadImpl value,
    $Res Function(_$LeadImpl) then,
  ) = __$$LeadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String? email,
    String? phone,
    String? company,
    String? jobTitle,
    LeadStatus status,
    LeadSource source,
    String? assignedTo,
    String? assignedToName,
    int aiScore,
    int intentScore,
    int budgetScore,
    int engagementScore,
    String? notes,
    Map<String, dynamic>? metadata,
    String? conversationId,
    DateTime? lastContactedAt,
    DateTime? qualifiedAt,
    DateTime? wonAt,
    DateTime? lostAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$LeadImplCopyWithImpl<$Res>
    extends _$LeadCopyWithImpl<$Res, _$LeadImpl>
    implements _$$LeadImplCopyWith<$Res> {
  __$$LeadImplCopyWithImpl(_$LeadImpl _value, $Res Function(_$LeadImpl) _then)
    : super(_value, _then);

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orgId = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? company = freezed,
    Object? jobTitle = freezed,
    Object? status = null,
    Object? source = null,
    Object? assignedTo = freezed,
    Object? assignedToName = freezed,
    Object? aiScore = null,
    Object? intentScore = null,
    Object? budgetScore = null,
    Object? engagementScore = null,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? conversationId = freezed,
    Object? lastContactedAt = freezed,
    Object? qualifiedAt = freezed,
    Object? wonAt = freezed,
    Object? lostAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$LeadImpl(
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
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        company: freezed == company
            ? _value.company
            : company // ignore: cast_nullable_to_non_nullable
                  as String?,
        jobTitle: freezed == jobTitle
            ? _value.jobTitle
            : jobTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as LeadStatus,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as LeadSource,
        assignedTo: freezed == assignedTo
            ? _value.assignedTo
            : assignedTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedToName: freezed == assignedToName
            ? _value.assignedToName
            : assignedToName // ignore: cast_nullable_to_non_nullable
                  as String?,
        aiScore: null == aiScore
            ? _value.aiScore
            : aiScore // ignore: cast_nullable_to_non_nullable
                  as int,
        intentScore: null == intentScore
            ? _value.intentScore
            : intentScore // ignore: cast_nullable_to_non_nullable
                  as int,
        budgetScore: null == budgetScore
            ? _value.budgetScore
            : budgetScore // ignore: cast_nullable_to_non_nullable
                  as int,
        engagementScore: null == engagementScore
            ? _value.engagementScore
            : engagementScore // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        conversationId: freezed == conversationId
            ? _value.conversationId
            : conversationId // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastContactedAt: freezed == lastContactedAt
            ? _value.lastContactedAt
            : lastContactedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        qualifiedAt: freezed == qualifiedAt
            ? _value.qualifiedAt
            : qualifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        wonAt: freezed == wonAt
            ? _value.wonAt
            : wonAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lostAt: freezed == lostAt
            ? _value.lostAt
            : lostAt // ignore: cast_nullable_to_non_nullable
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
class _$LeadImpl implements _Lead {
  const _$LeadImpl({
    required this.id,
    required this.orgId,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.jobTitle,
    this.status = LeadStatus.newLead,
    this.source = LeadSource.manual,
    this.assignedTo,
    this.assignedToName,
    this.aiScore = 0,
    this.intentScore = 0,
    this.budgetScore = 0,
    this.engagementScore = 0,
    this.notes,
    final Map<String, dynamic>? metadata,
    this.conversationId,
    this.lastContactedAt,
    this.qualifiedAt,
    this.wonAt,
    this.lostAt,
    required this.createdAt,
    required this.updatedAt,
  }) : _metadata = metadata;

  factory _$LeadImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeadImplFromJson(json);

  @override
  final String id;
  @override
  final String orgId;
  @override
  final String name;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? company;
  @override
  final String? jobTitle;
  @override
  @JsonKey()
  final LeadStatus status;
  @override
  @JsonKey()
  final LeadSource source;
  @override
  final String? assignedTo;
  @override
  final String? assignedToName;
  @override
  @JsonKey()
  final int aiScore;
  @override
  @JsonKey()
  final int intentScore;
  @override
  @JsonKey()
  final int budgetScore;
  @override
  @JsonKey()
  final int engagementScore;
  @override
  final String? notes;
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
  final String? conversationId;
  @override
  final DateTime? lastContactedAt;
  @override
  final DateTime? qualifiedAt;
  @override
  final DateTime? wonAt;
  @override
  final DateTime? lostAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Lead(id: $id, orgId: $orgId, name: $name, email: $email, phone: $phone, company: $company, jobTitle: $jobTitle, status: $status, source: $source, assignedTo: $assignedTo, assignedToName: $assignedToName, aiScore: $aiScore, intentScore: $intentScore, budgetScore: $budgetScore, engagementScore: $engagementScore, notes: $notes, metadata: $metadata, conversationId: $conversationId, lastContactedAt: $lastContactedAt, qualifiedAt: $qualifiedAt, wonAt: $wonAt, lostAt: $lostAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeadImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.jobTitle, jobTitle) ||
                other.jobTitle == jobTitle) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.assignedToName, assignedToName) ||
                other.assignedToName == assignedToName) &&
            (identical(other.aiScore, aiScore) || other.aiScore == aiScore) &&
            (identical(other.intentScore, intentScore) ||
                other.intentScore == intentScore) &&
            (identical(other.budgetScore, budgetScore) ||
                other.budgetScore == budgetScore) &&
            (identical(other.engagementScore, engagementScore) ||
                other.engagementScore == engagementScore) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.lastContactedAt, lastContactedAt) ||
                other.lastContactedAt == lastContactedAt) &&
            (identical(other.qualifiedAt, qualifiedAt) ||
                other.qualifiedAt == qualifiedAt) &&
            (identical(other.wonAt, wonAt) || other.wonAt == wonAt) &&
            (identical(other.lostAt, lostAt) || other.lostAt == lostAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orgId,
    name,
    email,
    phone,
    company,
    jobTitle,
    status,
    source,
    assignedTo,
    assignedToName,
    aiScore,
    intentScore,
    budgetScore,
    engagementScore,
    notes,
    const DeepCollectionEquality().hash(_metadata),
    conversationId,
    lastContactedAt,
    qualifiedAt,
    wonAt,
    lostAt,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeadImplCopyWith<_$LeadImpl> get copyWith =>
      __$$LeadImplCopyWithImpl<_$LeadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeadImplToJson(this);
  }
}

abstract class _Lead implements Lead {
  const factory _Lead({
    required final String id,
    required final String orgId,
    required final String name,
    final String? email,
    final String? phone,
    final String? company,
    final String? jobTitle,
    final LeadStatus status,
    final LeadSource source,
    final String? assignedTo,
    final String? assignedToName,
    final int aiScore,
    final int intentScore,
    final int budgetScore,
    final int engagementScore,
    final String? notes,
    final Map<String, dynamic>? metadata,
    final String? conversationId,
    final DateTime? lastContactedAt,
    final DateTime? qualifiedAt,
    final DateTime? wonAt,
    final DateTime? lostAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$LeadImpl;

  factory _Lead.fromJson(Map<String, dynamic> json) = _$LeadImpl.fromJson;

  @override
  String get id;
  @override
  String get orgId;
  @override
  String get name;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get company;
  @override
  String? get jobTitle;
  @override
  LeadStatus get status;
  @override
  LeadSource get source;
  @override
  String? get assignedTo;
  @override
  String? get assignedToName;
  @override
  int get aiScore;
  @override
  int get intentScore;
  @override
  int get budgetScore;
  @override
  int get engagementScore;
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get metadata;
  @override
  String? get conversationId;
  @override
  DateTime? get lastContactedAt;
  @override
  DateTime? get qualifiedAt;
  @override
  DateTime? get wonAt;
  @override
  DateTime? get lostAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Lead
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeadImplCopyWith<_$LeadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
