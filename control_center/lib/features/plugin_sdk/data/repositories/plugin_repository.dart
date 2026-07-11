import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/plugin_model.dart';
import '../../domain/repositories/plugin_repository_interface.dart';
import '../datasources/plugin_remote_datasource.dart';

class PluginRepository implements PluginRepositoryInterface {
  final PluginRemoteDatasource _datasource;

  PluginRepository(this._datasource);

  @override
  Future<ApiResult<List<PluginModel>>> getPlugins() async {
    try {
      final response = await _datasource.getPlugins();
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch plugins',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final plugins = data
          .map((json) => PluginModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiSuccess(plugins);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<PluginModel>> getPlugin(String id) async {
    try {
      final response = await _datasource.getPlugin(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch plugin',
            statusCode: response.statusCode,
          ),
        );
      }
      final plugin = PluginModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(plugin);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<PluginModel>> installPlugin(PluginModel plugin) async {
    try {
      final response = await _datasource.installPlugin(plugin);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to install plugin',
            statusCode: response.statusCode,
          ),
        );
      }
      final installed = PluginModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(installed);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<PluginModel>> updatePlugin(
    String id,
    PluginModel plugin,
  ) async {
    try {
      final response = await _datasource.updatePlugin(id, plugin);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to update plugin',
            statusCode: response.statusCode,
          ),
        );
      }
      final updated = PluginModel.fromJson(
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
  Future<ApiResult<void>> uninstallPlugin(String id) async {
    try {
      final response = await _datasource.uninstallPlugin(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to uninstall plugin',
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
  Future<ApiResult<PluginModel>> togglePluginStatus(
    String id,
    bool isEnabled,
  ) async {
    try {
      final response = await _datasource.togglePluginStatus(id, isEnabled);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to toggle plugin status',
            statusCode: response.statusCode,
          ),
        );
      }
      final toggled = PluginModel.fromJson(
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
