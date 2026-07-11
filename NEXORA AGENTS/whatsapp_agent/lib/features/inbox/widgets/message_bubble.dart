import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSent = message.isSentByUser;
    final isAI = message.isFromAI;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: isAI ? AppColors.aiIndicator.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2),
              child: Icon(
                isAI ? Icons.smart_toy_rounded : Icons.person_rounded,
                size: 12,
                color: isAI ? AppColors.aiIndicator : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSent ? AppColors.messageBubbleSent : AppColors.messageBubbleReceived,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isSent ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isSent ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.senderName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName!,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSent ? AppColors.textOnPrimary.withValues(alpha: 0.7) : AppColors.textMuted,
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSent ? AppColors.textOnPrimary : AppColors.textPrimary,
                    ),
                  ),
                  if (message.mediaUrl != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.surfaceBorder,
                      ),
                      child: Center(
                        child: Icon(
                          message.mediaType == 'image' ? Icons.image_rounded : Icons.insert_drive_file_rounded,
                          color: AppColors.textMuted,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isSent) const SizedBox(width: 8),
          if (isSent && message.isFromAI)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.aiIndicator,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, size: 10, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class MessageTimeDivider extends StatelessWidget {
  final String label;

  const MessageTimeDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.chipBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: AppTypography.labelSmall),
        ),
      ),
    );
  }
}
