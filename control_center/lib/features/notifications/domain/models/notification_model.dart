import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType { inApp, email, whatsapp, push }

enum NotificationCategory { general, lead, conversation, task, system }

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String orgId,
    required String userId,
    required String title,
    required String message,
    @Default(NotificationType.inApp) NotificationType notificationType,
    @Default(NotificationCategory.general) NotificationCategory category,
    @Default(false) bool isRead,
    String? actionUrl,
    String? metadataJson,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
