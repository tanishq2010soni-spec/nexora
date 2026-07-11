import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../data/datasources/tool_registry_remote_datasource.dart';
import '../domain/models/tool_category.dart';
import '../domain/models/tool_definition.dart';
import '../domain/repositories/tool_registry_repository_interface.dart';

final toolRegistryDatasourceProvider =
    Provider<ToolRegistryRemoteDatasource>((ref) {
  throw UnimplementedError(
    'toolRegistryDatasourceProvider must be overridden at the app level',
  );
});

final toolRegistryRepositoryProvider =
    Provider<ToolRegistryRepositoryInterface>((ref) {
  throw UnimplementedError(
    'toolRegistryRepositoryProvider must be overridden at the app level',
  );
});

final toolRegistryToolsProvider =
    FutureProvider.autoDispose<ApiResult<List<ToolDefinition>>>((ref) async {
  final repository = ref.watch(toolRegistryRepositoryProvider);
  return repository.getTools();
});

final toolRegistryDetailProvider =
    FutureProvider.autoDispose.family<ApiResult<ToolDefinition>, String>(
      (ref, id) async {
        final repository = ref.watch(toolRegistryRepositoryProvider);
        return repository.getTool(id);
      },
    );

final toolCategoriesProvider =
    FutureProvider.autoDispose<ApiResult<List<ToolCategory>>>((ref) async {
  final repository = ref.watch(toolRegistryRepositoryProvider);
  return repository.getCategories();
});
