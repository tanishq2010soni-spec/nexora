import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';

import '../data/datasources/conversation_remote_datasource.dart';
import '../data/repositories/conversation_repository.dart';
import '../domain/models/conversation.dart';
import '../domain/models/message.dart';
import '../domain/models/call_log.dart';
import '../domain/models/conversation_analytics.dart';
import '../domain/repositories/conversation_repository_interface.dart';

final conversationDatasourceProvider = Provider<ConversationRemoteDatasource>((
  ref,
) {
  throw UnimplementedError('Must be overridden');
});

final conversationRepositoryProvider =
    Provider<ConversationRepositoryInterface>((ref) {
      return ConversationRepository(ref.read(conversationDatasourceProvider));
    });

final conversationListProvider = FutureProvider<List<Conversation>>((
  ref,
) async {
  final result = await ref
      .read(conversationRepositoryProvider)
      .getConversations();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final conversationDetailProvider = FutureProvider.family<Conversation, String>((
  ref,
  id,
) async {
  final result = await ref
      .read(conversationRepositoryProvider)
      .getConversation(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final conversationMessagesProvider =
    FutureProvider.family<List<Message>, String>((ref, conversationId) async {
      final result = await ref
          .read(conversationRepositoryProvider)
          .getMessages(conversationId);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final callLogListProvider = FutureProvider<List<CallLog>>((ref) async {
  final result = await ref.read(conversationRepositoryProvider).getCallLogs();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final callLogDetailProvider = FutureProvider.family<CallLog, String>((
  ref,
  id,
) async {
  final result = await ref.read(conversationRepositoryProvider).getCallLog(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final conversationSearchProvider =
    FutureProvider.family<
      List<Conversation>,
      ({String query, String? platform, String? status})
    >((ref, params) async {
      final result = await ref
          .read(conversationRepositoryProvider)
          .searchConversations(
            params.query,
            platform: params.platform,
            status: params.status,
          );
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final conversationAnalyticsProvider = FutureProvider<ConversationAnalytics>((
  ref,
) async {
  final result = await ref.read(conversationRepositoryProvider).getAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final exportCsvProvider =
    FutureProvider.family<String, ({String? platform, String? status})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(conversationRepositoryProvider)
          .exportCsv(platform: params.platform, status: params.status);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });
