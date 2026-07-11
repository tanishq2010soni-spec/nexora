import '../../../../core/network/api_result.dart';
import '../models/call.dart';
import '../models/call_queue.dart';
import '../models/call_analytics.dart';

abstract class CallsRepositoryInterface {
  Future<ApiResult<List<VoiceCall>>> getCalls({
    String? direction,
    String? status,
    String? agentId,
    int limit = 20,
    int offset = 0,
  });
  Future<ApiResult<VoiceCall>> getCall(String id);
  Future<ApiResult<VoiceCall>> createCall({
    required String agentId,
    required String direction,
    required String callerNumber,
    required String calleeNumber,
  });
  Future<ApiResult<VoiceCall>> updateCall(
    String id,
    Map<String, dynamic> updates,
  );
  Future<ApiResult<CallAnalytics>> getAnalytics();
  Future<ApiResult<List<CallQueue>>> getQueues();
  Future<ApiResult<CallQueue>> createQueue({
    required String name,
    String? description,
    String? routingStrategy,
    int? maxWaitTime,
  });
  Future<ApiResult<void>> deleteQueue(String id);
}
