import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/tool_category.dart';
import '../../domain/models/tool_definition.dart';
import '../../providers/tool_registry_provider.dart';

class ToolRegistryScreen extends ConsumerStatefulWidget {
  const ToolRegistryScreen({super.key});

  @override
  ConsumerState<ToolRegistryScreen> createState() =>
      _ToolRegistryScreenState();
}

class _ToolRegistryScreenState extends ConsumerState<ToolRegistryScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final toolsAsync = ref.watch(toolRegistryToolsProvider);
    final categoriesAsync = ref.watch(toolCategoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tool Registry',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () {
                  ref.invalidate(toolRegistryToolsProvider);
                  ref.invalidate(toolCategoriesProvider);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            hint: 'Search tools...',
            prefix: const Icon(Icons.search, size: 16, color: AppColors.textTertiary),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: AppSpacing.md),
          categoriesAsync.when(
            loading: () => const SizedBox(height: 32),
            error: (_, _) => const SizedBox.shrink(),
            data: (apiResult) => switch (apiResult) {
              ApiSuccess<List<ToolCategory>>(:final data) => _buildCategoryFilters(data),
              _ => const SizedBox.shrink(),
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: toolsAsync.when(
              loading: () => const ListShimmer(),
              error: (e, _) => ErrorView(
                exception: e,
                onRetry: () => ref.invalidate(toolRegistryToolsProvider),
              ),
              data: (apiResult) => switch (apiResult) {
                ApiSuccess<List<ToolDefinition>>(:final data) => _buildList(data),
                ApiError<List<ToolDefinition>>(:final exception) => ErrorView(
                  exception: exception,
                  onRetry: () => ref.invalidate(toolRegistryToolsProvider),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(List<ToolCategory> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CategoryChip(
            label: 'All',
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _CategoryChip(
              label: '${cat.name} (${cat.count})',
              isSelected: _selectedCategory == cat.name,
              onTap: () =>
                  setState(() => _selectedCategory = cat.name),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildList(List<ToolDefinition> tools) {
    var filtered = tools.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.name.toLowerCase().contains(q) &&
            !t.displayName.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_selectedCategory != null &&
          t.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return EmptyState(
        icon: Icons.build_outlined,
        title: 'No Tools Found',
        subtitle: _searchQuery.isNotEmpty || _selectedCategory != null
            ? 'Try adjusting your search or filters.'
            : 'No tools registered yet.',
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final tool = filtered[index];
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
                    Icons.build_outlined,
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
                            tool.displayName,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'v${tool.version}',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      if (tool.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          tool.description!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (tool.category != null)
                            _ToolChip(
                              label: tool.category!,
                              color: AppColors.info,
                            ),
                          const SizedBox(width: AppSpacing.sm),
                          _ToolChip(
                            label: tool.isEnabled ? 'Enabled' : 'Disabled',
                            color: tool.isEnabled
                                ? AppColors.success
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _ToolChip(
                            label: tool.healthStatus,
                            color: tool.healthStatus == 'healthy'
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ],
                      ),
                    ],
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected
                ? AppColors.textInverse
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ToolChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
