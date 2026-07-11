import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/workflow_provider.dart';
import '../../models/workflow.dart';

class WorkflowsScreen extends StatefulWidget {
  const WorkflowsScreen({super.key});

  @override
  State<WorkflowsScreen> createState() => _WorkflowsScreenState();
}

class _WorkflowsScreenState extends State<WorkflowsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkflowProvider>().loadWorkflows();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkflowProvider>();
    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        children: [
          _buildHeader(provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.workflows.isEmpty
                    ? const EmptyState(icon: Icons.alt_route_rounded, title: 'No workflows yet', subtitle: 'Create your first automation workflow', actionLabel: 'Create Workflow')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.workflows.length,
                        itemBuilder: (context, index) => _buildWorkflowCard(provider, provider.workflows[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WorkflowProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workflows', style: AppTypography.displaySmall),
                const SizedBox(height: 4),
                Text('Automate conversations and lead management', style: AppTypography.bodyMedium),
              ],
            ),
          ),
          AppButton(
            label: 'Create Workflow',
            icon: Icons.add,
            onPressed: () => _showWorkflowDialog(context, provider, null),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowCard(WorkflowProvider provider, Workflow workflow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alt_route_rounded, size: 20, color: workflow.isActive ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workflow.name, style: AppTypography.headlineSmall),
                    if (workflow.description != null)
                      Text(workflow.description!, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              _badge(workflow.triggerLabel, AppColors.info),
              const SizedBox(width: 8),
              _badge(workflow.isActive ? 'Active' : 'Paused', workflow.isActive ? AppColors.success : AppColors.warning),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem('${workflow.steps.length}', 'Steps'),
              const SizedBox(width: 24),
              _statItem('${workflow.executionCount}', 'Executions'),
              const SizedBox(width: 24),
              _statItem(workflow.lastRunAt?.toString().split('T').first ?? 'Never', 'Last Run'),
              const Spacer(),
              AppButton(
                label: 'Edit',
                variant: AppButtonVariant.outline,
                onPressed: () => _showWorkflowDialog(context, provider, workflow),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: workflow.isActive ? 'Pause' : 'Activate',
                variant: AppButtonVariant.ghost,
                onPressed: () {
                  provider.updateWorkflow(workflow.id, {'is_active': !workflow.isActive});
                },
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'Test',
                variant: AppButtonVariant.text,
                onPressed: () async {
                  final result = await provider.testWorkflow(workflow.id);
                  if (result != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Test completed: ${result['status'] ?? 'ok'}')),
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'History',
                variant: AppButtonVariant.text,
                onPressed: () => _showExecutionHistory(context, provider, workflow),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }

  void _showWorkflowDialog(BuildContext context, WorkflowProvider provider, Workflow? workflow) {
    final nameCtrl = TextEditingController(text: workflow?.name ?? '');
    final descCtrl = TextEditingController(text: workflow?.description ?? '');
    String triggerType = workflow?.triggerType ?? 'manual';
    List<Map<String, dynamic>> steps = workflow?.steps.map((s) => {'type': s.type, 'config': Map<String, dynamic>.from(s.config)}).toList() ?? [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workflow != null ? 'Edit Workflow' : 'Create Workflow', style: AppTypography.displaySmall),
                const SizedBox(height: 20),
                AppTextField(label: 'Name *', hint: 'Workflow name', controller: nameCtrl),
                const SizedBox(height: 12),
                AppTextField(label: 'Description', hint: 'What does this workflow do?', controller: descCtrl, maxLines: 2),
                const SizedBox(height: 12),
                _buildDropdown('Trigger Type', triggerType, ['manual', 'incoming_message', 'lead_created', 'scheduled', 'campaign_completed'],
                    (v) => setDialogState(() => triggerType = v!), ctx),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Steps (${steps.length})', style: AppTypography.titleMedium),
                    const Spacer(),
                    AppButton(label: 'Add Step', icon: Icons.add, variant: AppButtonVariant.outline, onPressed: () {
                      setDialogState(() => steps.add({'type': 'send_message', 'config': <String, dynamic>{}}));
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: steps.isEmpty
                      ? Center(child: Text('No steps yet', style: AppTypography.bodyMedium))
                      : ReorderableListView.builder(
                          itemCount: steps.length,
                          onReorderItem: (oldIndex, newIndex) => setDialogState(() {
                            final item = steps.removeAt(oldIndex);
                            steps.insert(newIndex, item);
                          }),
                          itemBuilder: (ctx, i) {
                            final step = steps[i];
                            return Container(
                              key: ValueKey('step_$i'),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.inputBorder)),
                              child: Row(
                                children: [
                                  const Icon(Icons.drag_handle_rounded, size: 18, color: AppColors.textMuted),
                                  const SizedBox(width: 8),
                                  Text('${i + 1}.', style: AppTypography.bodyMedium),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: step['type'] as String,
                                        isExpanded: true,
                                        dropdownColor: AppColors.surfaceCard,
                                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                        items: ['send_message', 'update_lead', 'assign_agent', 'add_tag', 'webhook', 'condition']
                                            .map((t) => DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '))))
                                            .toList(),
                                        onChanged: (v) => setDialogState(() => step['type'] = v!),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                                    onPressed: () => setDialogState(() => steps.removeAt(i)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(label: 'Cancel', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(ctx)),
                    const SizedBox(width: 12),
                    AppButton(label: workflow != null ? 'Update' : 'Create', onPressed: () {
                      if (nameCtrl.text.isNotEmpty) {
                        final data = <String, dynamic>{
                          'name': nameCtrl.text,
                          'description': descCtrl.text,
                          'trigger_type': triggerType,
                          'trigger_config': <String, dynamic>{},
                          'steps': steps.asMap().entries.map((e) => {'type': e.value['type'], 'config': e.value['config'] ?? <String, dynamic>{}, 'order': e.key}).toList(),
                        };
                        if (workflow != null) {
                          provider.updateWorkflow(workflow.id, data);
                        } else {
                          provider.createWorkflow(data);
                        }
                        Navigator.pop(ctx);
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExecutionHistory(BuildContext context, WorkflowProvider provider, Workflow workflow) {
    provider.loadExecutions(workflow.id);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700,
          height: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Execution History - ${workflow.name}', style: AppTypography.headlineMedium),
              const SizedBox(height: 16),
              Expanded(
                child: context.watch<WorkflowProvider>().executions.isEmpty
                    ? const Center(child: Text('No executions yet'))
                    : ListView.builder(
                        itemCount: provider.executions.length,
                        itemBuilder: (ctx, i) {
                          final exec = provider.executions[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                _badge(exec.statusLabel, exec.status == 'completed' ? AppColors.success : exec.status == 'failed' ? AppColors.error : AppColors.warning),
                                const SizedBox(width: 12),
                                Expanded(child: Text('Started: ${exec.startedAt.toString().split('.')[0]}', style: AppTypography.bodySmall)),
                                Text('Duration: ${exec.duration.inSeconds}s', style: AppTypography.bodySmall),
                                if (exec.error != null) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(label: 'Close', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged, BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.inputBorder)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceCard,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
