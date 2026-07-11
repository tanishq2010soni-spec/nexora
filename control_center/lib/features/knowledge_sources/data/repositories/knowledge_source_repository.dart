import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/knowledge_source.dart';
import '../../domain/repositories/knowledge_source_repository_interface.dart';
import '../datasources/knowledge_source_remote_datasource.dart';

class KnowledgeSourceRepository implements KnowledgeSourceRepositoryInterface {
  final KnowledgeSourceRemoteDatasource _datasource;

  KnowledgeSourceRepository(this._datasource);

  @override
  Future<ApiResult<List<KnowledgeSource>>> getSources(String kbId) async {
    try {
      final response = await _datasource.getSources(kbId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch knowledge sources',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final sources = data
          .map(
            (json) => KnowledgeSource.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return ApiSuccess(sources);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<KnowledgeSource>> getSource(String id) async {
    try {
      final response = await _datasource.getSource(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch knowledge source',
            statusCode: response.statusCode,
          ),
        );
      }
      final source = KnowledgeSource.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(source);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<KnowledgeSource>> createSource(
    KnowledgeSource source,
  ) async {
    try {
      final response = await _datasource.createSource(source);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to create knowledge source',
            statusCode: response.statusCode,
          ),
        );
      }
      final created = KnowledgeSource.fromJson(
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
  Future<ApiResult<KnowledgeSource>> updateSource(
    String id,
    KnowledgeSource source,
  ) async {
    try {
      final response = await _datasource.updateSource(id, source);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to update knowledge source',
            statusCode: response.statusCode,
          ),
        );
      }
      final updated = KnowledgeSource.fromJson(
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
  Future<ApiResult<void>> deleteSource(String id) async {
    try {
      final response = await _datasource.deleteSource(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to delete knowledge source',
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
  Future<ApiResult<KnowledgeSource>> triggerIndexing(String id) async {
    try {
      final response = await _datasource.triggerIndexing(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to trigger indexing',
            statusCode: response.statusCode,
          ),
        );
      }
      final source = KnowledgeSource.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(source);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
