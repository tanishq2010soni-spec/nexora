import '../../../../core/network/api_result.dart';
import '../models/notification_model.dart';

abstract class NotificationsRepositoryInterface {
  Future<ApiResult<List<AppNotification>>> getNotifications({
    bool? unreadOnly,
    int page = 1,
    int limit = 20,
  });

  Future<ApiResult<int>> getUnreadCount();

  Future<ApiResult<AppNotification>> markAsRead(String id);

  Future<ApiResult<void>> markAllAsRead();
}
