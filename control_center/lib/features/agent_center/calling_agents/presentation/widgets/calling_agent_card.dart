import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../shared/models/agent.dart';
import '../../domain/models/calling_agent.dart';
import '../../providers/calling_agent_provider.dart';

class CallingAgentCard extends ConsumerStatefulWidget {
  final CallingAgent agent;

  const CallingAgentCard({super.key, required this.agent});

  @override
  ConsumerState<CallingAgentCard> createState() => _CallingAgentCardState();
}

class _CallingAgentCardState extends ConsumerState<CallingAgentCard> {
  bool _isHovered = false;

  Color get _statusColor => switch (widget.agent.status) {
    AgentStatus.active => AppColors.success,
    AgentStatus.idle => AppColors.warning,
    AgentStatus.error => AppColors.error,
    AgentStatus.disabled => AppColors.textTertiary,
  };

  String get _statusLabel => switch (widget.agent.status) {
    AgentStatus.active => 'Active',
    AgentStatus.idle => 'Idle',
    AgentStatus.error => 'Error',
    AgentStatus.disabled => 'Disabled',
  };

  @override
  Widget build(BuildContext context) {
    final agent = widget.agent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.surfaceHover : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: agent.status == AgentStatus.active
                ? AppColors.success.withValues(alpha: 0.3)
                : _isHovered
                ? AppColors.surfaceBorderLight
                : AppColors.surfaceBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    agent.name,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.record_voice_over,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  agent.voiceConfig.voiceId,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  agent.llmModel,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _StatChip(label: 'Total', value: '${agent.totalCalls}'),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(label: 'Today', value: '${agent.todayCalls}'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _statusLabel,
                  style: AppTypography.labelSmall.copyWith(color: _statusColor),
                ),
                const SizedBox(width: AppSpacing.sm),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  color: AppColors.surface,
                  onSelected: (value) => _handleAction(context, ref, value),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: agent.status == AgentStatus.disabled
                          ? 'enable'
                          : 'disable',
                      child: Text(
                        agent.status == AgentStatus.disabled
                            ? 'Enable'
                            : 'Disable',
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final repository = ref.read(callingAgentRepositoryProvider);

    switch (action) {
      case 'edit':
        break;
      case 'enable':
        await repository.toggleAgentStatus(widget.agent.id, true);
        ref.invalidate(callingAgentsProvider);
      case 'disable':
        await repository.toggleAgentStatus(widget.agent.id, false);
        ref.invalidate(callingAgentsProvider);
      case 'delete':
        final confirmed = await ConfirmDialog.show(
          context: context,
          title: 'Delete Agent',
          message:
              'Are you sure you want to delete "${widget.agent.name}"? This action cannot be undone.',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
        if (confirmed && context.mounted) {
          await repository.deleteAgent(widget.agent.id);
          ref.invalidate(callingAgentsProvider);
        }
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
