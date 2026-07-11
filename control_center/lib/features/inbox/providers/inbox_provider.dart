import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';

import '../data/datasources/inbox_remote_datasource.dart';
import '../data/repositories/inbox_repository.dart';
import '../domain/models/inbox_conversation.dart';
import '../domain/models/inbox_message.dart';
import '../domain/models/inbox_analytics.dart';
import '../domain/models/customer_side_panel.dart';
import '../domain/repositories/inbox_repository_interface.dart';

final inboxDatasourceProvider = Provider<InboxRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final inboxRepositoryProvider = Provider<InboxRepositoryInterface>((ref) {
  return InboxRepository(ref.read(inboxDatasourceProvider));
});

final inboxConversationListProvider = FutureProvider<List<InboxConversation>>((
  ref,
) async {
  final result = await ref.read(inboxRepositoryProvider).getConversations();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final inboxConversationDetailProvider =
    FutureProvider.family<InboxConversation, String>((ref, id) async {
      final result = await ref
          .read(inboxRepositoryProvider)
          .getConversation(id);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final inboxConversationFullDetailProvider =
    FutureProvider.family<
      ({
        InboxConversation conversation,
        List<InboxMessage> messages,
        CustomerSidePanel? customer,
      }),
      String
    >((ref, id) async {
      final result = await ref
          .read(inboxRepositoryProvider)
          .getConversationDetail(id);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final inboxMessagesProvider = FutureProvider.family<List<InboxMessage>, String>(
  (ref, conversationId) async {
    final result = await ref
        .read(inboxRepositoryProvider)
        .getMessages(conversationId);
    return switch (result) {
      ApiSuccess(data: final data) => data,
      ApiError(exception: final exception) => throw exception,
      _ => throw UnknownException('Unknown error'),
    };
  },
);

final inboxSearchProvider =
    FutureProvider.family<List<InboxConversation>, String>((ref, query) async {
      final result = await ref
          .read(inboxRepositoryProvider)
          .searchConversations(query);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final inboxAnalyticsProvider = FutureProvider<InboxAnalytics>((ref) async {
  final result = await ref.read(inboxRepositoryProvider).getAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
