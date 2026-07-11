import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';

import '../../domain/models/inbox_conversation.dart';
import '../../domain/models/inbox_message.dart';
import '../../domain/models/inbox_analytics.dart';
import '../../domain/models/customer_side_panel.dart';
import '../../domain/repositories/inbox_repository_interface.dart';
import '../datasources/inbox_remote_datasource.dart';

class InboxRepository implements InboxRepositoryInterface {
  final InboxRemoteDatasource _datasource;

  InboxRepository(this._datasource);

  @override
  Future<ApiResult<List<InboxConversation>>> getConversations({
    String? channel,
    String? status,
    String? assignedTo,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _datasource.getConversations(
        channel: channel,
        status: status,
        assignedTo: assignedTo,
        limit: limit,
        offset: offset,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => InboxConversation.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(items);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load conversations',
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
  Future<ApiResult<InboxConversation>> getConversation(String id) async {
    try {
      final response = await _datasource.getConversation(id);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(InboxConversation.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load conversation',
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
  Future<
    ApiResult<
      ({
        InboxConversation conversation,
        List<InboxMessage> messages,
        CustomerSidePanel? customer,
      })
    >
  >
  getConversationDetail(String id) async {
    try {
      final response = await _datasource.getConversationDetail(id);
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final conversation = InboxConversation.fromJson(
          data['conversation'] as Map<String, dynamic>,
        );
        final messagesList = (data['messages'] as List? ?? [])
            .map((e) => InboxMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        final customerData = data['customer'] as Map<String, dynamic>?;
        final customer = customerData != null
            ? CustomerSidePanel.fromJson(customerData)
            : null;
        return ApiSuccess((
          conversation: conversation,
          messages: messagesList,
          customer: customer,
        ));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load conversation detail',
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
  Future<ApiResult<List<InboxMessage>>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _datasource.getMessages(
        conversationId,
        limit: limit,
        offset: offset,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => InboxMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(items);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load messages',
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
  Future<ApiResult<InboxMessage>> sendMessage({
    required String conversationId,
    required String content,
    required String senderType,
  }) async {
    try {
      final response = await _datasource.sendMessage(
        conversationId: conversationId,
        content: content,
        senderType: senderType,
      );
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(InboxMessage.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to send message',
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
  Future<ApiResult<InboxConversation>> updateConversation(
    String id, {
    String? status,
    String? assignedTo,
    String? takeoverMode,
  }) async {
    try {
      final response = await _datasource.updateConversation(
        id,
        status: status,
        assignedTo: assignedTo,
        takeoverMode: takeoverMode,
      );
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(InboxConversation.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to update conversation',
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
  Future<ApiResult<InboxConversation>> toggleTakeover(String id) async {
    try {
      final response = await _datasource.toggleTakeover(id);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(InboxConversation.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to toggle takeover',
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
  Future<ApiResult<void>> markRead(String conversationId) async {
    try {
      final response = await _datasource.markRead(conversationId);
      if (response.isSuccess) {
        return ApiSuccess(null);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to mark as read',
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
  Future<ApiResult<void>> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    try {
      final response = await _datasource.sendTypingIndicator(
        conversationId: conversationId,
        isTyping: isTyping,
      );
      if (response.isSuccess) {
        return ApiSuccess(null);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to send typing indicator',
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
  Future<ApiResult<List<InboxConversation>>> searchConversations(
    String query,
  ) async {
    try {
      final response = await _datasource.searchConversations(query);
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => InboxConversation.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(items);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to search conversations',
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
  Future<ApiResult<InboxAnalytics>> getAnalytics() async {
    try {
      final response = await _datasource.getAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(InboxAnalytics.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load analytics',
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
  Future<ApiResult<String>> exportCsv() async {
    try {
      final response = await _datasource.exportCsv();
      if (response.isSuccess && response.data != null) {
        final data = response.data;
        final csvUrl = data is String ? data : data['url'] as String? ?? '';
        return ApiSuccess(csvUrl);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to export CSV',
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
  Future<ApiResult<void>> deleteConversation(String id) async {
    try {
      final response = await _datasource.deleteConversation(id);
      if (response.isSuccess) {
        return ApiSuccess(null);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to delete conversation',
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
