import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';

import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../../domain/models/call_log.dart';
import '../../domain/models/conversation_analytics.dart';
import '../../domain/repositories/conversation_repository_interface.dart';
import '../datasources/conversation_remote_datasource.dart';

class ConversationRepository implements ConversationRepositoryInterface {
  final ConversationRemoteDatasource _datasource;

  ConversationRepository(this._datasource);

  @override
  Future<ApiResult<List<Conversation>>> getConversations({
    String? platform,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _datasource.getConversations(
        platform: platform,
        status: status,
        search: search,
        page: page,
        limit: limit,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
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
  Future<ApiResult<Conversation>> getConversation(String id) async {
    try {
      final response = await _datasource.getConversation(id);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(Conversation.fromJson(response.data));
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
  Future<ApiResult<List<Message>>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _datasource.getMessages(
        conversationId,
        page: page,
        limit: limit,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
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
  Future<ApiResult<List<CallLog>>> getCallLogs({
    String? agentId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _datasource.getCallLogs(
        agentId: agentId,
        page: page,
        limit: limit,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => CallLog.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(items);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load call logs',
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
  Future<ApiResult<CallLog>> getCallLog(String id) async {
    try {
      final response = await _datasource.getCallLog(id);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(CallLog.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load call log',
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
  Future<ApiResult<List<Conversation>>> searchConversations(
    String query, {
    String? platform,
    String? status,
  }) async {
    try {
      final response = await _datasource.searchConversations(
        query,
        platform: platform,
        status: status,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
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
  Future<ApiResult<ConversationAnalytics>> getAnalytics() async {
    try {
      final response = await _datasource.getAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(ConversationAnalytics.fromJson(response.data));
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
  Future<ApiResult<String>> exportCsv({
    String? platform,
    String? status,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _datasource.exportCsv(
        platform: platform,
        status: status,
        from: from,
        to: to,
      );
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
}
