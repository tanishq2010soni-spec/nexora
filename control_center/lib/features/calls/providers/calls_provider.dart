import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';

import '../data/datasources/calls_remote_datasource.dart';
import '../data/repositories/calls_repository.dart';
import '../domain/models/call.dart';
import '../domain/models/call_queue.dart';
import '../domain/models/call_analytics.dart';
import '../domain/repositories/calls_repository_interface.dart';

final callsDatasourceProvider = Provider<CallsRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final callsRepositoryProvider = Provider<CallsRepositoryInterface>((ref) {
  return CallsRepository(ref.read(callsDatasourceProvider));
});

final callListProvider = FutureProvider<List<VoiceCall>>((ref) async {
  final result = await ref.read(callsRepositoryProvider).getCalls();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final callDetailProvider = FutureProvider.family<VoiceCall, String>((
  ref,
  id,
) async {
  final result = await ref.read(callsRepositoryProvider).getCall(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final callAnalyticsProvider = FutureProvider<CallAnalytics>((ref) async {
  final result = await ref.read(callsRepositoryProvider).getAnalytics();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final callQueueListProvider = FutureProvider<List<CallQueue>>((ref) async {
  final result = await ref.read(callsRepositoryProvider).getQueues();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
