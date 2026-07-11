import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/models/conversation.dart';
import '../../providers/conversation_provider.dart';

class ConversationAnalyticsOverview extends ConsumerWidget {
  const ConversationAnalyticsOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(conversationAnalyticsProvider);
    final conversationListAsync = ref.watch(conversationListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Overview',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildStatCards(analyticsAsync),
          const SizedBox(height: AppSpacing.xl),
          _buildRecentConversations(conversationListAsync),
        ],
      ),
    );
  }

  Widget _buildStatCards(AsyncValue analyticsAsync) {
    return analyticsAsync.when(
      loading: () => const SizedBox(height: 100, child: AppLoader()),
      error: (e, _) => const SizedBox(height: 40),
      data: (analytics) => Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: [
          SizedBox(
            width: 220,
            child: StatCard(
              title: 'Messages Today',
              value: '${analytics.messagesToday}',
              subtitle: 'Across all conversations',
              icon: Icons.message_outlined,
              trendColor: AppColors.accent,
            ),
          ),
          SizedBox(
            width: 220,
            child: StatCard(
              title: 'Calls Today',
              value: '${analytics.callsToday}',
              subtitle: 'Voice interactions',
              icon: Icons.phone_outlined,
              trendColor: AppColors.info,
            ),
          ),
          SizedBox(
            width: 220,
            child: StatCard(
              title: 'Active Conversations',
              value: '${analytics.activeConversations}',
              subtitle: '${analytics.pendingConversations} pending',
              icon: Icons.chat_bubble_outline,
              trendColor: AppColors.success,
            ),
          ),
          SizedBox(
            width: 220,
            child: StatCard(
              title: 'Resolution Rate',
              value: '${analytics.resolutionRate.toStringAsFixed(1)}%',
              subtitle: '${analytics.resolvedToday} resolved today',
              icon: Icons.check_circle_outline,
              trendColor: analytics.resolutionRate >= 80
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
          SizedBox(
            width: 220,
            child: StatCard(
              title: 'Avg Response Time',
              value: '${analytics.avgResponseTimeMs.toStringAsFixed(0)}ms',
              subtitle: 'Average first response',
              icon: Icons.timer_outlined,
              trendColor: analytics.avgResponseTimeMs <= 2000
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentConversations(
    AsyncValue<List<Conversation>> conversationListAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Conversations',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        conversationListAsync.when(
          loading: () => const SizedBox(height: 200, child: AppLoader()),
          error: (e, _) => const SizedBox(height: 40),
          data: (conversations) {
            if (conversations.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Center(
                  child: Text(
                    'No recent conversations',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              );
            }

            final recent = conversations.take(5).toList();

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  _buildTableHeader(),
                  ...recent.map(
                    (conversation) => _buildConversationRow(conversation),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Agent',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Platform',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
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
            flex: 3,
            child: Text(
              'Last Activity',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationRow(Conversation conversation) {
    final platformColor = conversation.platform == ConversationPlatform.whatsapp
        ? AppColors.success
        : AppColors.info;

    final (statusColor, statusLabel) = switch (conversation.status) {
      ConversationStatus.active => (AppColors.success, 'Active'),
      ConversationStatus.resolved => (AppColors.accent, 'Resolved'),
      ConversationStatus.pending => (AppColors.warning, 'Pending'),
      ConversationStatus.archived => (AppColors.textTertiary, 'Archived'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              conversation.agentName,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: platformColor.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                conversation.platform == ConversationPlatform.whatsapp
                    ? 'WhatsApp'
                    : 'Calling',
                style: AppTypography.labelSmall.copyWith(color: platformColor),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  statusLabel,
                  style: AppTypography.labelMedium.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${conversation.messageCount}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatTimestamp(
                conversation.lastMessageAt ?? conversation.updatedAt,
              ),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(date);
  }
}

class ConversationAnalyticsOverviewSkeleton extends StatelessWidget {
  const ConversationAnalyticsOverviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 180,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.surfaceHover,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: List.generate(
              5,
              (index) => SizedBox(
                width: 220,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHover,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
