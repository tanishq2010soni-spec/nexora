import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/knowledge_base.dart';

class KbCard extends StatelessWidget {
  final KnowledgeBase kb;
  final VoidCallback onViewDocuments;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KbCard({
    super.key,
    required this.kb,
    required this.onViewDocuments,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _syncStatusColor {
    switch (kb.qdrantSyncStatus) {
      case 'healthy':
        return AppColors.success;
      case 'syncing':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  String get _syncStatusLabel {
    switch (kb.qdrantSyncStatus) {
      case 'healthy':
        return 'Synced';
      case 'syncing':
        return 'Syncing';
      case 'error':
        return 'Error';
      default:
        return kb.qdrantSyncStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder_outlined,
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
                      kb.name,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (kb.description != null && kb.description!.isNotEmpty)
                      Text(
                        kb.description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _syncStatusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _syncStatusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _syncStatusLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: _syncStatusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatItem(
                icon: Icons.description_outlined,
                value: '${kb.documentCount}',
                label: 'Docs',
              ),
              const SizedBox(width: AppSpacing.lg),
              _StatItem(
                icon: Icons.view_module_outlined,
                value: '${kb.totalChunks}',
                label: 'Chunks',
              ),
              const SizedBox(width: AppSpacing.lg),
              _StatItem(
                icon: Icons.texture_outlined,
                value: '${kb.totalEmbeddings}',
                label: 'Embeddings',
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'View Docs',
                  variant: AppButtonVariant.primary,
                  isCompact: true,
                  icon: Icons.folder_open,
                  onPressed: onViewDocuments,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Edit',
                  variant: AppButtonVariant.ghost,
                  isCompact: true,
                  icon: Icons.edit_outlined,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Delete',
                  variant: AppButtonVariant.ghost,
                  isCompact: true,
                  icon: Icons.delete_outline,
                  onPressed: onDelete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
