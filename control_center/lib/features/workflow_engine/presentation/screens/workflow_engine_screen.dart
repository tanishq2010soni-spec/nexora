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
import '../../domain/enums/execution_status.dart';
import '../../domain/models/workflow_definition.dart';
import '../../domain/models/workflow_execution_model.dart';
import '../../providers/workflow_engine_provider.dart';

class WorkflowEngineScreen extends ConsumerWidget {
  const WorkflowEngineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowsAsync = ref.watch(workflowsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workflow Engine',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => ref.invalidate(workflowsProvider),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: workflowsAsync.when(
              loading: () => const ListShimmer(),
              error: (e, _) => ErrorView(
                exception: e,
                onRetry: () => ref.invalidate(workflowsProvider),
              ),
              data: (apiResult) => switch (apiResult) {
                ApiSuccess<List<WorkflowDefinition>>(:final data) =>
                  data.isEmpty
                      ? const EmptyState(
                          icon: Icons.account_tree_outlined,
                          title: 'No Workflows',
                          subtitle: 'No workflow definitions created yet.',
                        )
                      : ListView.separated(
                          itemCount: data.length,
separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                            final workflow = data[index];
                            return SlideFadeIn(
                              offset: const Offset(0, 12),
                              child: _WorkflowCard(
                                workflow: workflow,
                              ),
                            );
                          },
                        ),
                ApiError<List<WorkflowDefinition>>(:final exception) =>
                  ErrorView(
                    exception: exception,
                    onRetry: () => ref.invalidate(workflowsProvider),
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

class _WorkflowCard extends StatelessWidget {
  final WorkflowDefinition workflow;

  const _WorkflowCard({required this.workflow});

  IconData _triggerIcon() {
    return switch (workflow.triggerType?.toLowerCase()) {
      'cron' || 'schedule' => Icons.schedule,
      'webhook' => Icons.webhook,
      'event' => Icons.event,
      'manual' => Icons.touch_app,
      _ => Icons.bolt,
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
              _triggerIcon(),
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
                      workflow.name,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: workflow.isActive
                            ? AppColors.success.withAlpha(20)
                            : AppColors.textTertiary.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        workflow.isActive ? 'Active' : 'Inactive',
                        style: AppTypography.labelSmall.copyWith(
                          color: workflow.isActive
                              ? AppColors.success
                              : AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                if (workflow.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    workflow.description!,
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
                    Icon(Icons.alt_route,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${workflow.steps.length} step(s)',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (workflow.triggerType != null) ...[
                      const SizedBox(width: AppSpacing.md),
                      Icon(Icons.bolt,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        workflow.triggerType!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.tag,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'v${workflow.version}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _LastExecutionStatus(workflowId: workflow.id),
        ],
      ),
    );
  }
}

class _LastExecutionStatus extends ConsumerWidget {
  final String workflowId;

  const _LastExecutionStatus({required this.workflowId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final executionsAsync = ref.watch(
      workflowExecutionsProvider(workflowId),
    );

    return executionsAsync.when(
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (apiResult) => switch (apiResult) {
        ApiSuccess<List<WorkflowExecutionModel>>(:final data) =>
          data.isEmpty
              ? const SizedBox.shrink()
              : _buildStatusIndicator(data.first.status),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildStatusIndicator(ExecutionStatus status) {
    final (icon, color) = switch (status) {
      ExecutionStatus.pending => (Icons.schedule, AppColors.textTertiary),
      ExecutionStatus.running => (Icons.sync, AppColors.info),
      ExecutionStatus.completed => (Icons.check_circle, AppColors.success),
      ExecutionStatus.failed => (Icons.cancel, AppColors.error),
      ExecutionStatus.cancelled => (Icons.cancel_outlined, AppColors.warning),
      ExecutionStatus.paused => (Icons.pause_circle, AppColors.warning),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          status.name,
          style: AppTypography.labelSmall.copyWith(color: color),
        ),
      ],
    );
  }
}
