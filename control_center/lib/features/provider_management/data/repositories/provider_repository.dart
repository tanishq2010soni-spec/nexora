import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/provider_model.dart';
import '../../domain/repositories/provider_repository_interface.dart';
import '../datasources/provider_remote_datasource.dart';

class ProviderRepository implements ProviderRepositoryInterface {
  final ProviderRemoteDatasource _datasource;

  ProviderRepository(this._datasource);

  @override
  Future<ApiResult<List<ProviderModel>>> getProviders() async {
    try {
      final response = await _datasource.getProviders();
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch providers',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final providers = data
          .map((json) => ProviderModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiSuccess(providers);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<ProviderModel>> getProvider(String id) async {
    try {
      final response = await _datasource.getProvider(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch provider',
            statusCode: response.statusCode,
          ),
        );
      }
      final provider = ProviderModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(provider);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<ProviderModel>> createProvider(ProviderModel provider) async {
    try {
      final response = await _datasource.createProvider(provider);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to create provider',
            statusCode: response.statusCode,
          ),
        );
      }
      final created = ProviderModel.fromJson(
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
  Future<ApiResult<ProviderModel>> updateProvider(
    String id,
    ProviderModel provider,
  ) async {
    try {
      final response = await _datasource.updateProvider(id, provider);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to update provider',
            statusCode: response.statusCode,
          ),
        );
      }
      final updated = ProviderModel.fromJson(
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
  Future<ApiResult<void>> deleteProvider(String id) async {
    try {
      final response = await _datasource.deleteProvider(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to delete provider',
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
  Future<ApiResult<ProviderModel>> toggleProviderStatus(
    String id,
    bool isActive,
  ) async {
    try {
      final response = await _datasource.toggleProviderStatus(id, isActive);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to toggle provider status',
            statusCode: response.statusCode,
          ),
        );
      }
      final toggled = ProviderModel.fromJson(
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
  Future<ApiResult<ProviderModel>> checkHealth(String id) async {
    try {
      final response = await _datasource.checkHealth(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to check provider health',
            statusCode: response.statusCode,
          ),
        );
      }
      final health = ProviderModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(health);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
