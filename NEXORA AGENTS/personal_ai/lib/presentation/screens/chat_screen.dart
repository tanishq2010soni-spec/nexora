import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/conversation_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConversationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _startNewChat(context),
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.conversations.isEmpty
              ? EmptyState(
                  icon: Icons.chat_outlined,
                  title: 'No conversations yet',
                  subtitle: 'Start a new chat to begin',
                  action: ElevatedButton.icon(
                    onPressed: () => _startNewChat(context),
                    icon: const Icon(Icons.add),
                    label: const Text('New Chat'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: provider.conversations.length,
                  itemBuilder: (context, index) {
                    final conv = provider.conversations[index];
                    return FadeIn(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Material(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => context.go('/chat/${conv.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          conv.title,
                                          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${conv.messages.length} messages',
                                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    color: AppColors.textTertiary,
                                    onPressed: () => _deleteConversation(context, conv.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _startNewChat(BuildContext context) {
    final router = GoRouter.of(context);
    context.read<ConversationProvider>().createConversation().then((conv) {
      if (conv != null && mounted) {
        router.go('/chat/${conv.id}');
      }
    });
  }

  void _deleteConversation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete conversation'),
        content: const Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<ConversationProvider>().deleteConversation(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
