import '../../../../../core/network/api_result.dart';

import '../models/whatsapp_agent.dart';

abstract class WhatsAppAgentRepositoryInterface {
  Future<ApiResult<List<WhatsAppAgent>>> getAgents();
  Future<ApiResult<WhatsAppAgent>> getAgent(String id);
  Future<ApiResult<WhatsAppAgent>> createAgent(WhatsAppAgent agent);
  Future<ApiResult<WhatsAppAgent>> updateAgent(String id, WhatsAppAgent agent);
  Future<ApiResult<void>> deleteAgent(String id);
  Future<ApiResult<WhatsAppAgent>> toggleAgentStatus(String id, bool enabled);
}
