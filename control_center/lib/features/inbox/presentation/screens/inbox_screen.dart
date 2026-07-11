import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../domain/models/inbox_conversation.dart';
import '../../providers/inbox_provider.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/channel_icon.dart';
import '../widgets/message_bubble.dart';
import '../widgets/customer_panel.dart';

enum _ChannelFilter { all, whatsapp, instagram, facebook, website }

enum _StatusFilter { all, open, closed, pending }

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  String? _selectedConversationId;
  _ChannelFilter _channelFilter = _ChannelFilter.all;
  _StatusFilter _statusFilter = _StatusFilter.all;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(inboxConversationListProvider);

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
                _buildLeftPanel(conversationsAsync),
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
          'Inbox',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildLeftPanel(
    AsyncValue<List<InboxConversation>> conversationsAsync,
  ) {
    final conversations = conversationsAsync.when(
      loading: () => <InboxConversation>[],
      error: (_, _) => <InboxConversation>[],
      data: (data) => data,
    );

    final isLoading = conversationsAsync.isLoading;

    return Container(
      width: 380,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          _buildChannelTabs(),
          _buildStatusFilters(),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Expanded(child: _buildConversationItems(conversations, isLoading)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: TextField(
        controller: _searchController,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: AppColors.surfaceHover,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.surfaceBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.surfaceBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildTab('All', _ChannelFilter.all),
          const SizedBox(width: AppSpacing.xs),
          _buildTab('WhatsApp', _ChannelFilter.whatsapp),
          const SizedBox(width: AppSpacing.xs),
          _buildTab('Instagram', _ChannelFilter.instagram),
          const SizedBox(width: AppSpacing.xs),
          _buildTab('Facebook', _ChannelFilter.facebook),
          const SizedBox(width: AppSpacing.xs),
          _buildTab('Website', _ChannelFilter.website),
        ],
      ),
    );
  }

  Widget _buildTab(String label, _ChannelFilter filter) {
    final isSelected = _channelFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _channelFilter = filter),
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
            'Open',
            _StatusFilter.open,
            color: AppColors.success,
          ),
          _buildFilterChip(
            'Closed',
            _StatusFilter.closed,
            color: AppColors.textTertiary,
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

  Widget _buildConversationItems(
    List<InboxConversation> conversations,
    bool isLoading,
  ) {
    if (isLoading) return _buildLoadingSkeleton();

    var filtered = conversations;

    switch (_channelFilter) {
      case _ChannelFilter.whatsapp:
        filtered = filtered
            .where((c) => c.channel == InboxChannel.whatsapp)
            .toList();
      case _ChannelFilter.instagram:
        filtered = filtered
            .where((c) => c.channel == InboxChannel.instagram)
            .toList();
      case _ChannelFilter.facebook:
        filtered = filtered
            .where((c) => c.channel == InboxChannel.facebook)
            .toList();
      case _ChannelFilter.website:
        filtered = filtered
            .where((c) => c.channel == InboxChannel.website)
            .toList();
      case _ChannelFilter.all:
        break;
    }

    switch (_statusFilter) {
      case _StatusFilter.open:
        filtered = filtered.where((c) => c.status == InboxStatus.open).toList();
      case _StatusFilter.closed:
        filtered = filtered
            .where((c) => c.status == InboxStatus.closed)
            .toList();
      case _StatusFilter.pending:
        filtered = filtered
            .where((c) => c.status == InboxStatus.pending)
            .toList();
      case _StatusFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (c) =>
                c.customerName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (c.lastMessage?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    if (filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.textTertiary),
            SizedBox(height: AppSpacing.md),
            Text('No conversations found', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final conversation = filtered[index];
        final isSelected = conversation.id == _selectedConversationId;

        return ConversationTile(
          conversation: conversation,
          isSelected: isSelected,
          onTap: () {
            setState(() => _selectedConversationId = conversation.id);
          },
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

  Widget _buildRightPanel() {
    if (_selectedConversationId == null) {
      return _buildEmptyState();
    }

    return _buildConversationDetailView();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Select a conversation',
            style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose a conversation from the list to view details',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationDetailView() {
    final detailAsync = ref.watch(
      inboxConversationFullDetailProvider(_selectedConversationId!),
    );

    return detailAsync.when(
      loading: () => const _DetailSkeleton(),
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
                    inboxConversationFullDetailProvider(
                      _selectedConversationId!,
                    ),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
      data: (detail) => _InboxDetailContent(
        conversation: detail.conversation,
        messages: detail.messages,
        customer: detail.customer,
      ),
    );
  }
}

class _InboxDetailContent extends ConsumerStatefulWidget {
  final InboxConversation conversation;
  final List messages;
  final dynamic customer;

  const _InboxDetailContent({
    required this.conversation,
    required this.messages,
    this.customer,
  });

  @override
  ConsumerState<_InboxDetailContent> createState() =>
      _InboxDetailContentState();
}

class _InboxDetailContentState extends ConsumerState<_InboxDetailContent> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const Divider(height: 1, color: AppColors.surfaceBorder),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildMessageThread()),
              const SizedBox(width: 1),
              CustomerPanel(customer: widget.customer),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.surfaceBorder),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          ChannelIcon(channel: widget.conversation.channel.name),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.conversation.customerName,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildChannelBadge(),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.conversation.assignedToName ?? 'Unassigned',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildTakeoverToggle(),
        const SizedBox(width: AppSpacing.sm),
        _buildAssignmentSelector(),
        const SizedBox(width: AppSpacing.sm),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildTakeoverToggle() {
    final isHuman = widget.conversation.takeoverMode == TakeoverMode.human;
    return GestureDetector(
      onTap: () async {
        await ref
            .read(inboxRepositoryProvider)
            .toggleTakeover(widget.conversation.id);
        ref.invalidate(
          inboxConversationFullDetailProvider(widget.conversation.id),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: (isHuman ? AppColors.warning : AppColors.success).withAlpha(
            30,
          ),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isHuman ? AppColors.warning : AppColors.success,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isHuman ? Icons.person_outlined : Icons.smart_toy_outlined,
              size: 14,
              color: isHuman ? AppColors.warning : AppColors.success,
            ),
            const SizedBox(width: 4),
            Text(
              isHuman ? 'Human' : 'AI',
              style: AppTypography.labelSmall.copyWith(
                color: isHuman ? AppColors.warning : AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentSelector() {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'agent_1', child: Text('Agent 1')),
        const PopupMenuItem(value: 'agent_2', child: Text('Agent 2')),
        const PopupMenuItem(value: 'agent_3', child: Text('Agent 3')),
      ],
      onSelected: (value) async {
        await ref
            .read(inboxRepositoryProvider)
            .updateConversation(widget.conversation.id, assignedTo: value);
        ref.invalidate(
          inboxConversationFullDetailProvider(widget.conversation.id),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceHover,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Assign',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () async {
        final confirmed = await ConfirmDialog.show(
          context: context,
          title: 'Delete Conversation',
          message: 'Are you sure you want to delete this conversation?',
          confirmLabel: 'Delete',
          isDestructive: true,
        );
        if (confirmed) {
          await ref
              .read(inboxRepositoryProvider)
              .deleteConversation(widget.conversation.id);
          if (context.mounted) {
            ref.invalidate(inboxConversationListProvider);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(20),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.delete_outline,
          size: 14,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildChannelBadge() {
    final label = switch (widget.conversation.channel) {
      InboxChannel.whatsapp => 'WhatsApp',
      InboxChannel.instagram => 'Instagram',
      InboxChannel.facebook => 'Facebook',
      InboxChannel.website => 'Website',
    };
    final color = switch (widget.conversation.channel) {
      InboxChannel.whatsapp => const Color(0xFF25D366),
      InboxChannel.instagram => const Color(0xFFE4405F),
      InboxChannel.facebook => const Color(0xFF1877F2),
      InboxChannel.website => AppColors.accent,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (color, label) = switch (widget.conversation.status) {
      InboxStatus.open => (AppColors.success, 'Open'),
      InboxStatus.closed => (AppColors.textTertiary, 'Closed'),
      InboxStatus.pending => (AppColors.warning, 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildMessageThread() {
    final messages = widget.messages;

    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages in this conversation',
          style: AppTypography.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageBubble(message: messages[index]);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.surfaceHover,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.send, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    await ref
        .read(inboxRepositoryProvider)
        .sendMessage(
          conversationId: widget.conversation.id,
          content: content,
          senderType: 'agent',
        );

    ref.invalidate(inboxMessagesProvider(widget.conversation.id));
    ref.invalidate(inboxConversationFullDetailProvider(widget.conversation.id));
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 80,
          color: AppColors.surface,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHover,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHover,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHover,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.surfaceBorder),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}
