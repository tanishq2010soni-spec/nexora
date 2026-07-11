import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/model_registry_entry.dart';
import '../../domain/repositories/model_registry_repository_interface.dart';
import '../datasources/model_registry_remote_datasource.dart';

class ModelRegistryRepository implements ModelRegistryRepositoryInterface {
  final ModelRegistryRemoteDatasource _datasource;

  ModelRegistryRepository(this._datasource);

  @override
  Future<ApiResult<List<ModelRegistryEntry>>> getModels() async {
    try {
      final response = await _datasource.getModels();
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch models',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final models = data
          .map(
            (json) => ModelRegistryEntry.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return ApiSuccess(models);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<ModelRegistryEntry>> getModel(String id) async {
    try {
      final response = await _datasource.getModel(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch model',
            statusCode: response.statusCode,
          ),
        );
      }
      final model = ModelRegistryEntry.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(model);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<ModelRegistryEntry>> registerModel(
    ModelRegistryEntry model,
  ) async {
    try {
      final response = await _datasource.registerModel(model);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to register model',
            statusCode: response.statusCode,
          ),
        );
      }
      final registered = ModelRegistryEntry.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(registered);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<ModelRegistryEntry>> updateModel(
    String id,
    ModelRegistryEntry model,
  ) async {
    try {
      final response = await _datasource.updateModel(id, model);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to update model',
            statusCode: response.statusCode,
          ),
        );
      }
      final updated = ModelRegistryEntry.fromJson(
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
  Future<ApiResult<void>> deleteModel(String id) async {
    try {
      final response = await _datasource.deleteModel(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to delete model',
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
  Future<ApiResult<ModelRegistryEntry>> toggleModelStatus(
    String id,
    bool isActive,
  ) async {
    try {
      final response = await _datasource.toggleModelStatus(id, isActive);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to toggle model status',
            statusCode: response.statusCode,
          ),
        );
      }
      final toggled = ModelRegistryEntry.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(toggled);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ModelRegistryEntry>>> getModelsByProvider(
    String providerId,
  ) async {
    try {
      final response = await _datasource.getModelsByProvider(providerId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch models by provider',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final models = data
          .map(
            (json) => ModelRegistryEntry.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return ApiSuccess(models);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
