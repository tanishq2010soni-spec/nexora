import '../../../../core/network/api_result.dart';
import '../models/model_registry_entry.dart';

abstract class ModelRegistryRepositoryInterface {
  Future<ApiResult<List<ModelRegistryEntry>>> getModels();
  Future<ApiResult<ModelRegistryEntry>> getModel(String id);
  Future<ApiResult<ModelRegistryEntry>> registerModel(
    ModelRegistryEntry model,
  );
  Future<ApiResult<ModelRegistryEntry>> updateModel(
    String id,
    ModelRegistryEntry model,
  );
  Future<ApiResult<void>> deleteModel(String id);
  Future<ApiResult<ModelRegistryEntry>> toggleModelStatus(
    String id,
    bool isActive,
  );
  Future<ApiResult<List<ModelRegistryEntry>>> getModelsByProvider(
    String providerId,
  );
}
