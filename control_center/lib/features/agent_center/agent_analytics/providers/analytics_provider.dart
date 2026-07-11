import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/network/api_result.dart';
import '../data/datasources/analytics_remote_datasource.dart';
import '../data/repositories/analytics_repository.dart';
import '../domain/models/agent_analytics.dart';
import '../domain/repositories/analytics_repository_interface.dart';

final agentAnalyticsDatasourceProvider = Provider<AnalyticsRemoteDatasource>((
  ref,
) {
  throw UnimplementedError('Must be overridden');
});

final agentAnalyticsRepositoryProvider = Provider<AnalyticsRepositoryInterface>(
  (ref) {
    return AnalyticsRepository(ref.read(agentAnalyticsDatasourceProvider));
  },
);

final agentAnalyticsListProvider = FutureProvider<List<AgentAnalytics>>((
  ref,
) async {
  final result = await ref
      .read(agentAnalyticsRepositoryProvider)
      .getAgentAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final agentAnalyticsDetailProvider =
    FutureProvider.family<AgentAnalytics, String>((ref, agentId) async {
      final result = await ref
          .read(agentAnalyticsRepositoryProvider)
          .getAgentAnalyticsById(agentId);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });
