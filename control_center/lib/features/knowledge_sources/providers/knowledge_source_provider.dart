import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../data/datasources/knowledge_source_remote_datasource.dart';
import '../domain/models/knowledge_source.dart';
import '../domain/repositories/knowledge_source_repository_interface.dart';

final knowledgeSourceDatasourceProvider =
    Provider<KnowledgeSourceRemoteDatasource>((ref) {
  throw UnimplementedError(
    'knowledgeSourceDatasourceProvider must be overridden at the app level',
  );
});

final knowledgeSourceRepositoryProvider =
    Provider<KnowledgeSourceRepositoryInterface>((ref) {
  throw UnimplementedError(
    'knowledgeSourceRepositoryProvider must be overridden at the app level',
  );
});

final knowledgeSourcesProvider = FutureProvider.autoDispose
    .family<ApiResult<List<KnowledgeSource>>, String>((ref, kbId) async {
  final repository = ref.watch(knowledgeSourceRepositoryProvider);
  return repository.getSources(kbId);
});

final knowledgeSourceDetailProvider =
    FutureProvider.autoDispose.family<ApiResult<KnowledgeSource>, String>(
      (ref, id) async {
        final repository = ref.watch(knowledgeSourceRepositoryProvider);
        return repository.getSource(id);
      },
    );
