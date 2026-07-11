import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class LeadRemoteDatasource {
  final ApiClient _apiClient;

  const LeadRemoteDatasource(this._apiClient);

  Future<ApiResponse> getLeads({
    String? status,
    String? source,
    String? search,
    String? assignedTo,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      'offset': (page - 1) * limit,
    };
    if (status != null) query['status'] = status;
    if (source != null) query['source'] = source;
    if (search != null) query['search'] = search;
    if (assignedTo != null) query['assignedTo'] = assignedTo;

    final response = await _apiClient.get('/leads/', queryParameters: query);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getLeadsCount() async {
    final response = await _apiClient.get('/leads/count');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getLead(String id) async {
    final response = await _apiClient.get('/leads/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteLead(String id) async {
    final response = await _apiClient.delete('/leads/$id');
    return ApiResponse.fromResponse(response);
  }
}
