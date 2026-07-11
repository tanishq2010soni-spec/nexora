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
import '../../domain/enums/model_type.dart';
import '../../domain/models/model_registry_entry.dart';
import '../../providers/model_registry_provider.dart';

class ModelRegistryScreen extends ConsumerStatefulWidget {
  const ModelRegistryScreen({super.key});

  @override
  ConsumerState<ModelRegistryScreen> createState() =>
      _ModelRegistryScreenState();
}

class _ModelRegistryScreenState extends ConsumerState<ModelRegistryScreen> {
  ModelType? _typeFilter;

  static const _filterTabs = [
    null,
    ModelType.installed,
    ModelType.remote,
    ModelType.favorite,
    ModelType.downloaded,
  ];

  static const _filterLabels = [
    'All',
    'Installed',
    'Remote',
    'Favorites',
    'Downloaded',
  ];

  @override
  Widget build(BuildContext context) {
    final modelsAsync = ref.watch(modelRegistryModelsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Model Registry',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => ref.invalidate(modelRegistryModelsProvider),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filterTabs.length, (index) {
                final isSelected = _typeFilter == _filterTabs[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _typeFilter = _filterTabs[index]),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.surfaceBorder,
                        ),
                      ),
                      child: Text(
                        _filterLabels[index],
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.textInverse
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: modelsAsync.when(
              loading: () => const ListShimmer(),
              error: (e, _) => ErrorView(
                exception: e,
                onRetry: () => ref.invalidate(modelRegistryModelsProvider),
              ),
              data: (apiResult) => switch (apiResult) {
                ApiSuccess<List<ModelRegistryEntry>>(:final data) => _buildList(context, data),
                ApiError<List<ModelRegistryEntry>>(:final exception) => ErrorView(
                  exception: exception,
                  onRetry: () => ref.invalidate(modelRegistryModelsProvider),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<ModelRegistryEntry> models) {
    var filtered = _typeFilter == null
        ? models
        : models.where((m) => m.type == _typeFilter).toList();

    if (filtered.isEmpty) {
      return EmptyState(
        icon: Icons.memory_outlined,
        title: _typeFilter == null ? 'No Models' : 'No Matches',
        subtitle: _typeFilter == null
            ? 'No models registered yet'
            : 'No models of this type.',
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return SlideFadeIn(
          offset: const Offset(0, 12),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
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
                    Icons.memory,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBorderLight.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.type.name.toUpperCase(),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              entry.displayName,
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            entry.providerId,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (entry.version != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'v${entry.version}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                          if (entry.sizeMb != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.info.withAlpha(20),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                entry.sizeMb! >= 1024
                                    ? '${(entry.sizeMb! / 1024).toStringAsFixed(1)} GB'
                                    : '${entry.sizeMb} MB',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.info,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (entry.supportsVision)
                            _ModelChip(label: 'Vision', color: AppColors.info),
                          if (entry.supportsAudio)
                            _ModelChip(label: 'Audio', color: AppColors.success),
                          if (entry.supportsReasoning)
                            _ModelChip(label: 'Reasoning', color: AppColors.warning),
                          if (entry.supportsCoding)
                            _ModelChip(label: 'Coding', color: AppColors.accent),
                          if (entry.supportsEmbedding)
                            _ModelChip(label: 'Embedding', color: AppColors.info),
                          if (entry.supportsReranking)
                            _ModelChip(label: 'Reranking', color: AppColors.success),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: entry.isActive ? AppColors.success : AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModelChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ModelChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontSize: 9,
          ),
        ),
      ),
    );
  }
}
