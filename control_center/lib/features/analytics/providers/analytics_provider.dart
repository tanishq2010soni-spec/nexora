import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';

import '../data/datasources/analytics_remote_datasource.dart';
import '../data/repositories/analytics_repository.dart';
import '../domain/models/executive_summary.dart';
import '../domain/repositories/analytics_repository_interface.dart';

final analyticsDatasourceProvider = Provider<AnalyticsRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final analyticsRepositoryProvider = Provider<AnalyticsRepositoryInterface>((
  ref,
) {
  return AnalyticsRepository(ref.read(analyticsDatasourceProvider));
});

final executiveDashboardProvider = FutureProvider<ExecutiveSummary>((
  ref,
) async {
  final result = await ref
      .read(analyticsRepositoryProvider)
      .getExecutiveDashboard();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final revenueAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final result = await ref
      .read(analyticsRepositoryProvider)
      .getRevenueAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final leadAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.read(analyticsRepositoryProvider).getLeadAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final customerAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final result = await ref
      .read(analyticsRepositoryProvider)
      .getCustomerAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final conversationAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final result = await ref
      .read(analyticsRepositoryProvider)
      .getConversationAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final callAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.read(analyticsRepositoryProvider).getCallAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final agentAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final result = await ref
      .read(analyticsRepositoryProvider)
      .getAgentAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final aiPerformanceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.read(analyticsRepositoryProvider).getAiPerformance();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final inboxAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final result = await ref
      .read(analyticsRepositoryProvider)
      .getInboxAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
