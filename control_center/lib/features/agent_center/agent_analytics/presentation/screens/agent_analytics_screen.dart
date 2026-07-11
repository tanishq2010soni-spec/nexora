import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/empty_state.dart';
import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/widgets/error_view.dart';
import '../../domain/models/agent_analytics.dart';
import '../../providers/analytics_provider.dart';
import '../widgets/analytics_stat_card.dart';

class AgentAnalyticsScreen extends ConsumerWidget {
  const AgentAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(agentAnalyticsListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agent Analytics',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: analyticsAsync.when(
              loading: () => const AppLoader(),
              error: (err, _) => ErrorView(
                exception: UnknownException(err.toString()),
                onRetry: () => ref.invalidate(agentAnalyticsListProvider),
              ),
              data: (analyticsList) {
                if (analyticsList.isEmpty) {
                  return const EmptyState(
                    icon: Icons.analytics_outlined,
                    title: 'No analytics data',
                    subtitle:
                        'Analytics will appear here once agents start processing',
                  );
                }
                return _AnalyticsContent(analyticsList: analyticsList);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final List<AgentAnalytics> analyticsList;

  const _AnalyticsContent({required this.analyticsList});

  @override
  Widget build(BuildContext context) {
    final totalMessages = analyticsList.fold(
      0,
      (sum, a) => sum + a.totalMessages,
    );
    final totalCalls = analyticsList.fold(0, (sum, a) => sum + a.totalCalls);
    final avgSuccessRate = analyticsList.isEmpty
        ? 0.0
        : analyticsList.fold(0.0, (sum, a) => sum + a.successRate) /
              analyticsList.length;
    final totalLeads = analyticsList.fold(0, (sum, a) => sum + a.totalLeads);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AnalyticsStatCard(
                  label: 'Total Messages',
                  value: totalMessages.toString(),
                  icon: Icons.message_outlined,
                  iconColor: AppColors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AnalyticsStatCard(
                  label: 'Total Calls',
                  value: totalCalls.toString(),
                  icon: Icons.phone_outlined,
                  iconColor: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AnalyticsStatCard(
                  label: 'Average Success Rate',
                  value: '${avgSuccessRate.toStringAsFixed(1)}%',
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AnalyticsStatCard(
                  label: 'Total Leads',
                  value: totalLeads.toString(),
                  icon: Icons.person_add_outlined,
                  iconColor: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Per-Agent Analytics',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                ...analyticsList.map((analytics) => _buildTableRow(analytics)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Agent Name',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Messages',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Calls',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Success Rate',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Avg Response',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(AgentAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              analytics.agentName,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${analytics.totalMessages}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${analytics.totalCalls}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${analytics.successRate.toStringAsFixed(1)}%',
              style: AppTypography.bodyMedium.copyWith(
                color: analytics.successRate >= 80
                    ? AppColors.success
                    : analytics.successRate >= 50
                    ? AppColors.warning
                    : AppColors.error,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${analytics.avgResponseTimeMs.toStringAsFixed(0)}ms',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
