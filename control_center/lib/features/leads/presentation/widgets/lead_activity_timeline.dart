import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/lead_activity.dart';

class LeadActivityTimeline extends StatelessWidget {
  final List<LeadActivity> activities;

  const LeadActivityTimeline({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final sorted = List<LeadActivity>.from(activities)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final activity = sorted[index];
        final isLast = index == sorted.length - 1;
        return _buildTimelineItem(activity, isLast);
      },
    );
  }

  Widget _buildTimelineItem(LeadActivity activity, bool isLast) {
    final config = _activityConfig(activity.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: config.$2.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: config.$2.withAlpha(80)),
                ),
                child: Icon(config.$1, size: 16, color: config.$2),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.surfaceBorder),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatDateTime(activity.createdAt),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      if (activity.performedBy != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'by ${activity.performedBy}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (activity.oldValue != null && activity.newValue != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              activity.oldValue!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              activity.newValue!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _activityConfig(ActivityType type) {
    return switch (type) {
      ActivityType.created => (Icons.add_circle_outline, AppColors.success),
      ActivityType.statusChanged => (Icons.swap_horiz, AppColors.info),
      ActivityType.noteAdded => (Icons.note_add_outlined, AppColors.warning),
      ActivityType.assigned => (Icons.person_add_outlined, AppColors.accent),
      ActivityType.contacted => (
        Icons.phone_in_talk_outlined,
        const Color(0xFF06B6D4),
      ),
      ActivityType.qualified => (Icons.check_circle_outline, AppColors.success),
      ActivityType.won => (Icons.emoji_events_outlined, AppColors.success),
      ActivityType.lost => (Icons.cancel_outlined, AppColors.error),
      ActivityType.imported => (Icons.upload_file_outlined, AppColors.warning),
    };
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
