import '../../../../../../core/network/api_result.dart';
import '../models/agent_analytics.dart';

abstract class AnalyticsRepositoryInterface {
  Future<ApiResult<List<AgentAnalytics>>> getAgentAnalytics();
  Future<ApiResult<AgentAnalytics>> getAgentAnalyticsById(String agentId);
}
