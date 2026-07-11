import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/notification_model.dart';
import '../../domain/repositories/notifications_repository_interface.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepository implements NotificationsRepositoryInterface {
  final NotificationsRemoteDatasource _datasource;

  const NotificationsRepository(this._datasource);

  @override
  Future<ApiResult<List<AppNotification>>> getNotifications({
    bool? unreadOnly,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _datasource.getNotifications(
        unreadOnly: unreadOnly,
        page: page,
        limit: limit,
      );
      if (response.isSuccess && response.data != null) {
        final list = response.data! as List;
        final notifications = list
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(notifications);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch notifications'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<int>> getUnreadCount() async {
    try {
      final response = await _datasource.getUnreadCount();
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final count = data is Map<String, dynamic>
            ? (data['count'] as num?)?.toInt() ?? 0
            : (data as num?)?.toInt() ?? 0;
        return ApiSuccess(count);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch unread count'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AppNotification>> markAsRead(String id) async {
    try {
      final response = await _datasource.markAsRead(id);
      if (response.isSuccess && response.data != null) {
        final notification = AppNotification.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(notification);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to mark notification as read',
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> markAllAsRead() async {
    try {
      final response = await _datasource.markAllAsRead();
      if (response.isSuccess) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to mark all as read'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
