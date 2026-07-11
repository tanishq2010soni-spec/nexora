import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../domain/models/dashboard_stats.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e as dynamic,
        onRetry: () => ref.invalidate(dashboardStatsProvider),
      ),
      data: (stats) => _DashboardContent(stats: stats),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardStats stats;

  const _DashboardContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 1024 ? 3 : 4);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: screenWidth < 600 ? 1.6 : 2.0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SlideFadeIn(
                offset: const Offset(0, 20),
                child: StatCard(
                  title: 'Active Agents',
                  value: '${stats.activeAgents}',
                  subtitle: 'Running now',
                ),
              ),
              SlideFadeIn(
                offset: const Offset(0, 20),
                child: StatCard(
                  title: 'Messages Today',
                  value: '${stats.messagesToday}',
                  subtitle: 'Across all agents',
                ),
              ),
              SlideFadeIn(
                offset: const Offset(0, 20),
                child: StatCard(
                  title: 'Calls Today',
                  value: '${stats.callsToday}',
                  subtitle: 'Voice interactions',
                ),
              ),
              SlideFadeIn(
                offset: const Offset(0, 20),
                child: StatCard(
                  title: 'Leads Generated',
                  value: '${stats.leadsGenerated}',
                  subtitle: 'This week',
                ),
              ),
              SlideFadeIn(
                offset: const Offset(0, 20),
                child: StatCard(
                  title: 'Customers',
                  value: '${stats.customersManaged}',
                  subtitle: 'Managed',
                ),
              ),
              SlideFadeIn(
                offset: const Offset(0, 20),
                child: StatCard(
                  title: 'System Health',
                  value: stats.systemHealth,
                  subtitle: 'All services operational',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _RecentActivity(),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SlideFadeIn(
      offset: const Offset(0, 20),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _ActivityRow(
              icon: Icons.check_circle,
              iconColor: AppColors.success,
              text: 'System health check completed',
              time: '2 min ago',
            ),
            _ActivityRow(
              icon: Icons.person_add,
              iconColor: AppColors.accent,
              text: 'New lead captured from website',
              time: '15 min ago',
            ),
            _ActivityRow(
              icon: Icons.chat,
              iconColor: AppColors.info,
              text: 'Agent Nova resolved customer inquiry',
              time: '1 hour ago',
            ),
            _ActivityRow(
              icon: Icons.call,
              iconColor: AppColors.success,
              text: 'Voice call completed with prospect',
              time: '2 hours ago',
            ),
            _ActivityRow(
              icon: Icons.warning_amber,
              iconColor: AppColors.warning,
              text: 'High priority task assigned',
              time: '3 hours ago',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final String time;

  const _ActivityRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            time,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
