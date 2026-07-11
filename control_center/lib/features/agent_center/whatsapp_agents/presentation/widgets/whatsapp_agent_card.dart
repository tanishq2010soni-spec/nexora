import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_button.dart';

import '../../domain/models/whatsapp_agent.dart';

import '../../../shared/models/agent.dart';

class WhatsAppAgentCard extends StatefulWidget {
  final WhatsAppAgent agent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const WhatsAppAgentCard({
    super.key,
    required this.agent,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  State<WhatsAppAgentCard> createState() => _WhatsAppAgentCardState();
}

class _WhatsAppAgentCardState extends State<WhatsAppAgentCard> {
  bool _isHovered = false;

  Color get _statusColor {
    switch (widget.agent.status) {
      case AgentStatus.active:
        return AppColors.success;
      case AgentStatus.idle:
        return AppColors.warning;
      case AgentStatus.error:
        return AppColors.error;
      case AgentStatus.disabled:
        return AppColors.textTertiary;
    }
  }

  String get _statusLabel {
    switch (widget.agent.status) {
      case AgentStatus.active:
        return 'Active';
      case AgentStatus.idle:
        return 'Idle';
      case AgentStatus.error:
        return 'Error';
      case AgentStatus.disabled:
        return 'Disabled';
    }
  }

  String get _lastActiveText {
    if (widget.agent.lastActiveAt == null) return 'Never';
    final diff = DateTime.now().difference(widget.agent.lastActiveAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.surfaceHover : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.agent.status == AgentStatus.active
                ? AppColors.success.withValues(alpha: 0.3)
                : _isHovered
                ? AppColors.surfaceBorderLight
                : AppColors.surfaceBorder,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.agent.name,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.smart_toy_outlined,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  widget.agent.llmModel,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.circle, size: 10, color: _statusColor),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _statusLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Last active: $_lastActiveText',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Edit',
                    variant: AppButtonVariant.ghost,
                    isCompact: true,
                    icon: Icons.edit_outlined,
                    onPressed: widget.onEdit,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Delete',
                    variant: AppButtonVariant.ghost,
                    isCompact: true,
                    icon: Icons.delete_outline,
                    onPressed: widget.onDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
