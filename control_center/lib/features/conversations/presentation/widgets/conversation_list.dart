import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/conversation.dart';
import 'conversation_search_bar.dart';

enum _PlatformFilter { all, whatsapp, calling }

enum _StatusFilter { all, active, resolved, pending }

class ConversationList extends StatefulWidget {
  final List<Conversation> conversations;
  final String? selectedConversationId;
  final ValueChanged<String> onConversationSelected;
  final ValueChanged<String> onSearch;
  final bool isLoading;

  const ConversationList({
    super.key,
    required this.conversations,
    this.selectedConversationId,
    required this.onConversationSelected,
    required this.onSearch,
    this.isLoading = false,
  });

  @override
  State<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  _PlatformFilter _platformFilter = _PlatformFilter.all;
  _StatusFilter _statusFilter = _StatusFilter.all;

  List<Conversation> get _filteredConversations {
    var filtered = widget.conversations;

    switch (_platformFilter) {
      case _PlatformFilter.whatsapp:
        filtered = filtered
            .where((c) => c.platform == ConversationPlatform.whatsapp)
            .toList();
      case _PlatformFilter.calling:
        filtered = filtered
            .where((c) => c.platform == ConversationPlatform.calling)
            .toList();
      case _PlatformFilter.all:
        break;
    }

    switch (_statusFilter) {
      case _StatusFilter.active:
        filtered = filtered
            .where((c) => c.status == ConversationStatus.active)
            .toList();
      case _StatusFilter.resolved:
        filtered = filtered
            .where((c) => c.status == ConversationStatus.resolved)
            .toList();
      case _StatusFilter.pending:
        filtered = filtered
            .where((c) => c.status == ConversationStatus.pending)
            .toList();
      case _StatusFilter.all:
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          _buildPlatformTabs(),
          _buildStatusFilters(),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Expanded(child: _buildConversationItems()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ConversationSearchBar(onSearch: widget.onSearch),
    );
  }

  Widget _buildPlatformTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildTab('All', _PlatformFilter.all),
          const SizedBox(width: AppSpacing.xs),
          _buildTab('WhatsApp', _PlatformFilter.whatsapp),
          const SizedBox(width: AppSpacing.xs),
          _buildTab('Calling', _PlatformFilter.calling),
        ],
      ),
    );
  }

  Widget _buildTab(String label, _PlatformFilter filter) {
    final isSelected = _platformFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _platformFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha(30)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _buildFilterChip('All', _StatusFilter.all),
          _buildFilterChip(
            'Active',
            _StatusFilter.active,
            color: AppColors.success,
          ),
          _buildFilterChip(
            'Resolved',
            _StatusFilter.resolved,
            color: AppColors.accent,
          ),
          _buildFilterChip(
            'Pending',
            _StatusFilter.pending,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, _StatusFilter filter, {Color? color}) {
    final isSelected = _statusFilter == filter;
    final chipColor = color ?? AppColors.accent;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withAlpha(30) : AppColors.surfaceHover,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? chipColor : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItems() {
    if (widget.isLoading) {
      return _buildLoadingSkeleton();
    }

    final conversations = _filteredConversations;

    if (conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text('No conversations found', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final isSelected = conversation.id == widget.selectedConversationId;

        return _ConversationItem(
          conversation: conversation,
          isSelected: isSelected,
          onTap: () => widget.onConversationSelected(conversation.id),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 3,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceHover,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100 + (index * 20) % 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 160 + (index * 15) % 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationItem({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 3,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopRow(),
                  const SizedBox(height: 4),
                  _buildMessagePreview(),
                ],
              ),
            ),
            _buildRightColumn(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final color = conversation.platform == ConversationPlatform.whatsapp
        ? AppColors.success
        : AppColors.info;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        conversation.platform == ConversationPlatform.whatsapp
            ? Icons.chat_outlined
            : Icons.phone_outlined,
        size: 18,
        color: color,
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            conversation.agentName,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatusDot(),
      ],
    );
  }

  Widget _buildMessagePreview() {
    return Text(
      conversation.lastMessagePreview ?? 'No messages',
      style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatTimestamp(
            conversation.lastMessageAt ?? conversation.updatedAt,
          ),
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        _buildPlatformBadge(),
      ],
    );
  }

  Widget _buildPlatformBadge() {
    final isWhatsapp = conversation.platform == ConversationPlatform.whatsapp;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: (isWhatsapp ? AppColors.success : AppColors.info).withAlpha(30),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        isWhatsapp ? 'WA' : 'CALL',
        style: AppTypography.labelSmall.copyWith(
          fontSize: 9,
          color: isWhatsapp ? AppColors.success : AppColors.info,
        ),
      ),
    );
  }

  Widget _buildStatusDot() {
    final color = switch (conversation.status) {
      ConversationStatus.active => AppColors.success,
      ConversationStatus.resolved => AppColors.accent,
      ConversationStatus.pending => AppColors.warning,
      ConversationStatus.archived => AppColors.textTertiary,
    };

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return DateFormat('MMM d').format(date);
  }
}
