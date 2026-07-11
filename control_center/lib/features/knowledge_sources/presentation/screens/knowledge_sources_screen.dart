import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/enums/indexing_status.dart';
import '../../domain/enums/source_type.dart';
import '../../domain/models/knowledge_source.dart';
import '../../providers/knowledge_source_provider.dart';

class KnowledgeSourcesScreen extends ConsumerStatefulWidget {
  final String knowledgeBaseId;

  const KnowledgeSourcesScreen({
    super.key,
    required this.knowledgeBaseId,
  });

  @override
  ConsumerState<KnowledgeSourcesScreen> createState() =>
      _KnowledgeSourcesScreenState();
}

class _KnowledgeSourcesScreenState
    extends ConsumerState<KnowledgeSourcesScreen> {
  @override
  Widget build(BuildContext context) {
    final sourcesAsync = ref.watch(
      knowledgeSourcesProvider(widget.knowledgeBaseId),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Knowledge Sources',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: () => ref.invalidate(
                      knowledgeSourcesProvider(widget.knowledgeBaseId),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: 'Add Source',
                    icon: Icons.add,
                    onPressed: () => _showAddSourceDialog(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: sourcesAsync.when(
              loading: () => const ListShimmer(),
              error: (e, _) => ErrorView(
                exception: e,
                onRetry: () => ref.invalidate(
                  knowledgeSourcesProvider(widget.knowledgeBaseId),
                ),
              ),
              data: (apiResult) => switch (apiResult) {
                ApiSuccess<List<KnowledgeSource>>(:final data) => data.isEmpty
                    ? const EmptyState(
                        icon: Icons.source_outlined,
                        title: 'No Sources',
                        subtitle: 'Add a knowledge source to get started.',
                      )
                    : ListView.separated(
                        itemCount: data.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final source = data[index];
                          return SlideFadeIn(
                            offset: const Offset(0, 12),
                            child: _SourceCard(source: source),
                          );
                        },
                      ),
                ApiError<List<KnowledgeSource>>(:final exception) =>
                  ErrorView(
                    exception: exception,
                    onRetry: () => ref.invalidate(
                      knowledgeSourcesProvider(widget.knowledgeBaseId),
                    ),
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSourceDialog(BuildContext context) {
    SourceType? selectedType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: Text(
            'Add Knowledge Source',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select source type:',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SourceType.values.map((type) {
                    final isSelected = selectedType == type;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedType = type),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.surfaceHover,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.surfaceBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _sourceTypeIcon(type),
                              size: 14,
                              color: isSelected
                                  ? AppColors.textInverse
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _sourceTypeLabel(type),
                              style: AppTypography.labelSmall.copyWith(
                                color: isSelected
                                    ? AppColors.textInverse
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.ghost,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: 'Add',
              onPressed: selectedType == null
                  ? null
                  : () {
                      Navigator.of(ctx).pop();
                    },
            ),
          ],
        ),
      ),
    );
  }

  IconData _sourceTypeIcon(SourceType type) {
    return switch (type) {
      SourceType.web => Icons.language,
      SourceType.file => Icons.description,
      SourceType.database => Icons.storage,
      SourceType.api => Icons.api,
      SourceType.s3 => Icons.cloud,
      SourceType.gcs => Icons.cloud_queue,
      SourceType.confluence => Icons.article,
      SourceType.notion => Icons.book,
      SourceType.sharepoint => Icons.folder,
      SourceType.slack => Icons.chat,
      SourceType.discord => Icons.forum,
      SourceType.custom => Icons.code,
    };
  }

  String _sourceTypeLabel(SourceType type) {
    return switch (type) {
      SourceType.web => 'Web',
      SourceType.file => 'File',
      SourceType.database => 'Database',
      SourceType.api => 'API',
      SourceType.s3 => 'S3',
      SourceType.gcs => 'GCS',
      SourceType.confluence => 'Confluence',
      SourceType.notion => 'Notion',
      SourceType.sharepoint => 'SharePoint',
      SourceType.slack => 'Slack',
      SourceType.discord => 'Discord',
      SourceType.custom => 'Custom',
    };
  }
}

class _SourceCard extends StatelessWidget {
  final KnowledgeSource source;

  const _SourceCard({required this.source});

  IconData _sourceTypeIcon() {
    return switch (source.sourceType) {
      SourceType.web => Icons.language,
      SourceType.file => Icons.description,
      SourceType.database => Icons.storage,
      SourceType.api => Icons.api,
      SourceType.s3 => Icons.cloud,
      SourceType.gcs => Icons.cloud_queue,
      SourceType.confluence => Icons.article,
      SourceType.notion => Icons.book,
      SourceType.sharepoint => Icons.folder,
      SourceType.slack => Icons.chat,
      SourceType.discord => Icons.forum,
      SourceType.custom => Icons.code,
    };
  }

  Color _indexingColor() {
    return switch (source.indexingStatus) {
      IndexingStatus.pending => AppColors.textTertiary,
      IndexingStatus.indexing => AppColors.info,
      IndexingStatus.completed => AppColors.success,
      IndexingStatus.failed => AppColors.error,
      IndexingStatus.skipped => AppColors.warning,
    };
  }

  String _indexingLabel() {
    return switch (source.indexingStatus) {
      IndexingStatus.pending => 'Pending',
      IndexingStatus.indexing => 'Indexing',
      IndexingStatus.completed => 'Completed',
      IndexingStatus.failed => 'Failed',
      IndexingStatus.skipped => 'Skipped',
    };
  }

  @override
  Widget build(BuildContext context) {
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _sourceTypeIcon(),
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
                      source.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _indexingColor().withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _indexingLabel(),
                        style: AppTypography.labelSmall.copyWith(
                          color: _indexingColor(),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                if (source.lastIndexedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Last indexed: ${_formatDateTime(source.lastIndexedAt!)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
