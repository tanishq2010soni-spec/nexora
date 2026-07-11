import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../data/datasources/model_registry_remote_datasource.dart';
import '../domain/models/model_registry_entry.dart';
import '../domain/repositories/model_registry_repository_interface.dart';

final modelRegistryDatasourceProvider =
    Provider<ModelRegistryRemoteDatasource>((ref) {
  throw UnimplementedError(
    'modelRegistryDatasourceProvider must be overridden at the app level',
  );
});

final modelRegistryRepositoryProvider =
    Provider<ModelRegistryRepositoryInterface>((ref) {
  throw UnimplementedError(
    'modelRegistryRepositoryProvider must be overridden at the app level',
  );
});

final modelRegistryModelsProvider =
    FutureProvider.autoDispose<ApiResult<List<ModelRegistryEntry>>>((ref) async {
  final repository = ref.watch(modelRegistryRepositoryProvider);
  return repository.getModels();
});

final modelRegistryDetailProvider =
    FutureProvider.autoDispose.family<ApiResult<ModelRegistryEntry>, String>(
      (ref, id) async {
        final repository = ref.watch(modelRegistryRepositoryProvider);
        return repository.getModel(id);
      },
    );

final modelsByProviderProvider = FutureProvider.autoDispose
    .family<ApiResult<List<ModelRegistryEntry>>, String>(
      (ref, providerId) async {
        final repository = ref.watch(modelRegistryRepositoryProvider);
        return repository.getModelsByProvider(providerId);
      },
    );
