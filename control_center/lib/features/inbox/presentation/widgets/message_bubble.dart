import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/inbox_message.dart';

class MessageBubble extends StatelessWidget {
  final InboxMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isAgent = message.senderType == MessageSenderType.agent;
    final isSystem = message.senderType == MessageSenderType.system;

    if (isSystem) {
      return _buildSystemMessage();
    }

    return Align(
      alignment: isAgent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        child: Column(
          crossAxisAlignment: isAgent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (message.senderType == MessageSenderType.bot)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'AI Bot',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isAgent ? AppColors.accent : AppColors.surfaceHover,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isAgent ? 12 : 4),
                  bottomRight: Radius.circular(isAgent ? 4 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.attachmentUrl != null) _buildAttachment(),
                  Text(
                    message.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isAgent ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(message.createdAt),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceHover,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message.content,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAttachment() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceBorder.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_attachmentIcon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            message.attachmentType ?? 'Attachment',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _attachmentIcon {
    return switch (message.attachmentType) {
      'image' => Icons.image_outlined,
      'audio' => Icons.audio_file_outlined,
      'file' => Icons.attach_file,
      'video' => Icons.videocam_outlined,
      _ => Icons.attach_file,
    };
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
