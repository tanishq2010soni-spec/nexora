import '../../../../core/network/api_result.dart';
import '../models/inbox_conversation.dart';
import '../models/inbox_message.dart';
import '../models/inbox_analytics.dart';
import '../models/customer_side_panel.dart';

abstract class InboxRepositoryInterface {
  Future<ApiResult<List<InboxConversation>>> getConversations({
    String? channel,
    String? status,
    String? assignedTo,
    int limit = 20,
    int offset = 0,
  });

  Future<ApiResult<InboxConversation>> getConversation(String id);

  Future<
    ApiResult<
      ({
        InboxConversation conversation,
        List<InboxMessage> messages,
        CustomerSidePanel? customer,
      })
    >
  >
  getConversationDetail(String id);

  Future<ApiResult<List<InboxMessage>>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  });

  Future<ApiResult<InboxMessage>> sendMessage({
    required String conversationId,
    required String content,
    required String senderType,
  });

  Future<ApiResult<InboxConversation>> updateConversation(
    String id, {
    String? status,
    String? assignedTo,
    String? takeoverMode,
  });

  Future<ApiResult<InboxConversation>> toggleTakeover(String id);

  Future<ApiResult<void>> markRead(String conversationId);

  Future<ApiResult<void>> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  });

  Future<ApiResult<List<InboxConversation>>> searchConversations(String query);

  Future<ApiResult<InboxAnalytics>> getAnalytics();

  Future<ApiResult<String>> exportCsv();

  Future<ApiResult<void>> deleteConversation(String id);
}
