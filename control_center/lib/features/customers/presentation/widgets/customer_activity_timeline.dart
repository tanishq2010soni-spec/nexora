import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/models/customer_activity.dart';
import '../../providers/customer_provider.dart';

class CustomerActivityTimeline extends ConsumerWidget {
  final String customerId;

  const CustomerActivityTimeline({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(customerActivitiesProvider(customerId));

    return activitiesAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => Center(
        child: Text(
          'Failed to load activities',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timeline_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No Activities Yet',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            final isLast = index == activities.length - 1;

            return _buildTimelineItem(activity, isLast);
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(CustomerActivity activity, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getColor(activity.type),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.surfaceBorder),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIcon(activity.type),
                        size: 14,
                        color: _getColor(activity.type),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTypeLabel(activity.type),
                        style: AppTypography.labelSmall.copyWith(
                          color: _getColor(activity.type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(activity.createdAt),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (activity.performedByName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'By: ${activity.performedByName}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(CustomerActivityType type) {
    switch (type) {
      case CustomerActivityType.leadConverted:
        return AppColors.success;
      case CustomerActivityType.whatsappInteraction:
        return const Color(0xFF25D366);
      case CustomerActivityType.callInteraction:
        return AppColors.accent;
      case CustomerActivityType.noteAdded:
        return AppColors.warning;
      case CustomerActivityType.statusChanged:
        return AppColors.accent;
      case CustomerActivityType.segmentChanged:
        return AppColors.success;
    }
  }

  IconData _getIcon(CustomerActivityType type) {
    switch (type) {
      case CustomerActivityType.leadConverted:
        return Icons.person_add_outlined;
      case CustomerActivityType.whatsappInteraction:
        return Icons.chat_outlined;
      case CustomerActivityType.callInteraction:
        return Icons.phone_outlined;
      case CustomerActivityType.noteAdded:
        return Icons.note_outlined;
      case CustomerActivityType.statusChanged:
        return Icons.swap_horiz_outlined;
      case CustomerActivityType.segmentChanged:
        return Icons.category_outlined;
    }
  }

  String _getTypeLabel(CustomerActivityType type) {
    switch (type) {
      case CustomerActivityType.leadConverted:
        return 'Lead Converted';
      case CustomerActivityType.whatsappInteraction:
        return 'WhatsApp Interaction';
      case CustomerActivityType.callInteraction:
        return 'Call Interaction';
      case CustomerActivityType.noteAdded:
        return 'Note Added';
      case CustomerActivityType.statusChanged:
        return 'Status Changed';
      case CustomerActivityType.segmentChanged:
        return 'Segment Changed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
