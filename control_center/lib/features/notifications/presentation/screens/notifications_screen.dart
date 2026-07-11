import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/notification_model.dart';
import '../../providers/notifications_provider.dart';
import '../widgets/notification_tile.dart';

enum NotificationFilter { all, unread, read }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationFilter _filter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsListProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref, unreadCountAsync),
          const SizedBox(height: AppSpacing.xl),
          _buildFilterBar(),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => ErrorView(
                exception: e is AppException
                    ? e
                    : UnknownException(e.toString()),
                onRetry: () => ref.invalidate(notificationsListProvider),
              ),
              data: (notifications) {
                final filtered = _applyFilter(notifications);
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.notifications_none_outlined,
                    title: 'No Notifications',
                    subtitle: _filter == NotificationFilter.unread
                        ? 'You\'re all caught up!'
                        : 'No notifications to display.',
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final notification = filtered[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () => _handleTap(notification),
                      onMarkRead: () => _markAsRead(notification),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> unreadCountAsync,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Notifications',
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.md),
            unreadCountAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (count) {
                if (count == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        AppButton(
          label: 'Mark All Read',
          variant: AppButtonVariant.secondary,
          icon: Icons.done_all_outlined,
          onPressed: () => _markAllAsRead(context, ref),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: NotificationFilter.values.map((filter) {
        final isSelected = _filter == filter;
        final label = switch (filter) {
          NotificationFilter.all => 'All',
          NotificationFilter.unread => 'Unread',
          NotificationFilter.read => 'Read',
        };
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => setState(() => _filter = filter),
            selectedColor: AppColors.accentMuted,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.accent : AppColors.surfaceBorder,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<AppNotification> _applyFilter(List<AppNotification> notifications) {
    return switch (_filter) {
      NotificationFilter.all => notifications,
      NotificationFilter.unread =>
        notifications.where((n) => !n.isRead).toList(),
      NotificationFilter.read => notifications.where((n) => n.isRead).toList(),
    };
  }

  void _handleTap(AppNotification notification) {
    if (!notification.isRead) {
      ref.read(markNotificationReadProvider(notification.id));
      ref.invalidate(notificationsListProvider);
      ref.invalidate(unreadCountProvider);
    }
  }

  void _markAsRead(AppNotification notification) {
    ref.read(markNotificationReadProvider(notification.id));
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadCountProvider);
  }

  Future<void> _markAllAsRead(BuildContext context, WidgetRef ref) async {
    await ref.read(markAllReadProvider.future);
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadCountProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
