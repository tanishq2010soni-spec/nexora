// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  notificationType:
      $enumDecodeNullable(
        _$NotificationTypeEnumMap,
        json['notificationType'],
      ) ??
      NotificationType.inApp,
  category:
      $enumDecodeNullable(_$NotificationCategoryEnumMap, json['category']) ??
      NotificationCategory.general,
  isRead: json['isRead'] as bool? ?? false,
  actionUrl: json['actionUrl'] as String?,
  metadataJson: json['metadataJson'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orgId': instance.orgId,
  'userId': instance.userId,
  'title': instance.title,
  'message': instance.message,
  'notificationType': _$NotificationTypeEnumMap[instance.notificationType]!,
  'category': _$NotificationCategoryEnumMap[instance.category]!,
  'isRead': instance.isRead,
  'actionUrl': instance.actionUrl,
  'metadataJson': instance.metadataJson,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$NotificationTypeEnumMap = {
  NotificationType.inApp: 'inApp',
  NotificationType.email: 'email',
  NotificationType.whatsapp: 'whatsapp',
  NotificationType.push: 'push',
};

const _$NotificationCategoryEnumMap = {
  NotificationCategory.general: 'general',
  NotificationCategory.lead: 'lead',
  NotificationCategory.conversation: 'conversation',
  NotificationCategory.task: 'task',
  NotificationCategory.system: 'system',
};
