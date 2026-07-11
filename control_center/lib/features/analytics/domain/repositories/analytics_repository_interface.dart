import '../../../../core/network/api_result.dart';
import '../models/executive_summary.dart';

abstract class AnalyticsRepositoryInterface {
  Future<ApiResult<ExecutiveSummary>> getExecutiveDashboard();
  Future<ApiResult<Map<String, dynamic>>> getRevenueAnalytics();
  Future<ApiResult<Map<String, dynamic>>> getLeadAnalytics();
  Future<ApiResult<Map<String, dynamic>>> getCustomerAnalytics();
  Future<ApiResult<Map<String, dynamic>>> getConversationAnalytics();
  Future<ApiResult<Map<String, dynamic>>> getCallAnalytics();
  Future<ApiResult<Map<String, dynamic>>> getAgentAnalytics();
  Future<ApiResult<Map<String, dynamic>>> getAiPerformance();
  Future<ApiResult<Map<String, dynamic>>> getInboxAnalytics();
}
