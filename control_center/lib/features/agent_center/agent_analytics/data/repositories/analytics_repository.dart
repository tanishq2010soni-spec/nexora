import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/network/api_result.dart';
import '../../domain/models/agent_analytics.dart';
import '../../domain/repositories/analytics_repository_interface.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepository implements AnalyticsRepositoryInterface {
  final AnalyticsRemoteDatasource _datasource;

  AnalyticsRepository(this._datasource);

  @override
  Future<ApiResult<List<AgentAnalytics>>> getAgentAnalytics() async {
    try {
      final response = await _datasource.getAgentAnalytics();
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List<dynamic>? ?? []);
        final analytics = list
            .map((e) => AgentAnalytics.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(analytics);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load analytics',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AgentAnalytics>> getAgentAnalyticsById(
    String agentId,
  ) async {
    try {
      final response = await _datasource.getAgentAnalyticsById(agentId);
      if (response.isSuccess && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data['data'] as Map<String, dynamic>? ?? {});
        return ApiSuccess(AgentAnalytics.fromJson(data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load agent analytics',
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
