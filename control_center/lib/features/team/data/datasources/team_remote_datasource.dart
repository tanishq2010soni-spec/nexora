import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class TeamRemoteDatasource {
  final ApiClient _apiClient;

  const TeamRemoteDatasource(this._apiClient);

  static const _baseUrl = '/team';

  Future<ApiResponse> getDepartments() async {
    final response = await _apiClient.get('$_baseUrl/departments');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createDepartment(Map<String, dynamic> data) async {
    final response = await _apiClient.post('$_baseUrl/departments', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getTeams() async {
    final response = await _apiClient.get('$_baseUrl/teams');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createTeam(Map<String, dynamic> data) async {
    final response = await _apiClient.post('$_baseUrl/teams', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getRoles() async {
    final response = await _apiClient.get('$_baseUrl/roles');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createRole(Map<String, dynamic> data) async {
    final response = await _apiClient.post('$_baseUrl/roles', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getMembers() async {
    final response = await _apiClient.get('$_baseUrl/members');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getActivity() async {
    final response = await _apiClient.get('$_baseUrl/activity');
    return ApiResponse.fromResponse(response);
  }
}
