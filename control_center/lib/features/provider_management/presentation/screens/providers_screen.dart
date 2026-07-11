import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/enums/provider_health_status.dart';
import '../../domain/enums/provider_type.dart';
import '../../domain/models/provider_model.dart';
import '../../providers/provider_provider.dart';

class ProvidersScreen extends ConsumerWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(providersProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Providers',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => ref.invalidate(providersProvider),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: providersAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => ErrorView(
                exception: e,
                onRetry: () => ref.invalidate(providersProvider),
              ),
              data: (apiResult) => apiResult is ApiSuccess<List<ProviderModel>>
                  ? (apiResult.data.isEmpty
                      ? const EmptyState(
                          icon: Icons.dns_outlined,
                          title: 'No Providers',
                          subtitle: 'No providers configured yet.',
                        )
                      : _ProvidersGrid(providers: apiResult.data))
                  : apiResult is ApiError<List<ProviderModel>>
                      ? ErrorView(
                          exception: apiResult.exception,
                          onRetry: () => ref.invalidate(providersProvider),
                        )
                      : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProvidersGrid extends StatelessWidget {
  final List<ProviderModel> providers;

  const _ProvidersGrid({required this.providers});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = screenWidth < 600 ? 1 : (screenWidth < 1024 ? 2 : 3);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.lg,
        crossAxisSpacing: AppSpacing.lg,
        childAspectRatio: 1.6,
      ),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        return SlideFadeIn(
          offset: const Offset(0, 20),
          child: _ProviderCard(provider: provider),
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;

  const _ProviderCard({required this.provider});

  Color _healthColor() {
    return switch (provider.healthStatus) {
      ProviderHealthStatus.healthy => AppColors.success,
      ProviderHealthStatus.degraded => AppColors.warning,
      ProviderHealthStatus.down => AppColors.error,
      ProviderHealthStatus.unknown => AppColors.textTertiary,
    };
  }

  String _providerTypeLabel() {
    return switch (provider.providerType) {
      ProviderType.openai => 'OpenAI',
      ProviderType.anthropic => 'Anthropic',
      ProviderType.google => 'Google',
      ProviderType.azure => 'Azure',
      ProviderType.awsBedrock => 'AWS Bedrock',
      ProviderType.groq => 'Groq',
      ProviderType.together => 'Together',
      ProviderType.replicate => 'Replicate',
      ProviderType.ollama => 'Ollama',
      ProviderType.openRouter => 'OpenRouter',
      ProviderType.custom => 'Custom',
    };
  }

  IconData _providerIcon() {
    return switch (provider.providerType) {
      ProviderType.ollama => Icons.memory,
      ProviderType.custom => Icons.code,
      _ => Icons.cloud
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _providerIcon(),
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _providerTypeLabel(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _healthColor(),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              if (provider.latencyP50Ms > 0) ...[
                Icon(Icons.timer_outlined, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${provider.latencyP50Ms}ms',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (provider.contextWindow > 0) ...[
                Icon(Icons.aspect_ratio, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  '${(provider.contextWindow / 1000).toStringAsFixed(0)}K',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (provider.supportsStreaming)
                _Chip(label: 'Streaming', color: AppColors.info),
              if (provider.supportsVision)
                _Chip(label: 'Vision', color: AppColors.success),
              if (provider.supportsToolCalling)
                _Chip(label: 'Tool Calling', color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
