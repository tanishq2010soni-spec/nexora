import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../data/datasources/notifications_remote_datasource.dart';
import '../data/repositories/notifications_repository.dart';
import '../domain/models/notification_model.dart';
import '../domain/repositories/notifications_repository_interface.dart';

final notificationsDatasourceProvider = Provider<NotificationsRemoteDatasource>(
  (ref) {
    throw UnimplementedError('Must be overridden');
  },
);

final notificationsRepositoryProvider =
    Provider<NotificationsRepositoryInterface>((ref) {
      return NotificationsRepository(ref.read(notificationsDatasourceProvider));
    });

final notificationsListProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final result = await ref
      .read(notificationsRepositoryProvider)
      .getNotifications();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final unreadNotificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final result = await ref
      .read(notificationsRepositoryProvider)
      .getNotifications(unreadOnly: true);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final result = await ref
      .read(notificationsRepositoryProvider)
      .getUnreadCount();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final markNotificationReadProvider =
    FutureProvider.family<AppNotification, String>((ref, id) async {
      final result = await ref
          .read(notificationsRepositoryProvider)
          .markAsRead(id);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final markAllReadProvider = FutureProvider<void>((ref) async {
  final result = await ref
      .read(notificationsRepositoryProvider)
      .markAllAsRead();
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
