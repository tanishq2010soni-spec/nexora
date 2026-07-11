import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/workflow_model.dart';

class WorkflowTile extends StatelessWidget {
  final WorkflowModel workflow;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const WorkflowTile({
    super.key,
    required this.workflow,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: workflow.isActive
                ? AppColors.accent.withAlpha(40)
                : AppColors.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            _buildTriggerIcon(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          workflow.name,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildActiveBadge(),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (workflow.description != null) ...[
                    Text(
                      workflow.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  Row(
                    children: [
                      _buildTriggerBadge(),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${workflow.executionCount} runs',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (workflow.lastExecutedAt != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Last: ${_formatTime(workflow.lastExecutedAt!)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Switch(
              value: workflow.isActive,
              onChanged: (_) => onToggle?.call(),
              activeThumbColor: AppColors.accent,
            ),
            const SizedBox(width: AppSpacing.sm),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerIcon() {
    final (icon, color) = switch (workflow.triggerType) {
      WorkflowTriggerType.newLead => (
        Icons.person_add_outlined,
        AppColors.info,
      ),
      WorkflowTriggerType.customerReplied => (
        Icons.reply_outlined,
        AppColors.accent,
      ),
      WorkflowTriggerType.callMissed => (
        Icons.phone_missed_outlined,
        AppColors.warning,
      ),
      WorkflowTriggerType.appointmentBooked => (
        Icons.event_outlined,
        AppColors.success,
      ),
      WorkflowTriggerType.manual => (
        Icons.play_arrow_outlined,
        AppColors.textTertiary,
      ),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildTriggerBadge() {
    final label = switch (workflow.triggerType) {
      WorkflowTriggerType.newLead => 'New Lead',
      WorkflowTriggerType.customerReplied => 'Customer Replied',
      WorkflowTriggerType.callMissed => 'Call Missed',
      WorkflowTriggerType.appointmentBooked => 'Appointment Booked',
      WorkflowTriggerType.manual => 'Manual',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceBorderLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: workflow.isActive
            ? AppColors.success.withAlpha(30)
            : AppColors.surfaceBorderLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        workflow.isActive ? 'Active' : 'Inactive',
        style: AppTypography.labelSmall.copyWith(
          color: workflow.isActive ? AppColors.success : AppColors.textTertiary,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}';
  }
}
