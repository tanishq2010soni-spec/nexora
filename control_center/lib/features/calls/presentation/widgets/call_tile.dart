import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/call.dart';
import 'sentiment_badge.dart';

class CallTile extends StatelessWidget {
  final VoiceCall call;
  final bool isSelected;
  final VoidCallback onTap;

  const CallTile({
    super.key,
    required this.call,
    this.isSelected = false,
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
            _buildDirectionIcon(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopRow(),
                  const SizedBox(height: 4),
                  _buildPhoneNumber(),
                ],
              ),
            ),
            _buildRightColumn(),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionIcon() {
    final isInbound = call.direction == CallDirection.inbound;
    final color = isInbound ? AppColors.success : AppColors.info;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isInbound ? Icons.call_received : Icons.call_made,
        size: 18,
        color: color,
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            call.direction == CallDirection.inbound
                ? call.callerNumber
                : call.calleeNumber,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SentimentBadge(sentiment: call.sentiment, compact: true),
      ],
    );
  }

  Widget _buildPhoneNumber() {
    return Text(
      call.direction == CallDirection.inbound
          ? 'Inbound from ${call.callerNumber}'
          : 'Outbound to ${call.calleeNumber}',
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
          _formatTimestamp(call.createdAt),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final (color, label) = switch (call.status) {
      CallStatus.queued => (AppColors.textTertiary, 'Queued'),
      CallStatus.ringing => (AppColors.warning, 'Ringing'),
      CallStatus.inProgress => (AppColors.success, 'Active'),
      CallStatus.completed => (AppColors.accent, 'Done'),
      CallStatus.failed => (AppColors.error, 'Failed'),
      CallStatus.missed => (AppColors.error, 'Missed'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
