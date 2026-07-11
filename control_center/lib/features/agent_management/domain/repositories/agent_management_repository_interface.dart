import '../../../../core/network/api_result.dart';
import '../models/agent_capability.dart';
import '../models/agent_configuration.dart';
import '../models/agent_health.dart';
import '../models/agent_heartbeat.dart';
import '../models/agent_log.dart';
import '../models/agent_version.dart';

abstract class AgentManagementRepositoryInterface {
  Future<ApiResult<List<AgentVersion>>> getVersions(String agentId);
  Future<ApiResult<AgentVersion>> getVersion(String id);
  Future<ApiResult<AgentVersion>> createVersion(AgentVersion version);
  Future<ApiResult<List<AgentCapability>>> getCapabilities(String agentId);
  Future<ApiResult<AgentCapability>> toggleCapability(
    String id,
    bool enabled,
  );
  Future<ApiResult<AgentHealth>> getHealth(String agentId);
  Future<ApiResult<List<AgentConfiguration>>> getConfigurations(
    String agentId,
  );
  Future<ApiResult<AgentConfiguration>> updateConfiguration(
    String agentId,
    AgentConfiguration config,
  );
  Future<ApiResult<List<AgentLog>>> getLogs(
    String agentId, {
    int page,
    int limit,
  });
  Future<ApiResult<List<AgentHeartbeat>>> getHeartbeats(String agentId);
  Future<ApiResult<AgentHeartbeat>> recordHeartbeat(AgentHeartbeat heartbeat);
}
