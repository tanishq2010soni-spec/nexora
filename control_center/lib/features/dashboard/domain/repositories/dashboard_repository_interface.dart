import '../../../../core/network/api_result.dart';
import '../models/dashboard_stats.dart';

abstract class DashboardRepositoryInterface {
  Future<ApiResult<DashboardStats>> getStats();
}
