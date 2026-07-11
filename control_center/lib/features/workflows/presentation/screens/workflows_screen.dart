import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/workflow_model.dart';
import '../../providers/workflows_provider.dart';
import '../widgets/workflow_tile.dart';
import 'workflow_detail_screen.dart';

class WorkflowsScreen extends ConsumerStatefulWidget {
  const WorkflowsScreen({super.key});

  @override
  ConsumerState<WorkflowsScreen> createState() => _WorkflowsScreenState();
}

class _WorkflowsScreenState extends ConsumerState<WorkflowsScreen> {
  @override
  Widget build(BuildContext context) {
    final workflowsAsync = ref.watch(workflowsListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: workflowsAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => ErrorView(
                exception: e is AppException
                    ? e
                    : UnknownException(e.toString()),
                onRetry: () => ref.invalidate(workflowsListProvider),
              ),
              data: (workflows) {
                if (workflows.isEmpty) {
                  return EmptyState(
                    icon: Icons.account_tree_outlined,
                    title: 'No Workflows',
                    subtitle: 'Create your first workflow to automate tasks.',
                    action: AppButton(
                      label: 'Create Workflow',
                      icon: Icons.add,
                      onPressed: () => _showCreateWorkflowDialog(context, ref),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: workflows.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final workflow = workflows[index];
                    return WorkflowTile(
                      workflow: workflow,
                      onTap: () => _openWorkflowDetail(workflow),
                      onToggle: () => _toggleWorkflow(workflow),
                      onDelete: () =>
                          _confirmDeleteWorkflow(context, ref, workflow),
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

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Workflow Automation',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        AppButton(
          label: 'Create Workflow',
          icon: Icons.add,
          onPressed: () => _showCreateWorkflowDialog(context, ref),
        ),
      ],
    );
  }

  void _openWorkflowDetail(WorkflowModel workflow) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkflowDetailScreen(workflow: workflow),
      ),
    );
  }

  void _toggleWorkflow(WorkflowModel workflow) {
    ref.read(
      updateWorkflowProvider((
        id: workflow.id,
        name: null,
        description: null,
        triggerType: null,
        isActive: !workflow.isActive,
      )),
    );
    ref.invalidate(workflowsListProvider);
  }

  void _showCreateWorkflowDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    WorkflowTriggerType selectedTrigger = WorkflowTriggerType.manual;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: Text(
            'Create Workflow',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: nameController, hint: 'Workflow name'),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: descController,
                hint: 'Description (optional)',
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<WorkflowTriggerType>(
                initialValue: selectedTrigger,
                dropdownColor: AppColors.surface,
                decoration: InputDecoration(
                  labelText: 'Trigger Type',
                  labelStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.surfaceBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.surfaceBorder,
                    ),
                  ),
                ),
                items: WorkflowTriggerType.values.map((type) {
                  final label = switch (type) {
                    WorkflowTriggerType.newLead => 'New Lead',
                    WorkflowTriggerType.customerReplied => 'Customer Replied',
                    WorkflowTriggerType.callMissed => 'Call Missed',
                    WorkflowTriggerType.appointmentBooked =>
                      'Appointment Booked',
                    WorkflowTriggerType.manual => 'Manual',
                  };
                  return DropdownMenuItem(value: type, child: Text(label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedTrigger = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              label: 'Create',
              onPressed: () async {
                await ref.read(
                  createWorkflowProvider((
                    name: nameController.text,
                    description: descController.text.isEmpty
                        ? null
                        : descController.text,
                    triggerType: selectedTrigger,
                  )).future,
                );
                ref.invalidate(workflowsListProvider);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteWorkflow(
    BuildContext context,
    WidgetRef ref,
    WorkflowModel workflow,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Delete Workflow',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${workflow.name}"? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: 'Delete',
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(deleteWorkflowProvider(workflow.id).future);
      ref.invalidate(workflowsListProvider);
    }
  }
}
