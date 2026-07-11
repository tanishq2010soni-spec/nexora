import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/task_model.dart';
import 'priority_badge.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PriorityBadge(priority: task.priority),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusChip(),
                if (onEdit != null || onDelete != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      if (onEdit != null)
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                task.description!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (task.assignedTo != null) ...[
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.assignedTo!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                if (task.dueDate != null) ...[
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: _dueDateColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDueDate(task.dueDate!),
                    style: AppTypography.labelSmall.copyWith(
                      color: _dueDateColor(),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final config = _statusConfig(task.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: config.$2.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        config.$1,
        style: AppTypography.labelSmall.copyWith(color: config.$2),
      ),
    );
  }

  (String, Color) _statusConfig(TaskStatus status) {
    return switch (status) {
      TaskStatus.pending => ('Pending', AppColors.textSecondary),
      TaskStatus.inProgress => ('In Progress', AppColors.info),
      TaskStatus.completed => ('Completed', AppColors.success),
      TaskStatus.cancelled => ('Cancelled', AppColors.error),
    };
  }

  Color _dueDateColor() {
    if (task.dueDate == null) return AppColors.textTertiary;
    if (task.dueDate!.isBefore(DateTime.now())) return AppColors.error;
    final diff = task.dueDate!.difference(DateTime.now());
    if (diff.inDays < 2) return AppColors.warning;
    return AppColors.textTertiary;
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) return 'Overdue ${diff.inDays.abs()}d';
    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    return 'Due in ${diff.inDays}d';
  }
}
