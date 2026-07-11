import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/error_view.dart';
import '../../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics Center',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(executiveDashboardProvider);
                  ref.invalidate(revenueAnalyticsProvider);
                  ref.invalidate(leadAnalyticsProvider);
                  ref.invalidate(customerAnalyticsProvider);
                  ref.invalidate(conversationAnalyticsProvider);
                  ref.invalidate(callAnalyticsProvider);
                  ref.invalidate(agentAnalyticsProvider);
                  ref.invalidate(aiPerformanceProvider);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: DefaultTabController(
              length: 6,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    labelColor: AppColors.accent,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTypography.labelMedium,
                    unselectedLabelStyle: AppTypography.labelMedium,
                    indicatorColor: AppColors.accent,
                    dividerColor: AppColors.surfaceBorder,
                    tabs: const [
                      Tab(text: 'Executive'),
                      Tab(text: 'Leads'),
                      Tab(text: 'Customers'),
                      Tab(text: 'Conversations'),
                      Tab(text: 'Calls'),
                      Tab(text: 'AI Performance'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _ExecutiveTab(),
                        _LeadsTab(),
                        _CustomersTab(),
                        _ConversationsTab(),
                        _CallsTab(),
                        _AiPerformanceTab(),
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
}

class _ExecutiveTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(executiveDashboardProvider);

    return dashboardAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(executiveDashboardProvider),
      ),
      data: (data) {
        final s = data.summary;
        final k = data.kpis;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overview',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              _statGrid([
                _StatData('Total Leads', '${s.totalLeads}', Icons.person_add),
                _StatData(
                  'Converted',
                  '${s.leadsConverted}',
                  Icons.check_circle,
                ),
                _StatData('Customers', '${s.totalCustomers}', Icons.people),
                _StatData('Agents', '${s.totalAgents}', Icons.smart_toy),
                _StatData(
                  'Conversations',
                  '${s.totalConversations}',
                  Icons.chat_bubble,
                ),
                _StatData(
                  'Open',
                  '${s.openConversations}',
                  Icons.mark_chat_unread,
                ),
                _StatData(
                  'Messages Today',
                  '${s.messagesToday}',
                  Icons.message,
                ),
                _StatData('Calls', '${s.totalCalls}', Icons.phone),
                _StatData('Tasks', '${s.totalTasks}', Icons.task_alt),
                _StatData('Pending', '${s.pendingTasks}', Icons.pending),
                _StatData(
                  'Workflows',
                  '${s.activeWorkflows}',
                  Icons.account_tree,
                ),
                _StatData(
                  'Calls This Week',
                  '${s.callsThisWeek}',
                  Icons.phone_in_talk,
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Key Performance Indicators',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              _KpiCard(
                title: 'Lead Conversion Rate',
                value: '${k.leadConversionRate}%',
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.sm),
              _KpiCard(
                title: 'Avg Response Time',
                value: '${k.avgResponseTimeSeconds}s',
                color: AppColors.info,
              ),
              const SizedBox(height: AppSpacing.sm),
              _KpiCard(
                title: 'Agent Utilization',
                value: '${k.agentUtilizationRate}%',
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.sm),
              _KpiCard(
                title: 'AI Resolution Rate',
                value: '${k.aiResolutionRate}%',
                color: AppColors.accent,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statGrid(List<_StatData> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat.icon, size: 20, color: AppColors.accent),
              const SizedBox(height: AppSpacing.sm),
              Text(
                stat.value,
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                stat.title,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  _StatData(this.title, this.value, this.icon);
}

class _LeadsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(leadAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(leadAnalyticsProvider),
      ),
      data: (data) {
        final total = data['total_leads'] ?? 0;
        final recent = data['recent_leads'] ?? 0;
        final converted = data['converted_leads'] ?? 0;
        final convRate = data['conversion_rate'] ?? 0.0;
        final avgScore = data['avg_score'] ?? 0.0;
        final statusBreakdown = Map<String, dynamic>.from(
          data['status_breakdown'] ?? {},
        );
        final sourceBreakdown = Map<String, dynamic>.from(
          data['source_breakdown'] ?? {},
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lead Analytics',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              _kpiRow([
                _KpiData('Total Leads', '$total'),
                _KpiData('Recent', '$recent'),
                _KpiData('Converted', '$converted'),
                _KpiData('Conv. Rate', '$convRate%'),
                _KpiData('Avg Score', '$avgScore'),
              ]),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Status Breakdown',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...statusBreakdown.entries.map(
                (e) => _breakdownTile(e.key, e.value, AppColors.accent),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Source Breakdown',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...sourceBreakdown.entries.map(
                (e) => _breakdownTile(e.key, e.value, AppColors.info),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(customerAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(customerAnalyticsProvider),
      ),
      data: (data) {
        final total = data['total_customers'] ?? 0;
        final newPeriod = data['new_this_period'] ?? 0;
        final active = data['active_customers'] ?? 0;
        final retention = data['retention_rate'] ?? 0.0;
        final ltv = data['avg_lifetime_value'] ?? 0.0;
        final segments = Map<String, dynamic>.from(
          data['segment_breakdown'] ?? {},
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Analytics',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              _kpiRow([
                _KpiData('Total', '$total'),
                _KpiData('New', '$newPeriod'),
                _KpiData('Active', '$active'),
                _KpiData('Retention', '$retention%'),
                _KpiData('Avg LTV', '$ltv'),
              ]),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Segment Breakdown',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...segments.entries.map(
                (e) => _breakdownTile(e.key, e.value, AppColors.accent),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConversationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(conversationAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(conversationAnalyticsProvider),
      ),
      data: (data) {
        final total = data['total_conversations'] ?? 0;
        final totalMsgs = data['total_messages'] ?? 0;
        final recentMsgs = data['recent_messages'] ?? 0;
        final avgMsgs = data['avg_messages_per_conversation'] ?? 0.0;
        final aiRate = data['ai_resolution_rate'] ?? 0.0;
        final resolutionRate = data['resolution_rate'] ?? 0.0;
        final firstResponse = data['avg_first_response_seconds'] ?? 0.0;
        final channels = Map<String, dynamic>.from(
          data['channel_breakdown'] ?? {},
        );
        final statuses = Map<String, dynamic>.from(
          data['status_breakdown'] ?? {},
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conversation Analytics',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              _kpiRow([
                _KpiData('Total', '$total'),
                _KpiData('Messages', '$totalMsgs'),
                _KpiData('Recent', '$recentMsgs'),
                _KpiData('Avg Msgs', '$avgMsgs'),
                _KpiData('AI Rate', '$aiRate%'),
                _KpiData('Resolution', '$resolutionRate%'),
                _KpiData('1st Response', '${firstResponse}s'),
              ]),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Channels',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...channels.entries.map(
                (e) => _breakdownTile(e.key, e.value, AppColors.info),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Statuses',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...statuses.entries.map(
                (e) => _breakdownTile(e.key, e.value, AppColors.warning),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CallsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(callAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(callAnalyticsProvider),
      ),
      data: (data) {
        final total = data['total_calls'] ?? 0;
        final inbound = data['inbound_calls'] ?? 0;
        final outbound = data['outbound_calls'] ?? 0;
        final completed = data['completed_calls'] ?? 0;
        final missed = data['missed_calls'] ?? 0;
        final answerRate = data['answer_rate'] ?? 0.0;
        final avgDuration = data['avg_duration_seconds'] ?? 0;
        final sentiment = Map<String, dynamic>.from(
          data['sentiment_breakdown'] ?? {},
        );
        final outcomes = Map<String, dynamic>.from(
          data['outcome_breakdown'] ?? {},
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Call Analytics',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              _kpiRow([
                _KpiData('Total', '$total'),
                _KpiData('Inbound', '$inbound'),
                _KpiData('Outbound', '$outbound'),
                _KpiData('Completed', '$completed'),
                _KpiData('Missed', '$missed'),
                _KpiData('Answer Rate', '$answerRate%'),
                _KpiData('Avg Duration', '${avgDuration}s'),
              ]),
              const SizedBox(height: AppSpacing.xl),
              if (sentiment.isNotEmpty) ...[
                Text(
                  'Sentiment',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...sentiment.entries.map(
                  (e) => _breakdownTile(e.key, e.value, AppColors.success),
                ),
              ],
              if (outcomes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Outcomes',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...outcomes.entries.map(
                  (e) => _breakdownTile(e.key, e.value, AppColors.warning),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AiPerformanceTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiAsync = ref.watch(aiPerformanceProvider);

    return aiAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(aiPerformanceProvider),
      ),
      data: (data) {
        final botMsgs = data['total_bot_messages'] ?? 0;
        final userMsgs = data['total_user_messages'] ?? 0;
        final sessions = data['total_sessions'] ?? 0;
        final successRate = data['success_rate'] ?? 0.0;
        final avgLen = data['avg_response_length'] ?? 0;
        final models = Map<String, dynamic>.from(data['model_breakdown'] ?? {});
        final wfExecs = data['workflow_executions'] ?? 0;
        final wfRate = data['workflow_success_rate'] ?? 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Performance',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.lg),
              _kpiRow([
                _KpiData('Bot Messages', '$botMsgs'),
                _KpiData('User Messages', '$userMsgs'),
                _KpiData('Sessions', '$sessions'),
                _KpiData('Success Rate', '$successRate%'),
                _KpiData('Avg Length', '$avgLen'),
              ]),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Workflow Execution',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              _KpiCard(
                title: 'Workflow Executions',
                value: '$wfExecs',
                color: AppColors.accent,
              ),
              const SizedBox(height: AppSpacing.sm),
              _KpiCard(
                title: 'Workflow Success Rate',
                value: '$wfRate%',
                color: AppColors.success,
              ),
              if (models.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Models',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...models.entries.map(
                  (e) => _breakdownTile(e.key, e.value, AppColors.info),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

Widget _kpiRow(List<_KpiData> kpis) {
  return Wrap(
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.md,
    children: kpis
        .map(
          (kpi) => SizedBox(
            width: 140,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kpi.value,
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kpi.label,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _KpiData {
  final String label;
  final String value;
  _KpiData(this.label, this.value);
}

Widget _breakdownTile(String label, dynamic value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$value',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.analytics, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(value, style: AppTypography.h4.copyWith(color: color)),
        ],
      ),
    );
  }
}
