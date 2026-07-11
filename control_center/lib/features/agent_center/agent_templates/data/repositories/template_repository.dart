import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/network/api_result.dart';
import '../../domain/models/agent_template.dart';
import '../../domain/repositories/template_repository_interface.dart';
import '../datasources/template_remote_datasource.dart';

class TemplateRepository implements TemplateRepositoryInterface {
  final TemplateRemoteDatasource _datasource;

  TemplateRepository(this._datasource);

  @override
  Future<ApiResult<List<AgentTemplate>>> getTemplates() async {
    try {
      final response = await _datasource.getTemplates();
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List<dynamic>? ?? []);
        final templates = list
            .map((e) => AgentTemplate.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(templates);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load templates',
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
  Future<ApiResult<AgentTemplate>> getTemplate(String id) async {
    try {
      final response = await _datasource.getTemplate(id);
      if (response.isSuccess && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data['data'] as Map<String, dynamic>? ?? {});
        return ApiSuccess(AgentTemplate.fromJson(data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load template',
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
  Future<ApiResult<AgentTemplate>> createTemplate(
    AgentTemplate template,
  ) async {
    try {
      final response = await _datasource.createTemplate(template.toJson());
      if (response.isSuccess && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data['data'] as Map<String, dynamic>? ?? {});
        return ApiSuccess(AgentTemplate.fromJson(data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to create template',
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
  Future<ApiResult<AgentTemplate>> updateTemplate(
    String id,
    AgentTemplate template,
  ) async {
    try {
      final response = await _datasource.updateTemplate(id, template.toJson());
      if (response.isSuccess && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data['data'] as Map<String, dynamic>? ?? {});
        return ApiSuccess(AgentTemplate.fromJson(data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to update template',
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
  Future<ApiResult<void>> deleteTemplate(String id) async {
    try {
      final response = await _datasource.deleteTemplate(id);
      if (response.isSuccess) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to delete template',
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
  Future<ApiResult<AgentTemplate>> duplicateTemplate(
    String id,
    String newName,
  ) async {
    try {
      final response = await _datasource.duplicateTemplate(id, newName);
      if (response.isSuccess && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data['data'] as Map<String, dynamic>? ?? {});
        return ApiSuccess(AgentTemplate.fromJson(data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to duplicate template',
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
