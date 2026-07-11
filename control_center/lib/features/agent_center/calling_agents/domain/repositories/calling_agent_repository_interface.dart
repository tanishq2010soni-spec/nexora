import '../../../../../core/network/api_result.dart';
import '../models/calling_agent.dart';

abstract class CallingAgentRepositoryInterface {
  Future<ApiResult<List<CallingAgent>>> getAgents();
  Future<ApiResult<CallingAgent>> getAgent(String id);
  Future<ApiResult<CallingAgent>> createAgent(CallingAgent agent);
  Future<ApiResult<CallingAgent>> updateAgent(String id, CallingAgent agent);
  Future<ApiResult<void>> deleteAgent(String id);
  Future<ApiResult<CallingAgent>> toggleAgentStatus(String id, bool enabled);
}
