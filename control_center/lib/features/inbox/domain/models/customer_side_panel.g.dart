// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_side_panel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerSidePanelImpl _$$CustomerSidePanelImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerSidePanelImpl(
  customerId: json['customerId'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  segment: json['segment'] as String?,
  notes: json['notes'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  totalConversations: (json['totalConversations'] as num?)?.toInt() ?? 0,
  totalMessages: (json['totalMessages'] as num?)?.toInt() ?? 0,
  firstSeenAt: json['firstSeenAt'] == null
      ? null
      : DateTime.parse(json['firstSeenAt'] as String),
  lastSeenAt: json['lastSeenAt'] == null
      ? null
      : DateTime.parse(json['lastSeenAt'] as String),
);

Map<String, dynamic> _$$CustomerSidePanelImplToJson(
  _$CustomerSidePanelImpl instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'segment': instance.segment,
  'notes': instance.notes,
  'tags': instance.tags,
  'totalConversations': instance.totalConversations,
  'totalMessages': instance.totalMessages,
  'firstSeenAt': instance.firstSeenAt?.toIso8601String(),
  'lastSeenAt': instance.lastSeenAt?.toIso8601String(),
};
