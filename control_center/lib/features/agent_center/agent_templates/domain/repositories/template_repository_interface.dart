import '../../../../../../core/network/api_result.dart';
import '../models/agent_template.dart';

abstract class TemplateRepositoryInterface {
  Future<ApiResult<List<AgentTemplate>>> getTemplates();
  Future<ApiResult<AgentTemplate>> getTemplate(String id);
  Future<ApiResult<AgentTemplate>> createTemplate(AgentTemplate template);
  Future<ApiResult<AgentTemplate>> updateTemplate(
    String id,
    AgentTemplate template,
  );
  Future<ApiResult<void>> deleteTemplate(String id);
  Future<ApiResult<AgentTemplate>> duplicateTemplate(String id, String newName);
}
