import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';

import '../data/datasources/whatsapp_agent_remote_datasource.dart';
import '../data/repositories/whatsapp_agent_repository.dart';
import '../domain/models/whatsapp_agent.dart';
import '../domain/repositories/whatsapp_agent_repository_interface.dart';

final whatsappAgentDatasourceProvider = Provider<WhatsAppAgentRemoteDatasource>(
  (ref) {
    throw UnimplementedError('Must be overridden');
  },
);

final whatsappAgentRepositoryProvider =
    Provider<WhatsAppAgentRepositoryInterface>((ref) {
      return WhatsAppAgentRepository(ref.read(whatsappAgentDatasourceProvider));
    });

final whatsappAgentListProvider = FutureProvider<List<WhatsAppAgent>>((
  ref,
) async {
  final result = await ref.read(whatsappAgentRepositoryProvider).getAgents();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final whatsappAgentDetailProvider =
    FutureProvider.family<WhatsAppAgent, String>((ref, id) async {
      final result = await ref
          .read(whatsappAgentRepositoryProvider)
          .getAgent(id);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final createWhatsAppAgentProvider =
    FutureProvider.family<WhatsAppAgent, WhatsAppAgent>((ref, agent) async {
      final result = await ref
          .read(whatsappAgentRepositoryProvider)
          .createAgent(agent);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final updateWhatsAppAgentProvider =
    FutureProvider.family<WhatsAppAgent, ({String id, WhatsAppAgent agent})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(whatsappAgentRepositoryProvider)
          .updateAgent(params.id, params.agent);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final deleteWhatsAppAgentProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final result = await ref
      .read(whatsappAgentRepositoryProvider)
      .deleteAgent(id);
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final toggleWhatsAppAgentStatusProvider =
    FutureProvider.family<WhatsAppAgent, ({String id, bool enabled})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(whatsappAgentRepositoryProvider)
          .toggleAgentStatus(params.id, params.enabled);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });
