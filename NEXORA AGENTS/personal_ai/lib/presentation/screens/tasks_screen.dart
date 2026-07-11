import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/app_loader.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _createTask() {
    final goal = _goalController.text.trim();
    if (goal.isEmpty) return;
    _goalController.clear();
    context.read<TaskProvider>().createTask(goal);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Enter a goal...',
                      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _createTask(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: 'Create',
                  icon: Icons.add,
                  onPressed: _createTask,
                  loading: provider.loading,
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.loading
                ? const AppLoader()
                : provider.tasks.isEmpty
                    ? const EmptyState(
                        icon: Icons.task_alt_outlined,
                        title: 'No tasks',
                        subtitle: 'Create a task for the AI to execute',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
                        itemCount: provider.tasks.length,
                        itemBuilder: (context, index) {
                          final task = provider.tasks[index];
                          return _TaskCard(
                            task: task,
                            onCancel: () => provider.cancelTask(task.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onCancel;

  const _TaskCard({required this.task, required this.onCancel});

  Color get _statusColor {
    switch (task.status) {
      case 'completed':
        return AppColors.success;
      case 'running':
        return AppColors.primary;
      case 'failed':
        return AppColors.error;
      case 'cancelled':
        return AppColors.warning;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    task.goal,
                    style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                if (task.status == 'running')
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.danger,
                    size: AppButtonSize.sm,
                    onPressed: onCancel,
                  ),
              ],
            ),
            if (task.steps.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ...task.steps.map((step) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      step.status == 'completed'
                          ? Icons.check_circle
                          : step.status == 'failed'
                              ? Icons.error
                              : Icons.horizontal_rule,
                      size: 14,
                      color: step.status == 'completed'
                          ? AppColors.success
                          : step.status == 'failed'
                              ? AppColors.error
                              : AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      step.description,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatDate(task.createdAt),
              style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
