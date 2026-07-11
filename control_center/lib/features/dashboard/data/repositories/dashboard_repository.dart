import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository_interface.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepository implements DashboardRepositoryInterface {
  final DashboardRemoteDatasource _datasource;

  DashboardRepository(this._datasource);

  @override
  Future<ApiResult<DashboardStats>> getStats() async {
    try {
      final response = await _datasource.getStats();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(DashboardStats.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load stats',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
