import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/confirm_dialog.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_view.dart';

import '../../domain/models/whatsapp_agent.dart';
import '../../providers/whatsapp_agent_provider.dart';
import '../widgets/whatsapp_agent_card.dart';
import '../widgets/whatsapp_agent_form.dart';

class WhatsAppAgentsScreen extends ConsumerWidget {
  const WhatsAppAgentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(whatsappAgentListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WhatsApp Agents',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              AppButton(
                label: 'Create Agent',
                icon: Icons.add,
                onPressed: () => _showCreateForm(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: agentsAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => ErrorView(
                exception: e as dynamic,
                onRetry: () => ref.invalidate(whatsappAgentListProvider),
              ),
              data: (agents) {
                if (agents.isEmpty) {
                  return EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No WhatsApp Agents',
                    subtitle:
                        'Create your first WhatsApp agent to get started.',
                    action: AppButton(
                      label: 'Create Agent',
                      icon: Icons.add,
                      onPressed: () => _showCreateForm(context, ref),
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: agents.length,
                  itemBuilder: (context, index) {
                    final agent = agents[index];
                    return WhatsAppAgentCard(
                      agent: agent,
                      onEdit: () => _showEditForm(context, ref, agent),
                      onDelete: () => _confirmDelete(context, ref, agent),
                      onToggle: (enabled) =>
                          _toggleStatus(ref, agent.id, enabled),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => WhatsAppAgentForm(
        title: 'Create WhatsApp Agent',
        onSave: (agent) async {
          await ref.read(createWhatsAppAgentProvider(agent).future);
          ref.invalidate(whatsappAgentListProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditForm(BuildContext context, WidgetRef ref, WhatsAppAgent agent) {
    showDialog(
      context: context,
      builder: (_) => WhatsAppAgentForm(
        title: 'Edit WhatsApp Agent',
        agent: agent,
        onSave: (updatedAgent) async {
          await ref.read(
            updateWhatsAppAgentProvider((
              id: agent.id,
              agent: updatedAgent,
            )).future,
          );
          ref.invalidate(whatsappAgentListProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WhatsAppAgent agent,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Agent',
      message: 'Are you sure you want to delete "${agent.name}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await ref.read(deleteWhatsAppAgentProvider(agent.id).future);
      ref.invalidate(whatsappAgentListProvider);
    }
  }

  void _toggleStatus(WidgetRef ref, String id, bool enabled) {
    ref.read(toggleWhatsAppAgentStatusProvider((id: id, enabled: enabled)));
    ref.invalidate(whatsappAgentListProvider);
  }
}
