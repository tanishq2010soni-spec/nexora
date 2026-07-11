// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return _Customer.fromJson(json);
}

/// @nodoc
mixin _$Customer {
  String get id => throw _privateConstructorUsedError;
  String get orgId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  String? get jobTitle => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  CustomerSegment get segment => throw _privateConstructorUsedError;
  int get healthScore => throw _privateConstructorUsedError;
  int get engagementScore => throw _privateConstructorUsedError;
  int get retentionScore => throw _privateConstructorUsedError;
  int get satisfactionScore => throw _privateConstructorUsedError;
  int get revenueScore => throw _privateConstructorUsedError;
  String? get assignedTo => throw _privateConstructorUsedError;
  String? get assignedToName => throw _privateConstructorUsedError;
  String? get leadId => throw _privateConstructorUsedError;
  int get totalInteractions => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  Map<String, dynamic>? get preferences => throw _privateConstructorUsedError;
  Map<String, dynamic>? get memory => throw _privateConstructorUsedError;
  DateTime? get lastInteractionAt => throw _privateConstructorUsedError;
  DateTime? get lastPurchaseAt => throw _privateConstructorUsedError;
  DateTime? get churnedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Customer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerCopyWith<Customer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerCopyWith<$Res> {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) then) =
      _$CustomerCopyWithImpl<$Res, Customer>;
  @useResult
  $Res call({
    String id,
    String orgId,
    String name,
    String? email,
    String? phone,
    String? company,
    String? jobTitle,
    String? avatarUrl,
    CustomerSegment segment,
    int healthScore,
    int engagementScore,
    int retentionScore,
    int satisfactionScore,
    int revenueScore,
    String? assignedTo,
    String? assignedToName,
    String? leadId,
    int totalInteractions,
    double totalRevenue,
    List<String> tags,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? memory,
    DateTime? lastInteractionAt,
    DateTime? lastPurchaseAt,
    DateTime? churnedAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CustomerCopyWithImpl<$Res, $Val extends Customer>
    implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Customer
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
    Object? avatarUrl = freezed,
    Object? segment = null,
    Object? healthScore = null,
    Object? engagementScore = null,
    Object? retentionScore = null,
    Object? satisfactionScore = null,
    Object? revenueScore = null,
    Object? assignedTo = freezed,
    Object? assignedToName = freezed,
    Object? leadId = freezed,
    Object? totalInteractions = null,
    Object? totalRevenue = null,
    Object? tags = null,
    Object? preferences = freezed,
    Object? memory = freezed,
    Object? lastInteractionAt = freezed,
    Object? lastPurchaseAt = freezed,
    Object? churnedAt = freezed,
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
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            segment: null == segment
                ? _value.segment
                : segment // ignore: cast_nullable_to_non_nullable
                      as CustomerSegment,
            healthScore: null == healthScore
                ? _value.healthScore
                : healthScore // ignore: cast_nullable_to_non_nullable
                      as int,
            engagementScore: null == engagementScore
                ? _value.engagementScore
                : engagementScore // ignore: cast_nullable_to_non_nullable
                      as int,
            retentionScore: null == retentionScore
                ? _value.retentionScore
                : retentionScore // ignore: cast_nullable_to_non_nullable
                      as int,
            satisfactionScore: null == satisfactionScore
                ? _value.satisfactionScore
                : satisfactionScore // ignore: cast_nullable_to_non_nullable
                      as int,
            revenueScore: null == revenueScore
                ? _value.revenueScore
                : revenueScore // ignore: cast_nullable_to_non_nullable
                      as int,
            assignedTo: freezed == assignedTo
                ? _value.assignedTo
                : assignedTo // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedToName: freezed == assignedToName
                ? _value.assignedToName
                : assignedToName // ignore: cast_nullable_to_non_nullable
                      as String?,
            leadId: freezed == leadId
                ? _value.leadId
                : leadId // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalInteractions: null == totalInteractions
                ? _value.totalInteractions
                : totalInteractions // ignore: cast_nullable_to_non_nullable
                      as int,
            totalRevenue: null == totalRevenue
                ? _value.totalRevenue
                : totalRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            preferences: freezed == preferences
                ? _value.preferences
                : preferences // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            memory: freezed == memory
                ? _value.memory
                : memory // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            lastInteractionAt: freezed == lastInteractionAt
                ? _value.lastInteractionAt
                : lastInteractionAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastPurchaseAt: freezed == lastPurchaseAt
                ? _value.lastPurchaseAt
                : lastPurchaseAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            churnedAt: freezed == churnedAt
                ? _value.churnedAt
                : churnedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CustomerImplCopyWith<$Res>
    implements $CustomerCopyWith<$Res> {
  factory _$$CustomerImplCopyWith(
    _$CustomerImpl value,
    $Res Function(_$CustomerImpl) then,
  ) = __$$CustomerImplCopyWithImpl<$Res>;
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
    String? avatarUrl,
    CustomerSegment segment,
    int healthScore,
    int engagementScore,
    int retentionScore,
    int satisfactionScore,
    int revenueScore,
    String? assignedTo,
    String? assignedToName,
    String? leadId,
    int totalInteractions,
    double totalRevenue,
    List<String> tags,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? memory,
    DateTime? lastInteractionAt,
    DateTime? lastPurchaseAt,
    DateTime? churnedAt,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CustomerImplCopyWithImpl<$Res>
    extends _$CustomerCopyWithImpl<$Res, _$CustomerImpl>
    implements _$$CustomerImplCopyWith<$Res> {
  __$$CustomerImplCopyWithImpl(
    _$CustomerImpl _value,
    $Res Function(_$CustomerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Customer
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
    Object? avatarUrl = freezed,
    Object? segment = null,
    Object? healthScore = null,
    Object? engagementScore = null,
    Object? retentionScore = null,
    Object? satisfactionScore = null,
    Object? revenueScore = null,
    Object? assignedTo = freezed,
    Object? assignedToName = freezed,
    Object? leadId = freezed,
    Object? totalInteractions = null,
    Object? totalRevenue = null,
    Object? tags = null,
    Object? preferences = freezed,
    Object? memory = freezed,
    Object? lastInteractionAt = freezed,
    Object? lastPurchaseAt = freezed,
    Object? churnedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CustomerImpl(
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
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        segment: null == segment
            ? _value.segment
            : segment // ignore: cast_nullable_to_non_nullable
                  as CustomerSegment,
        healthScore: null == healthScore
            ? _value.healthScore
            : healthScore // ignore: cast_nullable_to_non_nullable
                  as int,
        engagementScore: null == engagementScore
            ? _value.engagementScore
            : engagementScore // ignore: cast_nullable_to_non_nullable
                  as int,
        retentionScore: null == retentionScore
            ? _value.retentionScore
            : retentionScore // ignore: cast_nullable_to_non_nullable
                  as int,
        satisfactionScore: null == satisfactionScore
            ? _value.satisfactionScore
            : satisfactionScore // ignore: cast_nullable_to_non_nullable
                  as int,
        revenueScore: null == revenueScore
            ? _value.revenueScore
            : revenueScore // ignore: cast_nullable_to_non_nullable
                  as int,
        assignedTo: freezed == assignedTo
            ? _value.assignedTo
            : assignedTo // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedToName: freezed == assignedToName
            ? _value.assignedToName
            : assignedToName // ignore: cast_nullable_to_non_nullable
                  as String?,
        leadId: freezed == leadId
            ? _value.leadId
            : leadId // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalInteractions: null == totalInteractions
            ? _value.totalInteractions
            : totalInteractions // ignore: cast_nullable_to_non_nullable
                  as int,
        totalRevenue: null == totalRevenue
            ? _value.totalRevenue
            : totalRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        preferences: freezed == preferences
            ? _value._preferences
            : preferences // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        memory: freezed == memory
            ? _value._memory
            : memory // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        lastInteractionAt: freezed == lastInteractionAt
            ? _value.lastInteractionAt
            : lastInteractionAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastPurchaseAt: freezed == lastPurchaseAt
            ? _value.lastPurchaseAt
            : lastPurchaseAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        churnedAt: freezed == churnedAt
            ? _value.churnedAt
            : churnedAt // ignore: cast_nullable_to_non_nullable
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
class _$CustomerImpl implements _Customer {
  const _$CustomerImpl({
    required this.id,
    required this.orgId,
    required this.name,
    this.email,
    this.phone,
    this.company,
    this.jobTitle,
    this.avatarUrl,
    this.segment = CustomerSegment.newCustomer,
    this.healthScore = 0,
    this.engagementScore = 0,
    this.retentionScore = 0,
    this.satisfactionScore = 0,
    this.revenueScore = 0,
    this.assignedTo,
    this.assignedToName,
    this.leadId,
    this.totalInteractions = 0,
    this.totalRevenue = 0.0,
    final List<String> tags = const [],
    final Map<String, dynamic>? preferences,
    final Map<String, dynamic>? memory,
    this.lastInteractionAt,
    this.lastPurchaseAt,
    this.churnedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : _tags = tags,
       _preferences = preferences,
       _memory = memory;

  factory _$CustomerImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomerImplFromJson(json);

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
  final String? avatarUrl;
  @override
  @JsonKey()
  final CustomerSegment segment;
  @override
  @JsonKey()
  final int healthScore;
  @override
  @JsonKey()
  final int engagementScore;
  @override
  @JsonKey()
  final int retentionScore;
  @override
  @JsonKey()
  final int satisfactionScore;
  @override
  @JsonKey()
  final int revenueScore;
  @override
  final String? assignedTo;
  @override
  final String? assignedToName;
  @override
  final String? leadId;
  @override
  @JsonKey()
  final int totalInteractions;
  @override
  @JsonKey()
  final double totalRevenue;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final Map<String, dynamic>? _preferences;
  @override
  Map<String, dynamic>? get preferences {
    final value = _preferences;
    if (value == null) return null;
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _memory;
  @override
  Map<String, dynamic>? get memory {
    final value = _memory;
    if (value == null) return null;
    if (_memory is EqualUnmodifiableMapView) return _memory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? lastInteractionAt;
  @override
  final DateTime? lastPurchaseAt;
  @override
  final DateTime? churnedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Customer(id: $id, orgId: $orgId, name: $name, email: $email, phone: $phone, company: $company, jobTitle: $jobTitle, avatarUrl: $avatarUrl, segment: $segment, healthScore: $healthScore, engagementScore: $engagementScore, retentionScore: $retentionScore, satisfactionScore: $satisfactionScore, revenueScore: $revenueScore, assignedTo: $assignedTo, assignedToName: $assignedToName, leadId: $leadId, totalInteractions: $totalInteractions, totalRevenue: $totalRevenue, tags: $tags, preferences: $preferences, memory: $memory, lastInteractionAt: $lastInteractionAt, lastPurchaseAt: $lastPurchaseAt, churnedAt: $churnedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orgId, orgId) || other.orgId == orgId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.jobTitle, jobTitle) ||
                other.jobTitle == jobTitle) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.segment, segment) || other.segment == segment) &&
            (identical(other.healthScore, healthScore) ||
                other.healthScore == healthScore) &&
            (identical(other.engagementScore, engagementScore) ||
                other.engagementScore == engagementScore) &&
            (identical(other.retentionScore, retentionScore) ||
                other.retentionScore == retentionScore) &&
            (identical(other.satisfactionScore, satisfactionScore) ||
                other.satisfactionScore == satisfactionScore) &&
            (identical(other.revenueScore, revenueScore) ||
                other.revenueScore == revenueScore) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.assignedToName, assignedToName) ||
                other.assignedToName == assignedToName) &&
            (identical(other.leadId, leadId) || other.leadId == leadId) &&
            (identical(other.totalInteractions, totalInteractions) ||
                other.totalInteractions == totalInteractions) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._preferences,
              _preferences,
            ) &&
            const DeepCollectionEquality().equals(other._memory, _memory) &&
            (identical(other.lastInteractionAt, lastInteractionAt) ||
                other.lastInteractionAt == lastInteractionAt) &&
            (identical(other.lastPurchaseAt, lastPurchaseAt) ||
                other.lastPurchaseAt == lastPurchaseAt) &&
            (identical(other.churnedAt, churnedAt) ||
                other.churnedAt == churnedAt) &&
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
    avatarUrl,
    segment,
    healthScore,
    engagementScore,
    retentionScore,
    satisfactionScore,
    revenueScore,
    assignedTo,
    assignedToName,
    leadId,
    totalInteractions,
    totalRevenue,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_preferences),
    const DeepCollectionEquality().hash(_memory),
    lastInteractionAt,
    lastPurchaseAt,
    churnedAt,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      __$$CustomerImplCopyWithImpl<_$CustomerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomerImplToJson(this);
  }
}

abstract class _Customer implements Customer {
  const factory _Customer({
    required final String id,
    required final String orgId,
    required final String name,
    final String? email,
    final String? phone,
    final String? company,
    final String? jobTitle,
    final String? avatarUrl,
    final CustomerSegment segment,
    final int healthScore,
    final int engagementScore,
    final int retentionScore,
    final int satisfactionScore,
    final int revenueScore,
    final String? assignedTo,
    final String? assignedToName,
    final String? leadId,
    final int totalInteractions,
    final double totalRevenue,
    final List<String> tags,
    final Map<String, dynamic>? preferences,
    final Map<String, dynamic>? memory,
    final DateTime? lastInteractionAt,
    final DateTime? lastPurchaseAt,
    final DateTime? churnedAt,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CustomerImpl;

  factory _Customer.fromJson(Map<String, dynamic> json) =
      _$CustomerImpl.fromJson;

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
  String? get avatarUrl;
  @override
  CustomerSegment get segment;
  @override
  int get healthScore;
  @override
  int get engagementScore;
  @override
  int get retentionScore;
  @override
  int get satisfactionScore;
  @override
  int get revenueScore;
  @override
  String? get assignedTo;
  @override
  String? get assignedToName;
  @override
  String? get leadId;
  @override
  int get totalInteractions;
  @override
  double get totalRevenue;
  @override
  List<String> get tags;
  @override
  Map<String, dynamic>? get preferences;
  @override
  Map<String, dynamic>? get memory;
  @override
  DateTime? get lastInteractionAt;
  @override
  DateTime? get lastPurchaseAt;
  @override
  DateTime? get churnedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Customer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerImplCopyWith<_$CustomerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
