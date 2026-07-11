import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/provider_overrides.dart';

class HealthStatus {
  final String service;
  final String status;
  final bool isHealthy;
  final String? detail;

  const HealthStatus({
    required this.service,
    required this.status,
    required this.isHealthy,
    this.detail,
  });
}

final healthCheckProvider = FutureProvider<List<HealthStatus>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final results = <HealthStatus>[];

  try {
    final response = await apiClient.get('/health');
    results.add(
      HealthStatus(
        service: 'API Server',
        status: 'Running',
        isHealthy: response.statusCode == 200,
      ),
    );
  } catch (_) {
    results.add(
      HealthStatus(
        service: 'API Server',
        status: 'Unreachable',
        isHealthy: false,
      ),
    );
  }

  try {
    final response = await apiClient.get('/health/detailed');
    if (response.statusCode == 200 && response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      for (final entry in data.entries) {
        final healthy = entry.value == 'healthy' || entry.value == 'ok';
        results.add(
          HealthStatus(
            service: _formatServiceName(entry.key),
            status: healthy ? 'Healthy' : 'Degraded',
            isHealthy: healthy,
          ),
        );
      }
    }
  } catch (_) {
    results.addAll([
      HealthStatus(service: 'Database', status: 'Unknown', isHealthy: false),
      HealthStatus(service: 'Ollama LLM', status: 'Unknown', isHealthy: false),
      HealthStatus(
        service: 'Vector Store',
        status: 'Unknown',
        isHealthy: false,
      ),
    ]);
  }

  return results;
});

String _formatServiceName(String key) {
  return switch (key.toLowerCase()) {
    'database' || 'db' => 'Database',
    'ollama' || 'llm' => 'Ollama LLM',
    'qdrant' || 'vector_store' || 'vector' => 'Vector Store',
    'redis' || 'cache' => 'Cache',
    _ => key[0].toUpperCase() + key.substring(1),
  };
}
