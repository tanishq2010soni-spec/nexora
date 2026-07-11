import '../../../../core/network/api_result.dart';

abstract class AuditLogsRepositoryInterface {
  Future<ApiResult<List<Map<String, dynamic>>>> getLogs();
}
