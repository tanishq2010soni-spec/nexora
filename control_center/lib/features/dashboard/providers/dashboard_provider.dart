import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_result.dart';
import '../data/datasources/dashboard_remote_datasource.dart';
import '../data/repositories/dashboard_repository.dart';
import '../domain/models/dashboard_stats.dart';
import '../domain/repositories/dashboard_repository_interface.dart';

final dashboardDatasourceProvider = Provider<DashboardRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final dashboardRepositoryProvider = Provider<DashboardRepositoryInterface>((
  ref,
) {
  return DashboardRepository(ref.read(dashboardDatasourceProvider));
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final result = await ref.read(dashboardRepositoryProvider).getStats();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
