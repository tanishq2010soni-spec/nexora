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
import '../../domain/models/plugin_model.dart';
import '../../providers/plugin_provider.dart';

class PluginsScreen extends ConsumerStatefulWidget {
  const PluginsScreen({super.key});

  @override
  ConsumerState<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends ConsumerState<PluginsScreen> {
  String? _selectedPluginId;

  @override
  Widget build(BuildContext context) {
    final pluginsAsync = ref.watch(pluginsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plugins',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => ref.invalidate(pluginsProvider),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: pluginsAsync.when(
              loading: () => const ListShimmer(),
              error: (e, _) => ErrorView(
                exception: e,
                onRetry: () => ref.invalidate(pluginsProvider),
              ),
              data: (apiResult) => switch (apiResult) {
                ApiSuccess<List<PluginModel>>(:final data) => data.isEmpty
                    ? const EmptyState(
                        icon: Icons.extension_outlined,
                        title: 'No Plugins',
                        subtitle: 'No plugins registered yet.',
                      )
                    : ListView.separated(
                        itemCount: data.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final plugin = data[index];
                          final isExpanded =
                              _selectedPluginId == plugin.id;
                          return SlideFadeIn(
                            offset: const Offset(0, 12),
                            child: _PluginCard(
                              plugin: plugin,
                              isExpanded: isExpanded,
                              onToggle: () {
                                setState(() {
                                  _selectedPluginId = isExpanded
                                      ? null
                                      : plugin.id;
                                });
                              },
                            ),
                          );
                        },
                      ),
                ApiError<List<PluginModel>>(:final exception) =>
                  ErrorView(
                    exception: exception,
                    onRetry: () => ref.invalidate(pluginsProvider),
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PluginCard extends StatelessWidget {
  final PluginModel plugin;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _PluginCard({
    required this.plugin,
    required this.isExpanded,
    required this.onToggle,
  });

  Color _healthColor() {
    return switch (plugin.healthStatus.toLowerCase()) {
      'healthy' => AppColors.success,
      'degraded' => AppColors.warning,
      'down' || 'error' => AppColors.error,
      _ => AppColors.textTertiary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.extension_outlined,
                      size: 20,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plugin.displayName,
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: plugin.isEnabled
                                    ? AppColors.success.withAlpha(20)
                                    : AppColors.textTertiary.withAlpha(20),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                plugin.isEnabled ? 'Enabled' : 'Disabled',
                                style: AppTypography.labelSmall.copyWith(
                                  color: plugin.isEnabled
                                      ? AppColors.success
                                      : AppColors.textTertiary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'v${plugin.version}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            if (plugin.category != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withAlpha(20),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  plugin.category!,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.info,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            _PluginDetailView(plugin: plugin),
        ],
      ),
    );
  }
}

class _PluginDetailView extends StatelessWidget {
  final PluginModel plugin;

  const _PluginDetailView({required this.plugin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.surfaceBorder),
          const SizedBox(height: AppSpacing.md),
          if (plugin.description != null) ...[
            Text(
              plugin.description!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (plugin.manifestJson != null) ...[
            _DetailSection(
              icon: Icons.article_outlined,
              title: 'Manifest',
              content: plugin.manifestJson!,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (plugin.permissionsJson != null) ...[
            _DetailSection(
              icon: Icons.lock_outline,
              title: 'Permissions',
              content: plugin.permissionsJson!,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (plugin.hooksJson != null) ...[
            _DetailSection(
              icon: Icons.link,
              title: 'Hooks',
              content: plugin.hooksJson!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceHover,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Text(
            content,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
