import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/workflow_model.dart';
import '../../domain/models/workflow_execution.dart';
import '../../providers/workflows_provider.dart';
import '../widgets/trigger_badge.dart';

class WorkflowDetailScreen extends ConsumerStatefulWidget {
  final WorkflowModel workflow;

  const WorkflowDetailScreen({super.key, required this.workflow});

  @override
  ConsumerState<WorkflowDetailScreen> createState() =>
      _WorkflowDetailScreenState();
}

class _WorkflowDetailScreenState extends ConsumerState<WorkflowDetailScreen> {
  late WorkflowModel _workflow;

  @override
  void initState() {
    super.initState();
    _workflow = widget.workflow;
  }

  @override
  Widget build(BuildContext context) {
    final executionsAsync = ref.watch(workflowExecutionsProvider(_workflow.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _workflow.name,
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          AppButton(
            label: _workflow.isActive ? 'Deactivate' : 'Activate',
            variant: _workflow.isActive
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            isCompact: true,
            onPressed: () => _toggleWorkflow(),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: 'Execute',
            icon: Icons.play_arrow_outlined,
            isCompact: true,
            onPressed: () => _executeWorkflow(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Execution History',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: executionsAsync.when(
                loading: () => const AppLoader(),
                error: (e, _) => ErrorView(
                  exception: e is AppException
                      ? e
                      : UnknownException(e.toString()),
                  onRetry: () =>
                      ref.invalidate(workflowExecutionsProvider(_workflow.id)),
                ),
                data: (executions) {
                  if (executions.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_outlined,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(height: 16),
                          Text('No Executions', style: AppTypography.h4),
                          SizedBox(height: 8),
                          Text(
                            'Execute this workflow to see its history.',
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildExecutionsList(executions);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
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
              TriggerBadge(triggerType: _workflow.triggerType),
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _workflow.isActive
                      ? AppColors.success.withAlpha(30)
                      : AppColors.surfaceBorderLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _workflow.isActive ? 'Active' : 'Inactive',
                  style: AppTypography.labelMedium.copyWith(
                    color: _workflow.isActive
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          if (_workflow.description != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _workflow.description!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _buildStat('Executions', '${_workflow.executionCount}'),
              const SizedBox(width: AppSpacing.xl),
              _buildStat(
                'Last Run',
                _workflow.lastExecutedAt != null
                    ? DateFormat(
                        'MMM d, y h:mm a',
                      ).format(_workflow.lastExecutedAt!)
                    : 'Never',
              ),
              const SizedBox(width: AppSpacing.xl),
              _buildStat(
                'Created',
                DateFormat('MMM d, y').format(_workflow.createdAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildExecutionsList(List<WorkflowExecution> executions) {
    return ListView.separated(
      itemCount: executions.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final execution = executions[index];
        return _buildExecutionTile(execution);
      },
    );
  }

  Widget _buildExecutionTile(WorkflowExecution execution) {
    final (statusColor, statusLabel) = switch (execution.status) {
      WorkflowExecutionStatus.running => (AppColors.warning, 'Running'),
      WorkflowExecutionStatus.completed => (AppColors.success, 'Completed'),
      WorkflowExecutionStatus.failed => (AppColors.error, 'Failed'),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  execution.triggerEvent ?? 'Manual Trigger',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Started ${DateFormat('MMM d, y h:mm a').format(execution.startedAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                if (execution.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    execution.errorMessage!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusLabel,
              style: AppTypography.labelSmall.copyWith(color: statusColor),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (execution.completedAt != null)
            Text(
              _formatDuration(execution.startedAt, execution.completedAt!),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  void _toggleWorkflow() {
    ref.read(
      updateWorkflowProvider((
        id: _workflow.id,
        name: null,
        description: null,
        triggerType: null,
        isActive: !_workflow.isActive,
      )),
    );
    setState(
      () => _workflow = _workflow.copyWith(isActive: !_workflow.isActive),
    );
    ref.invalidate(workflowExecutionsProvider(_workflow.id));
  }

  Future<void> _executeWorkflow() async {
    await ref.read(executeWorkflowProvider(_workflow.id).future);
    ref.invalidate(workflowExecutionsProvider(_workflow.id));
    ref.invalidate(workflowsListProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workflow execution started'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  String _formatDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }
}
