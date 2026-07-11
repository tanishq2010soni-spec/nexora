import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/executive_summary.dart';
import '../../domain/repositories/analytics_repository_interface.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepository implements AnalyticsRepositoryInterface {
  final AnalyticsRemoteDatasource _datasource;

  AnalyticsRepository(this._datasource);

  @override
  Future<ApiResult<ExecutiveSummary>> getExecutiveDashboard() async {
    try {
      final response = await _datasource.getExecutiveDashboard();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(ExecutiveSummary.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load dashboard',
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
  Future<ApiResult<Map<String, dynamic>>> getRevenueAnalytics() async {
    try {
      final response = await _datasource.getRevenueAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(Map<String, dynamic>.from(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed',
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
  Future<ApiResult<Map<String, dynamic>>> getLeadAnalytics() async {
    try {
      final response = await _datasource.getLeadAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(Map<String, dynamic>.from(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed',
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
  Future<ApiResult<Map<String, dynamic>>> getCustomerAnalytics() async {
    try {
      final response = await _datasource.getCustomerAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(Map<String, dynamic>.from(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed',
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
  Future<ApiResult<Map<String, dynamic>>> getConversationAnalytics() async {
    try {
      final response = await _datasource.getConversationAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(Map<String, dynamic>.from(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed',
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
  Future<ApiResult<Map<String, dynamic>>> getCallAnalytics() async {
    try {
      final response = await _datasource.getCallAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(Map<String, dynamic>.from(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed',
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
  Future<ApiResult<Map<String, dynamic>>> getAgentAnalytics() async {
    try {
      final response = await _datasource.getAgentAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(Map<String, dynamic>.from(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed',
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
  Future<ApiResult<Map<String, dynamic>>> getAiPerformance() async {
    try {
      final response = await _datasource.getAiPerformance();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(Map<String, dynamic>.from(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed',
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
  Future<ApiResult<Map<String, dynamic>>> getInboxAnalytics() async {
    try {
      final response = await _datasource.getInboxAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(Map<String, dynamic>.from(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed',
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
