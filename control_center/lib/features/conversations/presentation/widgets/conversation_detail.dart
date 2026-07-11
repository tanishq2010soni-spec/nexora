import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/conversation.dart';
import '../../providers/conversation_provider.dart';
import 'message_timeline.dart';
import 'call_detail.dart';

class ConversationDetail extends ConsumerWidget {
  final Conversation conversation;

  const ConversationDetail({super.key, required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildHeader(context, ref),
        const Divider(height: 1, color: AppColors.surfaceBorder),
        Expanded(
          child: conversation.platform == ConversationPlatform.whatsapp
              ? _buildWhatsAppContent(ref)
              : _buildCallingContent(ref),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _platformColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_platformIcon, size: 20, color: _platformColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      conversation.externalUserId,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPlatformBadge(),
                    const SizedBox(width: AppSpacing.sm),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Agent: ${conversation.agentName}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              AppButton(
                label: 'Resolve',
                variant: AppButtonVariant.secondary,
                isCompact: true,
                icon: Icons.check_circle_outline,
                onPressed: conversation.status == ConversationStatus.active
                    ? () => _resolveConversation(ref)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Archive',
                variant: AppButtonVariant.ghost,
                isCompact: true,
                icon: Icons.archive_outlined,
                onPressed: conversation.status != ConversationStatus.archived
                    ? () => _archiveConversation(ref)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Export',
                variant: AppButtonVariant.ghost,
                isCompact: true,
                icon: Icons.download_outlined,
                onPressed: () => _exportConversation(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppContent(WidgetRef ref) {
    final messagesAsync = ref.watch(
      conversationMessagesProvider(conversation.id),
    );

    return messagesAsync.when(
      loading: () => const MessageTimelineSkeleton(),
      error: (e, _) => Center(
        child: Text(
          'Failed to load messages',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return const Center(
            child: Text(
              'No messages in this conversation',
              style: AppTypography.bodyMedium,
            ),
          );
        }
        return MessageTimeline(messages: messages);
      },
    );
  }

  Widget _buildCallingContent(WidgetRef ref) {
    final callLogsAsync = ref.watch(callLogListProvider);

    return callLogsAsync.when(
      loading: () => const CallDetailSkeleton(),
      error: (e, _) => Center(
        child: Text(
          'Failed to load call details',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (callLogs) {
        final callLog = callLogs
            .where((c) => c.conversationId == conversation.id)
            .firstOrNull;

        if (callLog == null) {
          return const Center(
            child: Text('No call log found', style: AppTypography.bodyMedium),
          );
        }
        return CallDetail(callLog: callLog);
      },
    );
  }

  Widget _buildPlatformBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _platformColor.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        conversation.platform == ConversationPlatform.whatsapp
            ? 'WhatsApp'
            : 'Calling',
        style: AppTypography.labelSmall.copyWith(color: _platformColor),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (color, label) = switch (conversation.status) {
      ConversationStatus.active => (AppColors.success, 'Active'),
      ConversationStatus.resolved => (AppColors.accent, 'Resolved'),
      ConversationStatus.pending => (AppColors.warning, 'Pending'),
      ConversationStatus.archived => (AppColors.textTertiary, 'Archived'),
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

  Color get _platformColor {
    return conversation.platform == ConversationPlatform.whatsapp
        ? AppColors.success
        : AppColors.info;
  }

  IconData get _platformIcon {
    return conversation.platform == ConversationPlatform.whatsapp
        ? Icons.chat_outlined
        : Icons.phone_outlined;
  }

  void _resolveConversation(WidgetRef ref) {
    ref.read(conversationRepositoryProvider).getConversation(conversation.id);
    ref.invalidate(conversationListProvider);
    ref.invalidate(conversationDetailProvider(conversation.id));
  }

  void _archiveConversation(WidgetRef ref) {
    ref.read(conversationRepositoryProvider).getConversation(conversation.id);
    ref.invalidate(conversationListProvider);
    ref.invalidate(conversationDetailProvider(conversation.id));
  }

  void _exportConversation(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting conversation...')));
  }
}

class ConversationDetailSkeleton extends StatelessWidget {
  const ConversationDetailSkeleton({super.key});

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
        const Expanded(child: MessageTimelineSkeleton()),
      ],
    );
  }
}
