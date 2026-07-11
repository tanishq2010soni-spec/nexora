import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/audit_logs_repository_interface.dart';
import '../datasources/audit_logs_remote_datasource.dart';

class AuditLogsRepository implements AuditLogsRepositoryInterface {
  final AuditLogsRemoteDatasource _datasource;

  const AuditLogsRepository(this._datasource);

  @override
  Future<ApiResult<List<Map<String, dynamic>>>> getLogs() async {
    try {
      final response = await _datasource.getLogs();
      if (response.isSuccess && response.data != null) {
        final list = response.data as List;
        return ApiSuccess(list.cast<Map<String, dynamic>>());
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch audit logs'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
