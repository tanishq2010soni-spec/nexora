import '../../../../core/network/api_result.dart';
import '../models/knowledge_base.dart';
import '../models/document.dart';
import '../models/kb_statistics.dart';

abstract class KnowledgeBaseRepositoryInterface {
  Future<ApiResult<List<KnowledgeBase>>> getKnowledgeBases();
  Future<ApiResult<KnowledgeBase>> getKnowledgeBase(String id);
  Future<ApiResult<KnowledgeBase>> createKnowledgeBase(
    String name,
    String? description,
  );
  Future<ApiResult<KnowledgeBase>> updateKnowledgeBase(
    String id,
    String name,
    String? description,
  );
  Future<ApiResult<void>> deleteKnowledgeBase(String id);

  Future<ApiResult<List<KbDocument>>> getDocuments(String knowledgeBaseId);
  Future<ApiResult<KbDocument>> getDocument(String id);
  Future<ApiResult<KbDocument>> uploadDocument(
    String knowledgeBaseId,
    List<int> fileBytes,
    String filename,
  );
  Future<ApiResult<void>> deleteDocument(String id);
  Future<ApiResult<KbDocument>> reindexDocument(String id);

  Future<ApiResult<List<KbDocument>>> searchDocuments(
    String knowledgeBaseId,
    String query,
  );

  Future<ApiResult<KbStatistics>> getStatistics();
}
