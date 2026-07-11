import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/inbox_conversation.dart';
import '../../domain/models/inbox_message.dart';
import '../../domain/models/customer_side_panel.dart';
import '../../providers/inbox_provider.dart';
import '../widgets/channel_icon.dart';
import '../widgets/message_bubble.dart';
import '../widgets/customer_panel.dart';

class InboxDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const InboxDetailScreen({super.key, required this.conversationId});

  @override
  ConsumerState<InboxDetailScreen> createState() => _InboxDetailScreenState();
}

class _InboxDetailScreenState extends ConsumerState<InboxDetailScreen> {
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
    final detailAsync = ref.watch(
      inboxConversationFullDetailProvider(widget.conversationId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
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
                    inboxConversationFullDetailProvider(widget.conversationId),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (detail) => _buildContent(detail),
      ),
    );
  }

  Widget _buildContent(dynamic detail) {
    final conversation = detail.conversation as InboxConversation;
    final messages = detail.messages as List<InboxMessage>;
    final customer = detail.customer as CustomerSidePanel?;

    return Column(
      children: [
        _buildHeader(conversation),
        const Divider(height: 1, color: AppColors.surfaceBorder),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildMessageThread(messages)),
              const SizedBox(width: 1),
              CustomerPanel(customer: customer),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.surfaceBorder),
        _buildMessageInput(conversation),
      ],
    );
  }

  Widget _buildHeader(InboxConversation conversation) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          ChannelIcon(channel: conversation.channel.name),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      conversation.customerName,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildChannelBadge(conversation.channel),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatusBadge(conversation.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  conversation.assignedToName ?? 'Unassigned',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderActions(conversation),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(InboxConversation conversation) {
    return Row(
      children: [
        _buildTakeoverToggle(conversation),
        const SizedBox(width: AppSpacing.sm),
        _buildAssignmentSelector(conversation),
      ],
    );
  }

  Widget _buildTakeoverToggle(InboxConversation conversation) {
    final isHuman = conversation.takeoverMode == TakeoverMode.human;
    return GestureDetector(
      onTap: () async {
        await ref.read(inboxRepositoryProvider).toggleTakeover(conversation.id);
        ref.invalidate(inboxConversationFullDetailProvider(conversation.id));
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

  Widget _buildAssignmentSelector(InboxConversation conversation) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'agent_1', child: Text('Agent 1')),
        const PopupMenuItem(value: 'agent_2', child: Text('Agent 2')),
        const PopupMenuItem(value: 'agent_3', child: Text('Agent 3')),
      ],
      onSelected: (value) async {
        await ref
            .read(inboxRepositoryProvider)
            .updateConversation(conversation.id, assignedTo: value);
        ref.invalidate(inboxConversationFullDetailProvider(conversation.id));
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

  Widget _buildChannelBadge(InboxChannel channel) {
    final label = switch (channel) {
      InboxChannel.whatsapp => 'WhatsApp',
      InboxChannel.instagram => 'Instagram',
      InboxChannel.facebook => 'Facebook',
      InboxChannel.website => 'Website',
    };
    final color = switch (channel) {
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

  Widget _buildStatusBadge(InboxStatus status) {
    final (color, label) = switch (status) {
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

  Widget _buildMessageThread(List<InboxMessage> messages) {
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

  Widget _buildMessageInput(InboxConversation conversation) {
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
              onSubmitted: (_) => _sendMessage(conversation.id),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: () => _sendMessage(conversation.id),
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

  void _sendMessage(String conversationId) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    await ref
        .read(inboxRepositoryProvider)
        .sendMessage(
          conversationId: conversationId,
          content: content,
          senderType: 'agent',
        );

    ref.invalidate(inboxMessagesProvider(conversationId));
    ref.invalidate(inboxConversationFullDetailProvider(conversationId));
  }
}
