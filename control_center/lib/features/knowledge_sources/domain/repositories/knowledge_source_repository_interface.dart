import '../../../../core/network/api_result.dart';
import '../models/knowledge_source.dart';

abstract class KnowledgeSourceRepositoryInterface {
  Future<ApiResult<List<KnowledgeSource>>> getSources(String kbId);
  Future<ApiResult<KnowledgeSource>> getSource(String id);
  Future<ApiResult<KnowledgeSource>> createSource(KnowledgeSource source);
  Future<ApiResult<KnowledgeSource>> updateSource(
    String id,
    KnowledgeSource source,
  );
  Future<ApiResult<void>> deleteSource(String id);
  Future<ApiResult<KnowledgeSource>> triggerIndexing(String id);
}
