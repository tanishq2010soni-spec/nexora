import '../../../../core/network/api_result.dart';
import '../models/provider_model.dart';

abstract class ProviderRepositoryInterface {
  Future<ApiResult<List<ProviderModel>>> getProviders();
  Future<ApiResult<ProviderModel>> getProvider(String id);
  Future<ApiResult<ProviderModel>> createProvider(ProviderModel provider);
  Future<ApiResult<ProviderModel>> updateProvider(
    String id,
    ProviderModel provider,
  );
  Future<ApiResult<void>> deleteProvider(String id);
  Future<ApiResult<ProviderModel>> toggleProviderStatus(
    String id,
    bool isActive,
  );
  Future<ApiResult<ProviderModel>> checkHealth(String id);
}
