import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.surfaceHover,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: notification.isRead
                ? AppColors.surfaceBorder
                : AppColors.accent.withAlpha(60),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryIcon(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: notification.isRead
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.createdAt),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildTypeBadge(),
                      const SizedBox(width: AppSpacing.sm),
                      _buildCategoryBadge(),
                      const Spacer(),
                      if (!notification.isRead && onMarkRead != null)
                        TextButton(
                          onPressed: onMarkRead,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Mark read',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.sm,
                  top: AppSpacing.xs,
                ),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    final (icon, color) = switch (notification.category) {
      NotificationCategory.lead => (Icons.person_add_outlined, AppColors.info),
      NotificationCategory.conversation => (
        Icons.chat_bubble_outline,
        AppColors.accent,
      ),
      NotificationCategory.task => (Icons.task_outlined, AppColors.warning),
      NotificationCategory.system => (
        Icons.settings_outlined,
        AppColors.textSecondary,
      ),
      NotificationCategory.general => (
        Icons.notifications_outlined,
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

  Widget _buildTypeBadge() {
    final label = switch (notification.notificationType) {
      NotificationType.inApp => 'In-App',
      NotificationType.email => 'Email',
      NotificationType.whatsapp => 'WhatsApp',
      NotificationType.push => 'Push',
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

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceBorderLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        notification.category.name,
        style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
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
    return DateFormat('MMM d').format(dateTime);
  }
}
