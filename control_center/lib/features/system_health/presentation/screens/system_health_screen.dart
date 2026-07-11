import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/error_view.dart';
import '../../providers/health_provider.dart';

class SystemHealthScreen extends ConsumerWidget {
  const SystemHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthCheckProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Health',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => ref.invalidate(healthCheckProvider),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: healthAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => ErrorView(
                exception: e as dynamic,
                onRetry: () => ref.invalidate(healthCheckProvider),
              ),
              data: (statuses) {
                if (statuses.isEmpty) {
                  return const _EmptyHealthState();
                }
                return ListView(
                  children: statuses.map((status) {
                    final icon = _serviceIcon(status.service);
                    final color = status.isHealthy
                        ? AppColors.success
                        : AppColors.error;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildHealthCard(
                        icon: icon,
                        label: status.service,
                        status: status.status,
                        color: color,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _serviceIcon(String service) {
    return switch (service.toLowerCase()) {
      'database' || 'db' => Icons.storage,
      'api server' => Icons.api,
      'ollama llm' || 'llm' => Icons.memory,
      'vector store' => Icons.dns_outlined,
      'cache' || 'redis' => Icons.cached_outlined,
      _ => Icons.check_circle_outline,
    };
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String label,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: AppTypography.bodySmall.copyWith(
                    color: status == 'Healthy' || status == 'Running'
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _EmptyHealthState extends StatelessWidget {
  const _EmptyHealthState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Health check unavailable',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to retrieve system health status.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
