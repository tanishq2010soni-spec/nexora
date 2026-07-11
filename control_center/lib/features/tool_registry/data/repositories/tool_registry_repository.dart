import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/tool_category.dart';
import '../../domain/models/tool_definition.dart';
import '../../domain/repositories/tool_registry_repository_interface.dart';
import '../datasources/tool_registry_remote_datasource.dart';

class ToolRegistryRepository implements ToolRegistryRepositoryInterface {
  final ToolRegistryRemoteDatasource _datasource;

  ToolRegistryRepository(this._datasource);

  @override
  Future<ApiResult<List<ToolDefinition>>> getTools() async {
    try {
      final response = await _datasource.getTools();
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch tools',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final tools = data
          .map((json) => ToolDefinition.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiSuccess(tools);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<ToolDefinition>> getTool(String id) async {
    try {
      final response = await _datasource.getTool(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch tool',
            statusCode: response.statusCode,
          ),
        );
      }
      final tool = ToolDefinition.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(tool);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<ToolDefinition>> createTool(ToolDefinition tool) async {
    try {
      final response = await _datasource.createTool(tool);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to create tool',
            statusCode: response.statusCode,
          ),
        );
      }
      final created = ToolDefinition.fromJson(
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
  Future<ApiResult<ToolDefinition>> updateTool(
    String id,
    ToolDefinition tool,
  ) async {
    try {
      final response = await _datasource.updateTool(id, tool);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to update tool',
            statusCode: response.statusCode,
          ),
        );
      }
      final updated = ToolDefinition.fromJson(
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
  Future<ApiResult<void>> deleteTool(String id) async {
    try {
      final response = await _datasource.deleteTool(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to delete tool',
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
  Future<ApiResult<ToolDefinition>> toggleToolStatus(
    String id,
    bool isEnabled,
  ) async {
    try {
      final response = await _datasource.toggleToolStatus(id, isEnabled);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to toggle tool status',
            statusCode: response.statusCode,
          ),
        );
      }
      final toggled = ToolDefinition.fromJson(
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
  Future<ApiResult<List<ToolCategory>>> getCategories() async {
    try {
      final response = await _datasource.getCategories();
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch tool categories',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final categories = data
          .map((json) => ToolCategory.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiSuccess(categories);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ToolDefinition>>> getToolsByCategory(
    String category,
  ) async {
    try {
      final response = await _datasource.getToolsByCategory(category);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch tools by category',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final tools = data
          .map((json) => ToolDefinition.fromJson(json as Map<String, dynamic>))
          .toList();
      return ApiSuccess(tools);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
