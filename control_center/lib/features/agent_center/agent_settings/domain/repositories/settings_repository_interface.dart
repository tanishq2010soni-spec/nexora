import '../../../../../../core/network/api_result.dart';
import '../models/agent_settings.dart';
import '../models/available_model.dart';

abstract class SettingsRepositoryInterface {
  Future<ApiResult<AgentSettings>> getAgentSettings(String agentId);
  Future<ApiResult<AgentSettings>> updateAgentSettings(
    String agentId,
    AgentSettings settings,
  );
  Future<ApiResult<List<AvailableModel>>> getAvailableModels();
}
