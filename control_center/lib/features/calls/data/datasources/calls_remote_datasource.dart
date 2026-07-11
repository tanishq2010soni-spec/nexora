import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class CallsRemoteDatasource {
  final ApiClient _client;

  CallsRemoteDatasource(this._client);

  Future<ApiResponse> getCalls({
    String? direction,
    String? status,
    String? agentId,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit, 'offset': offset};
    if (direction != null) queryParams['direction'] = direction;
    if (status != null) queryParams['status'] = status;
    if (agentId != null) queryParams['agent_id'] = agentId;

    final response = await _client.get(
      '/calls/calls',
      queryParameters: queryParams,
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getCall(String id) async {
    final response = await _client.get('/calls/calls/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createCall({
    required String agentId,
    required String direction,
    required String callerNumber,
    required String calleeNumber,
  }) async {
    final response = await _client.post(
      '/calls/calls',
      data: {
        'agent_id': agentId,
        'direction': direction,
        'caller_number': callerNumber,
        'callee_number': calleeNumber,
      },
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateCall(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _client.patch('/calls/calls/$id', data: updates);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getAnalytics() async {
    final response = await _client.get('/calls/calls/analytics');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getQueues() async {
    final response = await _client.get('/calls/queues');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createQueue({
    required String name,
    String? description,
    String? routingStrategy,
    int? maxWaitTime,
  }) async {
    final data = <String, dynamic>{'name': name};
    if (description != null) data['description'] = description;
    if (routingStrategy != null) data['routing_strategy'] = routingStrategy;
    if (maxWaitTime != null) data['max_wait_time'] = maxWaitTime;

    final response = await _client.post('/calls/queues', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteQueue(String id) async {
    final response = await _client.delete('/calls/queues/$id');
    return ApiResponse.fromResponse(response);
  }
}
