import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';

import '../../domain/models/call.dart';
import '../../domain/models/call_queue.dart';
import '../../domain/models/call_analytics.dart';
import '../../domain/repositories/calls_repository_interface.dart';
import '../datasources/calls_remote_datasource.dart';

class CallsRepository implements CallsRepositoryInterface {
  final CallsRemoteDatasource _datasource;

  CallsRepository(this._datasource);

  @override
  Future<ApiResult<List<VoiceCall>>> getCalls({
    String? direction,
    String? status,
    String? agentId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _datasource.getCalls(
        direction: direction,
        status: status,
        agentId: agentId,
        limit: limit,
        offset: offset,
      );
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => VoiceCall.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(items);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load calls',
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
  Future<ApiResult<VoiceCall>> getCall(String id) async {
    try {
      final response = await _datasource.getCall(id);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(VoiceCall.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load call',
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
  Future<ApiResult<VoiceCall>> createCall({
    required String agentId,
    required String direction,
    required String callerNumber,
    required String calleeNumber,
  }) async {
    try {
      final response = await _datasource.createCall(
        agentId: agentId,
        direction: direction,
        callerNumber: callerNumber,
        calleeNumber: calleeNumber,
      );
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(VoiceCall.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to create call',
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
  Future<ApiResult<VoiceCall>> updateCall(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _datasource.updateCall(id, updates);
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(VoiceCall.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to update call',
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
  Future<ApiResult<CallAnalytics>> getAnalytics() async {
    try {
      final response = await _datasource.getAnalytics();
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(CallAnalytics.fromJson(response.data));
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
  Future<ApiResult<List<CallQueue>>> getQueues() async {
    try {
      final response = await _datasource.getQueues();
      if (response.isSuccess && response.data != null) {
        final List<dynamic> list = response.data is List
            ? response.data as List
            : (response.data['data'] as List? ?? []);
        final items = list
            .map((e) => CallQueue.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(items);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to load queues',
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
  Future<ApiResult<CallQueue>> createQueue({
    required String name,
    String? description,
    String? routingStrategy,
    int? maxWaitTime,
  }) async {
    try {
      final response = await _datasource.createQueue(
        name: name,
        description: description,
        routingStrategy: routingStrategy,
        maxWaitTime: maxWaitTime,
      );
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(CallQueue.fromJson(response.data));
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to create queue',
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
  Future<ApiResult<void>> deleteQueue(String id) async {
    try {
      final response = await _datasource.deleteQueue(id);
      if (response.isSuccess) {
        return ApiSuccess(null);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Failed to delete queue',
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
