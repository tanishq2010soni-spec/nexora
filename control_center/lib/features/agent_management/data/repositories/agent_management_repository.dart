import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/agent_capability.dart';
import '../../domain/models/agent_configuration.dart';
import '../../domain/models/agent_health.dart';
import '../../domain/models/agent_heartbeat.dart';
import '../../domain/models/agent_log.dart';
import '../../domain/models/agent_version.dart';
import '../../domain/repositories/agent_management_repository_interface.dart';
import '../datasources/agent_management_remote_datasource.dart';

class AgentManagementRepository implements AgentManagementRepositoryInterface {
  final AgentManagementRemoteDatasource _datasource;

  AgentManagementRepository(this._datasource);

  @override
  Future<ApiResult<List<AgentVersion>>> getVersions(String agentId) async {
    try {
      final response = await _datasource.getVersions(agentId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch agent versions',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final versions = data
          .map((json) => AgentVersion.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiSuccess(versions);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AgentVersion>> getVersion(String id) async {
    try {
      final response = await _datasource.getVersion(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch agent version',
            statusCode: response.statusCode,
          ),
        );
      }
      final version = AgentVersion.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(version);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AgentVersion>> createVersion(AgentVersion version) async {
    try {
      final response = await _datasource.createVersion(version);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to create agent version',
            statusCode: response.statusCode,
          ),
        );
      }
      final created = AgentVersion.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(created);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<AgentCapability>>> getCapabilities(
    String agentId,
  ) async {
    try {
      final response = await _datasource.getCapabilities(agentId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch agent capabilities',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final capabilities = data
          .map(
            (json) => AgentCapability.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return ApiSuccess(capabilities);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AgentCapability>> toggleCapability(
    String id,
    bool enabled,
  ) async {
    try {
      final response = await _datasource.toggleCapability(id, enabled);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to toggle agent capability',
            statusCode: response.statusCode,
          ),
        );
      }
      final capability = AgentCapability.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(capability);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AgentHealth>> getHealth(String agentId) async {
    try {
      final response = await _datasource.getHealth(agentId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch agent health',
            statusCode: response.statusCode,
          ),
        );
      }
      final health = AgentHealth.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(health);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<AgentConfiguration>>> getConfigurations(
    String agentId,
  ) async {
    try {
      final response = await _datasource.getConfigurations(agentId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch agent configurations',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final configs = data
          .map(
            (json) =>
                AgentConfiguration.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return ApiSuccess(configs);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AgentConfiguration>> updateConfiguration(
    String agentId,
    AgentConfiguration config,
  ) async {
    try {
      final response = await _datasource.updateConfiguration(agentId, config);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to update agent configuration',
            statusCode: response.statusCode,
          ),
        );
      }
      final updated = AgentConfiguration.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(updated);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<AgentLog>>> getLogs(
    String agentId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _datasource.getLogs(agentId, page: page, limit: limit);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch agent logs',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final logs = data
          .map((json) => AgentLog.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiSuccess(logs);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<AgentHeartbeat>>> getHeartbeats(String agentId) async {
    try {
      final response = await _datasource.getHeartbeats(agentId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch agent heartbeats',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final heartbeats = data
          .map((json) => AgentHeartbeat.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiSuccess(heartbeats);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AgentHeartbeat>> recordHeartbeat(
    AgentHeartbeat heartbeat,
  ) async {
    try {
      final response = await _datasource.recordHeartbeat(heartbeat);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to record agent heartbeat',
            statusCode: response.statusCode,
          ),
        );
      }
      final recorded = AgentHeartbeat.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(recorded);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
