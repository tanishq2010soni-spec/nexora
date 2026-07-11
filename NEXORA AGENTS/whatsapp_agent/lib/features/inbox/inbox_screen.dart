import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_loader.dart';
import '../../providers/conversation_provider.dart';
import 'widgets/conversation_list_item.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input.dart';
import 'widgets/customer_info_panel.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _searchController = TextEditingController();
  String _filterMode = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationProvider>().loadConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConversationProvider>();
    final conversations = provider.filteredConversations;

    return Container(
      color: AppColors.scaffoldBackground,
      child: Row(
        children: [
          _buildConversationList(provider, conversations),
          if (provider.selectedConversation != null)
            _buildChatArea(provider)
          else
            _buildEmptyChat(),
          if (provider.selectedConversation != null)
            CustomerInfoPanel(conversation: provider.selectedConversation!),
        ],
      ),
    );
  }

  Widget _buildConversationList(ConversationProvider provider, List conversations) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          right: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          Expanded(
            child: provider.isLoading
                ? const AppLoader()
                : conversations.isEmpty
                    ? Center(
                        child: Text(
                          'No conversations found',
                          style: AppTypography.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: conversations.length,
                        itemExtent: 76,
                        itemBuilder: (context, index) {
                          final conv = conversations[index];
                          return ConversationListItem(
                            conversation: conv,
                            isSelected: provider.selectedConversation?.id == conv.id,
                            onTap: () => provider.selectConversation(conv.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.inputBg,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.inputFocusedBorder),
          ),
        ),
        onChanged: (value) {
          context.read<ConversationProvider>().setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['all', 'unread', 'assigned', 'ai'];
    final labels = ['All', 'Unread', 'Assigned', 'AI'];
    final provider = context.watch<ConversationProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isActive = _filterMode == filters[index];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _filterMode = filters[index]);
                switch (filters[index]) {
                  case 'unread':
                    provider.setStatusFilter('unread');
                    break;
                  case 'assigned':
                    provider.setStatusFilter('assigned');
                    break;
                  default:
                    provider.setStatusFilter('');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: isActive
                      ? const Border(
                          bottom: BorderSide(color: AppColors.primary, width: 2),
                        )
                      : null,
                ),
                child: Text(
                  labels[index],
                  style: AppTypography.labelLarge.copyWith(
                    color: isActive ? AppColors.textPrimary : AppColors.textMuted,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChatArea(ConversationProvider provider) {
    final conversation = provider.selectedConversation!;
    return Expanded(
      child: Column(
        children: [
          _buildChatHeader(conversation, provider),
          Expanded(
            child: provider.messages.isEmpty
                ? Center(child: Text('No messages yet', style: AppTypography.bodyMedium))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: provider.messages[index]);
                    },
                  ),
          ),
          _buildAIStatusBar(conversation, provider),
          MessageInput(
            onSend: (text) => provider.sendMessage(conversation.id, text),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader(dynamic conversation, ConversationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              conversation.initials,
              style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conversation.displayName, style: AppTypography.titleMedium),
                Text(
                  conversation.isAIActive ? 'AI Active' : 'Human Handoff',
                  style: AppTypography.bodySmall.copyWith(
                    color: conversation.isAIActive ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 18),
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildAIStatusBar(dynamic conversation, ConversationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          Icon(
            conversation.isAIActive ? Icons.smart_toy_rounded : Icons.person_rounded,
            size: 16,
            color: conversation.isAIActive ? AppColors.aiIndicator : AppColors.handoffHuman,
          ),
          const SizedBox(width: 8),
          Text(
            conversation.isAIActive ? 'AI Assistant is active' : 'Human agent handling',
            style: AppTypography.bodySmall.copyWith(
              color: conversation.isAIActive ? AppColors.aiIndicator : AppColors.handoffHuman,
            ),
          ),
          const Spacer(),
          if (conversation.isAIActive)
            TextButton(
              onPressed: () => provider.requestHandoff(conversation.id),
              child: const Text('Request Human', style: TextStyle(fontSize: 11, color: AppColors.warning)),
            )
          else
            TextButton(
              onPressed: () => provider.resumeAI(conversation.id),
              child: const Text('Resume AI', style: TextStyle(fontSize: 11, color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Select a conversation', style: AppTypography.bodyLarge),
            const SizedBox(height: 8),
            Text('Choose a conversation from the left panel', style: AppTypography.bodyMedium),
          ],
        ),
      ),
    );
  }
}
