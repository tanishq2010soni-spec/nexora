import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/inbox_conversation.dart';
import 'channel_icon.dart';
import 'unread_badge.dart';

class ConversationTile extends StatelessWidget {
  final InboxConversation conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 3,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            ChannelIcon(channel: conversation.channel.name),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopRow(),
                  const SizedBox(height: 4),
                  _buildMessagePreview(),
                ],
              ),
            ),
            _buildRightColumn(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            conversation.customerName,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatusDot(),
      ],
    );
  }

  Widget _buildMessagePreview() {
    return Text(
      conversation.lastMessage ?? 'No messages',
      style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatTimestamp(conversation.updatedAt),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChannelBadge(),
            if (conversation.unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              UnreadBadge(count: conversation.unreadCount),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildChannelBadge() {
    final label = switch (conversation.channel) {
      InboxChannel.whatsapp => 'WA',
      InboxChannel.instagram => 'IG',
      InboxChannel.facebook => 'FB',
      InboxChannel.website => 'WEB',
    };
    final color = switch (conversation.channel) {
      InboxChannel.whatsapp => const Color(0xFF25D366),
      InboxChannel.instagram => const Color(0xFFE4405F),
      InboxChannel.facebook => const Color(0xFF1877F2),
      InboxChannel.website => AppColors.accent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(fontSize: 9, color: color),
      ),
    );
  }

  Widget _buildStatusDot() {
    final color = switch (conversation.status) {
      InboxStatus.open => AppColors.success,
      InboxStatus.closed => AppColors.textTertiary,
      InboxStatus.pending => AppColors.warning,
    };

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return DateFormat('MMM d').format(date);
  }
}
