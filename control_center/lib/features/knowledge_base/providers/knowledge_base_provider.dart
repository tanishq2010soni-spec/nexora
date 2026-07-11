import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_result.dart';

import '../data/datasources/knowledge_base_remote_datasource.dart';
import '../data/repositories/knowledge_base_repository.dart';
import '../domain/models/knowledge_base.dart';
import '../domain/models/document.dart';
import '../domain/models/kb_statistics.dart';
import '../domain/repositories/knowledge_base_repository_interface.dart';

final kbDatasourceProvider = Provider<KnowledgeBaseRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final kbRepositoryProvider = Provider<KnowledgeBaseRepositoryInterface>((ref) {
  return KnowledgeBaseRepository(ref.read(kbDatasourceProvider));
});

final kbListProvider = FutureProvider<List<KnowledgeBase>>((ref) async {
  final result = await ref.read(kbRepositoryProvider).getKnowledgeBases();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final kbDetailProvider = FutureProvider.family<KnowledgeBase, String>((
  ref,
  id,
) async {
  final result = await ref.read(kbRepositoryProvider).getKnowledgeBase(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final kbDocumentsProvider = FutureProvider.family<List<KbDocument>, String>((
  ref,
  kbId,
) async {
  final result = await ref.read(kbRepositoryProvider).getDocuments(kbId);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final kbStatisticsProvider = FutureProvider<KbStatistics>((ref) async {
  final result = await ref.read(kbRepositoryProvider).getStatistics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final kbSearchProvider =
    FutureProvider.family<List<KbDocument>, ({String kbId, String query})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(kbRepositoryProvider)
          .searchDocuments(params.kbId, params.query);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final createKnowledgeBaseProvider =
    FutureProvider.family<KnowledgeBase, ({String name, String? description})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(kbRepositoryProvider)
          .createKnowledgeBase(params.name, params.description);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final deleteKnowledgeBaseProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final result = await ref.read(kbRepositoryProvider).deleteKnowledgeBase(id);
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final uploadDocumentProvider =
    FutureProvider.family<
      KbDocument,
      ({String knowledgeBaseId, List<int> fileBytes, String filename})
    >((ref, params) async {
      final result = await ref
          .read(kbRepositoryProvider)
          .uploadDocument(
            params.knowledgeBaseId,
            params.fileBytes,
            params.filename,
          );
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final deleteDocumentProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final result = await ref.read(kbRepositoryProvider).deleteDocument(id);
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final reindexDocumentProvider = FutureProvider.family<KbDocument, String>((
  ref,
  id,
) async {
  final result = await ref.read(kbRepositoryProvider).reindexDocument(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
