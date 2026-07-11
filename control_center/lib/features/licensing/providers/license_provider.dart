import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../data/datasources/license_remote_datasource.dart';
import '../domain/models/license_model.dart';
import '../domain/repositories/license_repository_interface.dart';

final licenseDatasourceProvider = Provider<LicenseRemoteDatasource>((ref) {
  throw UnimplementedError(
    'licenseDatasourceProvider must be overridden at the app level',
  );
});

final licenseRepositoryProvider = Provider<LicenseRepositoryInterface>((ref) {
  throw UnimplementedError(
    'licenseRepositoryProvider must be overridden at the app level',
  );
});

final licenseProvider =
    FutureProvider.autoDispose.family<ApiResult<LicenseModel>, String>(
      (ref, orgId) async {
        final repository = ref.watch(licenseRepositoryProvider);
        return repository.getLicense(orgId);
      },
    );
