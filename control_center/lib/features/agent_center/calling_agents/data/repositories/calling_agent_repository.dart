import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/network/api_result.dart';
import '../../domain/models/calling_agent.dart';
import '../../domain/repositories/calling_agent_repository_interface.dart';
import '../datasources/calling_agent_remote_datasource.dart';

class CallingAgentRepository implements CallingAgentRepositoryInterface {
  final CallingAgentRemoteDatasource _datasource;

  CallingAgentRepository(this._datasource);

  @override
  Future<ApiResult<List<CallingAgent>>> getAgents() async {
    try {
      final response = await _datasource.getAgents();
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch calling agents',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final agents = data
          .map((json) => CallingAgent.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiSuccess(agents);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<CallingAgent>> getAgent(String id) async {
    try {
      final response = await _datasource.getAgent(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch calling agent',
            statusCode: response.statusCode,
          ),
        );
      }
      final agent = CallingAgent.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(agent);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<CallingAgent>> createAgent(CallingAgent agent) async {
    try {
      final response = await _datasource.createAgent(agent);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to create calling agent',
            statusCode: response.statusCode,
          ),
        );
      }
      final created = CallingAgent.fromJson(
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
  Future<ApiResult<CallingAgent>> updateAgent(
    String id,
    CallingAgent agent,
  ) async {
    try {
      final response = await _datasource.updateAgent(id, agent);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to update calling agent',
            statusCode: response.statusCode,
          ),
        );
      }
      final updated = CallingAgent.fromJson(
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
  Future<ApiResult<void>> deleteAgent(String id) async {
    try {
      final response = await _datasource.deleteAgent(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to delete calling agent',
            statusCode: response.statusCode,
          ),
        );
      }
      return const ApiSuccess(null);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<CallingAgent>> toggleAgentStatus(
    String id,
    bool enabled,
  ) async {
    try {
      final response = await _datasource.toggleAgentStatus(id, enabled);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to toggle agent status',
            statusCode: response.statusCode,
          ),
        );
      }
      final toggled = CallingAgent.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(toggled);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
