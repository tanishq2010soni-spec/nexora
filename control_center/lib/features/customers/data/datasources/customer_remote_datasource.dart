import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class CustomerRemoteDatasource {
  final ApiClient _apiClient;

  const CustomerRemoteDatasource(this._apiClient);

  static const _baseUrl = '';

  Future<ApiResponse> getCustomers({
    String? segment,
    String? search,
    String? assignedTo,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      'offset': (page - 1) * limit,
    };
    if (segment != null) query['segment'] = segment;
    if (search != null) query['search'] = search;
    if (assignedTo != null) query['assignedTo'] = assignedTo;

    final response = await _apiClient.get(
      '$_baseUrl/customers/',
      queryParameters: query,
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getCustomer(String id) async {
    final response = await _apiClient.get('/customers/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateCustomer(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch('/customers/$id', data: data);
    return ApiResponse.fromResponse(response);
  }
}
