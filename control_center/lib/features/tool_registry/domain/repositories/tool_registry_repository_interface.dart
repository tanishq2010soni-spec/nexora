import '../../../../core/network/api_result.dart';
import '../models/tool_category.dart';
import '../models/tool_definition.dart';

abstract class ToolRegistryRepositoryInterface {
  Future<ApiResult<List<ToolDefinition>>> getTools();
  Future<ApiResult<ToolDefinition>> getTool(String id);
  Future<ApiResult<ToolDefinition>> createTool(ToolDefinition tool);
  Future<ApiResult<ToolDefinition>> updateTool(
    String id,
    ToolDefinition tool,
  );
  Future<ApiResult<void>> deleteTool(String id);
  Future<ApiResult<ToolDefinition>> toggleToolStatus(
    String id,
    bool isEnabled,
  );
  Future<ApiResult<List<ToolCategory>>> getCategories();
  Future<ApiResult<List<ToolDefinition>>> getToolsByCategory(String category);
}
