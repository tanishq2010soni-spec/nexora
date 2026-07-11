import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/conversation.dart';
import '../../providers/conversation_provider.dart';
import '../widgets/conversation_list.dart';
import '../widgets/conversation_detail.dart';
import '../widgets/conversation_analytics_overview.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  String? _selectedConversationId;

  @override
  Widget build(BuildContext context) {
    final conversationListAsync = ref.watch(conversationListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeftPanel(conversationListAsync),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: _buildRightPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Conversations',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(AsyncValue<List<Conversation>> conversationListAsync) {
    final conversations = conversationListAsync.when(
      loading: () => <Conversation>[],
      error: (_, _) => <Conversation>[],

      data: (data) => data,
    );

    final isLoading = conversationListAsync.isLoading;

    return ConversationList(
      conversations: conversations,
      selectedConversationId: _selectedConversationId,
      isLoading: isLoading,
      onConversationSelected: (id) {
        setState(() => _selectedConversationId = id);
      },
      onSearch: (query) {},
    );
  }

  Widget _buildRightPanel() {
    if (_selectedConversationId == null) {
      return _buildAnalyticsOverview();
    }

    return _buildConversationDetailView();
  }

  Widget _buildAnalyticsOverview() {
    final analyticsAsync = ref.watch(conversationAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const ConversationAnalyticsOverviewSkeleton(),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load analytics',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              e is AppException ? e.message : e.toString(),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      data: (_) => const ConversationAnalyticsOverview(),
    );
  }

  Widget _buildConversationDetailView() {
    final conversationAsync = ref.watch(
      conversationDetailProvider(_selectedConversationId!),
    );

    return conversationAsync.when(
      loading: () => const ConversationDetailSkeleton(),
      error: (e, _) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load conversation',
                style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                e is AppException ? e.message : e.toString(),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: () {
                  ref.invalidate(
                    conversationDetailProvider(_selectedConversationId!),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
      data: (conversation) => ConversationDetail(conversation: conversation),
    );
  }
}
