import '../../../../core/network/api_result.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/call_log.dart';
import '../models/conversation_analytics.dart';

abstract class ConversationRepositoryInterface {
  Future<ApiResult<List<Conversation>>> getConversations({
    String? platform,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  });
  Future<ApiResult<Conversation>> getConversation(String id);
  Future<ApiResult<List<Message>>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  });
  Future<ApiResult<List<CallLog>>> getCallLogs({
    String? agentId,
    int page = 1,
    int limit = 20,
  });
  Future<ApiResult<CallLog>> getCallLog(String id);
  Future<ApiResult<List<Conversation>>> searchConversations(
    String query, {
    String? platform,
    String? status,
  });
  Future<ApiResult<ConversationAnalytics>> getAnalytics();
  Future<ApiResult<String>> exportCsv({
    String? platform,
    String? status,
    DateTime? from,
    DateTime? to,
  });
}
