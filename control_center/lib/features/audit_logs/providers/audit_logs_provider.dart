import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_result.dart';
import '../data/datasources/audit_logs_remote_datasource.dart';
import '../data/repositories/audit_logs_repository.dart';
import '../domain/repositories/audit_logs_repository_interface.dart';

final auditLogsDatasourceProvider = Provider<AuditLogsRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final auditLogsRepositoryProvider = Provider<AuditLogsRepositoryInterface>((
  ref,
) {
  return AuditLogsRepository(ref.read(auditLogsDatasourceProvider));
});

final auditLogsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final result = await ref.read(auditLogsRepositoryProvider).getLogs();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});
