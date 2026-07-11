import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/network/api_result.dart';
import '../../domain/models/agent_settings.dart';
import '../../domain/models/available_model.dart';
import '../../domain/repositories/settings_repository_interface.dart';
import '../datasources/settings_remote_datasource.dart';

class AgentCenterSettingsRepository implements SettingsRepositoryInterface {
  final AgentCenterSettingsRemoteDatasource _datasource;

  AgentCenterSettingsRepository(this._datasource);

  @override
  Future<ApiResult<AgentSettings>> getAgentSettings(String agentId) async {
    try {
      final response = await _datasource.getAgentSettings(agentId);
      return ApiSuccess(response.data as AgentSettings);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AgentSettings>> updateAgentSettings(
    String agentId,
    AgentSettings settings,
  ) async {
    try {
      final response = await _datasource.updateAgentSettings(agentId, settings);
      return ApiSuccess(response.data as AgentSettings);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<AvailableModel>>> getAvailableModels() async {
    try {
      final response = await _datasource.getAvailableModels();
      return ApiSuccess(response.data as List<AvailableModel>);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
