import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class BillingRemoteDatasource {
  final ApiClient _apiClient;

  const BillingRemoteDatasource(this._apiClient);

  static const _baseUrl = '/billing';

  Future<ApiResponse> getPlans() async {
    final response = await _apiClient.get('$_baseUrl/plans');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getSubscription() async {
    final response = await _apiClient.get('$_baseUrl/subscription');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createSubscription(String planId) async {
    final response = await _apiClient.post(
      '$_baseUrl/subscription',
      data: {'planId': planId},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> cancelSubscription() async {
    final response = await _apiClient.delete('$_baseUrl/subscription');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getInvoices() async {
    final response = await _apiClient.get('$_baseUrl/invoices');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getUsage() async {
    final response = await _apiClient.get('$_baseUrl/usage');
    return ApiResponse.fromResponse(response);
  }
}
