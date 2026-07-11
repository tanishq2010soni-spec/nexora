import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:control_center/app.dart';
import 'package:control_center/core/auth/session_manager.dart';
import 'package:control_center/core/auth/token_manager.dart';
import 'package:control_center/core/network/api_response.dart';
import 'package:control_center/core/storage/secure_storage_service.dart';
import 'package:control_center/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:control_center/features/dashboard/providers/dashboard_provider.dart';

class FakeTokenManager extends TokenManager {
  FakeTokenManager() : super(_FakeSecureStorage());

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  bool isTokenExpired(String token) => true;
}

class _FakeSecureStorage implements SecureStorageService {
  @override
  Future<void> save(String key, String value) async {}
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> delete(String key) async {}
  @override
  Future<void> deleteAll() async {}
}

class FakeDashboardDatasource implements DashboardRemoteDatasource {
  @override
  Future<ApiResponse> getStats() async {
    return const ApiResponse(
      statusCode: 200,
      data: {
        'active_agents': 5,
        'messages_today': 142,
        'calls_today': 23,
        'leads_generated': 18,
        'customers_managed': 89,
        'system_health': 'healthy',
      },
    );
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenManagerProvider.overrideWithValue(FakeTokenManager()),
          dashboardDatasourceProvider.overrideWithValue(
            FakeDashboardDatasource(),
          ),
        ],
        child: const NexoraApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
