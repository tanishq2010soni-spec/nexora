import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/network/api_result.dart';

import '../../domain/models/whatsapp_agent.dart';
import '../../domain/repositories/whatsapp_agent_repository_interface.dart';
import '../datasources/whatsapp_agent_remote_datasource.dart';
import '../../../shared/models/agent.dart';
import '../../../shared/models/whatsapp_config.dart';

class WhatsAppAgentRepository implements WhatsAppAgentRepositoryInterface {
  final WhatsAppAgentRemoteDatasource _datasource;

  WhatsAppAgentRepository(this._datasource);

  WhatsAppAgent _mapResponse(Map<String, dynamic> json) {
    return WhatsAppAgent(
      id: json['id']?.toString() ?? '',
      orgId: json['org_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      systemPrompt: json['system_prompt']?.toString() ?? '',
      llmModel: json['llm_model']?.toString() ?? 'llama3',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      status: AgentStatus.active,
      config: const WhatsAppConfig(),
      knowledgeBaseIds: null,
      lastActiveAt: null,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> _toCreatePayload(WhatsAppAgent agent) {
    return {
      'name': agent.name,
      'platform_type': 'whatsapp',
      'system_prompt': agent.systemPrompt,
      'llm_model': agent.llmModel,
      'temperature': agent.temperature,
    };
  }

  Map<String, dynamic> _toUpdatePayload(WhatsAppAgent agent) {
    final payload = <String, dynamic>{};
    payload['name'] = agent.name;
    payload['platform_type'] = 'whatsapp';
    payload['system_prompt'] = agent.systemPrompt;
    payload['llm_model'] = agent.llmModel;
    payload['temperature'] = agent.temperature;
    return payload;
  }

  @override
  Future<ApiResult<List<WhatsAppAgent>>> getAgents() async {
    try {
      final response = await _datasource.getAgents();
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final agents = list
            .map((e) => _mapResponse(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(agents);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load agents',
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
  Future<ApiResult<WhatsAppAgent>> getAgent(String id) async {
    try {
      final response = await _datasource.getAgent(id);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(_mapResponse(response.data as Map<String, dynamic>));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load agent',
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
  Future<ApiResult<WhatsAppAgent>> createAgent(WhatsAppAgent agent) async {
    try {
      final response = await _datasource.createAgent(_toCreatePayload(agent));
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(_mapResponse(response.data as Map<String, dynamic>));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to create agent',
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
  Future<ApiResult<WhatsAppAgent>> updateAgent(
    String id,
    WhatsAppAgent agent,
  ) async {
    try {
      final response = await _datasource.updateAgent(
        id,
        _toUpdatePayload(agent),
      );
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(_mapResponse(response.data as Map<String, dynamic>));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to update agent',
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
  Future<ApiResult<void>> deleteAgent(String id) async {
    try {
      final response = await _datasource.deleteAgent(id);
      if (response.isSuccess) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to delete agent',
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
  Future<ApiResult<WhatsAppAgent>> toggleAgentStatus(
    String id,
    bool enabled,
  ) async {
    try {
      final response = await _datasource.toggleAgentStatus(id, enabled);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(_mapResponse(response.data as Map<String, dynamic>));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to toggle agent status',
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
