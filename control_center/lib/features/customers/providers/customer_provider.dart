import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../data/datasources/customer_remote_datasource.dart';
import '../data/repositories/customer_repository.dart';
import '../domain/models/customer.dart';
import '../domain/models/customer_activity.dart';
import '../domain/models/customer_analytics.dart';
import '../domain/models/customer_note.dart';
import '../domain/repositories/customer_repository_interface.dart';

final customerDatasourceProvider = Provider<CustomerRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final customerRepositoryProvider = Provider<CustomerRepositoryInterface>((ref) {
  return CustomerRepository(ref.read(customerDatasourceProvider));
});

final customerListProvider = FutureProvider<List<Customer>>((ref) async {
  final result = await ref.read(customerRepositoryProvider).getCustomers();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final customerDetailProvider = FutureProvider.family<Customer, String>((
  ref,
  id,
) async {
  final result = await ref.read(customerRepositoryProvider).getCustomer(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final customerActivitiesProvider =
    FutureProvider.family<List<CustomerActivity>, String>((
      ref,
      customerId,
    ) async {
      final result = await ref
          .read(customerRepositoryProvider)
          .getActivities(customerId);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final customerAnalyticsProvider = FutureProvider<CustomerAnalytics>((
  ref,
) async {
  final result = await ref.read(customerRepositoryProvider).getAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final customerSearchProvider =
    FutureProvider.family<List<Customer>, ({String query, String? segment})>((
      ref,
      params,
    ) async {
      CustomerSegment? segmentFilter;

      if (params.segment != null) {
        segmentFilter = CustomerSegment.values.firstWhere(
          (e) => e.name == params.segment,
          orElse: () => CustomerSegment.active,
        );
      }

      final result = await ref
          .read(customerRepositoryProvider)
          .searchCustomers(params.query, segment: segmentFilter);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final createCustomerProvider = FutureProvider.family<Customer, Customer>((
  ref,
  customer,
) async {
  final result = await ref
      .read(customerRepositoryProvider)
      .createCustomer(customer);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final updateCustomerProvider =
    FutureProvider.family<Customer, ({String id, Customer customer})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(customerRepositoryProvider)
          .updateCustomer(params.id, params.customer);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final deleteCustomerProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final result = await ref.read(customerRepositoryProvider).deleteCustomer(id);
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final updateCustomerSegmentProvider =
    FutureProvider.family<Customer, ({String id, String segment})>((
      ref,
      params,
    ) async {
      final segment = CustomerSegment.values.firstWhere(
        (e) => e.name == params.segment,
        orElse: () => CustomerSegment.active,
      );
      final result = await ref
          .read(customerRepositoryProvider)
          .updateSegment(params.id, segment);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final assignCustomerProvider =
    FutureProvider.family<Customer, ({String id, String userId})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(customerRepositoryProvider)
          .assignCustomer(params.id, params.userId);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final addCustomerNoteProvider =
    FutureProvider.family<CustomerNote, ({String customerId, String content})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(customerRepositoryProvider)
          .addNote(params.customerId, params.content);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final exportCustomersCsvProvider = FutureProvider<String>((ref) async {
  final result = await ref.read(customerRepositoryProvider).exportCsv();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
