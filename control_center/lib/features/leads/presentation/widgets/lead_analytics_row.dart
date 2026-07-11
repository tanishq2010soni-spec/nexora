import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../providers/lead_provider.dart';

class LeadAnalyticsRow extends ConsumerWidget {
  const LeadAnalyticsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(leadAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const SizedBox(height: 90, child: AppLoader()),
      error: (e, _) => const SizedBox(height: 40),
      data: (analytics) => Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Total Leads',
              value: '${analytics.totalLeads}',
              subtitle: 'All time',
              icon: Icons.people_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StatCard(
              title: 'Qualified Leads',
              value: '${analytics.qualifiedLeads}',
              subtitle: '${analytics.qualifiedToday} today',
              icon: Icons.check_circle_outline,
              trendColor: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StatCard(
              title: 'Won Leads',
              value: '${analytics.wonLeads}',
              subtitle: '${analytics.wonToday} today',
              icon: Icons.star_outline,
              trendColor: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StatCard(
              title: 'Conversion Rate',
              value: '${analytics.conversionRate.toStringAsFixed(1)}%',
              subtitle: 'Won / Total',
              icon: Icons.trending_up,
              trendColor: analytics.conversionRate > 10
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StatCard(
              title: 'Avg Lead Score',
              value: analytics.avgLeadScore.toStringAsFixed(0),
              subtitle: '0–100 scale',
              icon: Icons.speed_outlined,
              trendColor: analytics.avgLeadScore > 50
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StatCard(
              title: 'New Today',
              value: '${analytics.newLeadsToday}',
              subtitle: 'Created today',
              icon: Icons.fiber_new_outlined,
              trendColor: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }
}
