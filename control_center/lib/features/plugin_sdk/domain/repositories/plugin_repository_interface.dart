import '../../../../core/network/api_result.dart';
import '../models/plugin_model.dart';

abstract class PluginRepositoryInterface {
  Future<ApiResult<List<PluginModel>>> getPlugins();
  Future<ApiResult<PluginModel>> getPlugin(String id);
  Future<ApiResult<PluginModel>> installPlugin(PluginModel plugin);
  Future<ApiResult<PluginModel>> updatePlugin(
    String id,
    PluginModel plugin,
  );
  Future<ApiResult<void>> uninstallPlugin(String id);
  Future<ApiResult<PluginModel>> togglePluginStatus(
    String id,
    bool isEnabled,
  );
}
