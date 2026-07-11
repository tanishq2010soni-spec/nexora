import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';

import '../../domain/models/knowledge_base.dart';
import '../../domain/models/document.dart';
import '../../domain/models/kb_statistics.dart';
import '../../domain/repositories/knowledge_base_repository_interface.dart';
import '../datasources/knowledge_base_remote_datasource.dart';

class KnowledgeBaseRepository implements KnowledgeBaseRepositoryInterface {
  final KnowledgeBaseRemoteDatasource _datasource;

  KnowledgeBaseRepository(this._datasource);

  @override
  Future<ApiResult<List<KnowledgeBase>>> getKnowledgeBases() async {
    try {
      final response = await _datasource.getKnowledgeBases();
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => KnowledgeBase.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(items);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load knowledge bases',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<KnowledgeBase>> getKnowledgeBase(String id) async {
    try {
      final response = await _datasource.getKnowledgeBase(id);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(KnowledgeBase.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load knowledge base',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<KnowledgeBase>> createKnowledgeBase(
    String name,
    String? description,
  ) async {
    try {
      final data = <String, dynamic>{'name': name};
      if (description != null) data['description'] = description;
      final response = await _datasource.createKnowledgeBase(data);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(KnowledgeBase.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to create knowledge base',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<KnowledgeBase>> updateKnowledgeBase(
    String id,
    String name,
    String? description,
  ) async {
    try {
      final data = <String, dynamic>{'name': name};
      if (description != null) data['description'] = description;
      final response = await _datasource.updateKnowledgeBase(id, data);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(KnowledgeBase.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to update knowledge base',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteKnowledgeBase(String id) async {
    try {
      final response = await _datasource.deleteKnowledgeBase(id);
      if (response.isSuccess) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to delete knowledge base',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<KbDocument>>> getDocuments(
    String knowledgeBaseId,
  ) async {
    try {
      final response = await _datasource.getDocuments(knowledgeBaseId);
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => KbDocument.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(items);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load documents',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<KbDocument>> getDocument(String id) async {
    try {
      final response = await _datasource.getDocument(id);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(KbDocument.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load document',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<KbDocument>> uploadDocument(
    String knowledgeBaseId,
    List<int> fileBytes,
    String filename,
  ) async {
    try {
      final response = await _datasource.uploadDocument(
        knowledgeBaseId,
        fileBytes,
        filename,
      );
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(KbDocument.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to upload document',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteDocument(String id) async {
    try {
      final response = await _datasource.deleteDocument(id);
      if (response.isSuccess) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to delete document',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<KbDocument>> reindexDocument(String id) async {
    try {
      final response = await _datasource.reindexDocument(id);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(KbDocument.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to reindex document',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<KbDocument>>> searchDocuments(
    String knowledgeBaseId,
    String query,
  ) async {
    try {
      final response = await _datasource.searchDocuments(
        knowledgeBaseId,
        query,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => KbDocument.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(items);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to search documents',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<KbStatistics>> getStatistics() async {
    try {
      final response = await _datasource.getStatistics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(KbStatistics.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load statistics',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
