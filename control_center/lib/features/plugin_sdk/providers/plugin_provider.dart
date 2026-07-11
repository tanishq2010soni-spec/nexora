import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../data/datasources/plugin_remote_datasource.dart';
import '../domain/models/plugin_model.dart';
import '../domain/repositories/plugin_repository_interface.dart';

final pluginDatasourceProvider = Provider<PluginRemoteDatasource>((ref) {
  throw UnimplementedError(
    'pluginDatasourceProvider must be overridden at the app level',
  );
});

final pluginRepositoryProvider = Provider<PluginRepositoryInterface>((ref) {
  throw UnimplementedError(
    'pluginRepositoryProvider must be overridden at the app level',
  );
});

final pluginsProvider =
    FutureProvider.autoDispose<ApiResult<List<PluginModel>>>((ref) async {
  final repository = ref.watch(pluginRepositoryProvider);
  return repository.getPlugins();
});

final pluginDetailProvider =
    FutureProvider.autoDispose.family<ApiResult<PluginModel>, String>(
      (ref, id) async {
        final repository = ref.watch(pluginRepositoryProvider);
        return repository.getPlugin(id);
      },
    );
