import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../data/datasources/provider_remote_datasource.dart';
import '../domain/models/provider_model.dart';
import '../domain/repositories/provider_repository_interface.dart';

final providerDatasourceProvider = Provider<ProviderRemoteDatasource>((ref) {
  throw UnimplementedError(
    'providerDatasourceProvider must be overridden at the app level',
  );
});

final providerRepositoryProvider = Provider<ProviderRepositoryInterface>((ref) {
  throw UnimplementedError(
    'providerRepositoryProvider must be overridden at the app level',
  );
});

final providersProvider =
    FutureProvider.autoDispose<ApiResult<List<ProviderModel>>>((ref) async {
  final repository = ref.watch(providerRepositoryProvider);
  return repository.getProviders();
});

final providerDetailProvider =
    FutureProvider.autoDispose.family<ApiResult<ProviderModel>, String>(
      (ref, id) async {
        final repository = ref.watch(providerRepositoryProvider);
        return repository.getProvider(id);
      },
    );
