import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../data/datasources/billing_remote_datasource.dart';
import '../data/repositories/billing_repository.dart';
import '../domain/models/plan.dart';
import '../domain/models/subscription.dart';
import '../domain/models/invoice.dart';
import '../domain/repositories/billing_repository_interface.dart';

final billingDatasourceProvider = Provider<BillingRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final billingRepositoryProvider = Provider<BillingRepositoryInterface>((ref) {
  return BillingRepository(ref.read(billingDatasourceProvider));
});

final planListProvider = FutureProvider<List<Plan>>((ref) async {
  final result = await ref.read(billingRepositoryProvider).getPlans();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final subscriptionProvider = FutureProvider<Subscription>((ref) async {
  final result = await ref.read(billingRepositoryProvider).getSubscription();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final invoiceListProvider = FutureProvider<List<Invoice>>((ref) async {
  final result = await ref.read(billingRepositoryProvider).getInvoices();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final usageProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final result = await ref.read(billingRepositoryProvider).getUsage();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final createSubscriptionProvider = FutureProvider.family<Subscription, String>((
  ref,
  planId,
) async {
  final result = await ref
      .read(billingRepositoryProvider)
      .createSubscription(planId);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final cancelSubscriptionProvider = FutureProvider<void>((ref) async {
  final result = await ref.read(billingRepositoryProvider).cancelSubscription();
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
