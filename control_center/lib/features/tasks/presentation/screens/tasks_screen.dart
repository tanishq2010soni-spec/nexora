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
import '../../domain/models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../widgets/priority_badge.dart';
import 'task_detail_screen.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: AppSpacing.xl),
          _buildFilters(context),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: tasksAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => ErrorView(
                exception: e is AppException
                    ? e
                    : UnknownException(e.toString()),
                onRetry: () => ref.invalidate(taskListProvider),
              ),
              data: (tasks) {
                final filtered = _applyFilters(tasks);
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.task_alt,
                    title: 'No Tasks Found',
                    subtitle: _hasActiveFilters
                        ? 'Try adjusting your filters.'
                        : 'Create your first task to get started.',
                    action: AppButton(
                      label: _hasActiveFilters ? 'Clear Filters' : 'Add Task',
                      icon: _hasActiveFilters ? null : Icons.add,
                      variant: _hasActiveFilters
                          ? AppButtonVariant.secondary
                          : AppButtonVariant.primary,
                      onPressed: () {
                        if (_hasActiveFilters) {
                          _clearFilters();
                        } else {
                          _showCreateTaskDialog(context, ref);
                        }
                      },
                    ),
                  );
                }
                return _buildTaskList(context, ref, filtered);
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
          'Tasks',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        AppButton(
          label: 'Add Task',
          icon: Icons.add,
          onPressed: () => _showCreateTaskDialog(context, ref),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          hint: 'Search tasks...',
          controller: _searchController,
          prefix: Icon(Icons.search),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildFilterChip(
              label: 'All',
              selected: _statusFilter == null,
              onTap: () => setState(() => _statusFilter = null),
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip(
              label: 'Pending',
              selected: _statusFilter == TaskStatus.pending,
              onTap: () => setState(() => _statusFilter = TaskStatus.pending),
            ),
            _buildFilterChip(
              label: 'In Progress',
              selected: _statusFilter == TaskStatus.inProgress,
              onTap: () =>
                  setState(() => _statusFilter = TaskStatus.inProgress),
            ),
            _buildFilterChip(
              label: 'Completed',
              selected: _statusFilter == TaskStatus.completed,
              onTap: () => setState(() => _statusFilter = TaskStatus.completed),
            ),
            _buildFilterChip(
              label: 'Cancelled',
              selected: _statusFilter == TaskStatus.cancelled,
              onTap: () => setState(() => _statusFilter = TaskStatus.cancelled),
            ),
            const SizedBox(width: AppSpacing.lg),
            Container(width: 1, height: 24, color: AppColors.surfaceBorder),
            const SizedBox(width: AppSpacing.lg),
            _buildPriorityFilter('Low', TaskPriority.low),
            _buildPriorityFilter('Med', TaskPriority.medium),
            _buildPriorityFilter('High', TaskPriority.high),
            _buildPriorityFilter('Urgent', TaskPriority.urgent),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityFilter(String label, TaskPriority priority) {
    final selected = _priorityFilter == priority;
    return _buildFilterChip(
      label: label,
      selected: selected,
      onTap: () => setState(() => _priorityFilter = selected ? null : priority),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    WidgetRef ref,
    List<TaskModel> tasks,
  ) {
    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          tileColor: AppColors.surface,
          leading: _buildStatusIcon(task.status),
          title: Text(
            task.title,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: task.description != null
              ? Text(
                  task.description!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PriorityBadge(priority: task.priority),
              if (task.dueDate != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.dueDate!.day}/${task.dueDate!.month}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.sm),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                onSelected: (value) {
                  if (value == 'edit') _showEditTaskDialog(context, ref, task);
                  if (value == 'delete') _confirmDeleteTask(context, ref, task);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          onTap: () => _openTaskDetail(context, task),
        );
      },
    );
  }

  Widget _buildStatusIcon(TaskStatus status) {
    final color = switch (status) {
      TaskStatus.pending => AppColors.textTertiary,
      TaskStatus.inProgress => AppColors.info,
      TaskStatus.completed => AppColors.success,
      TaskStatus.cancelled => AppColors.error,
    };
    final icon = switch (status) {
      TaskStatus.pending => Icons.radio_button_unchecked,
      TaskStatus.inProgress => Icons.play_circle_outline,
      TaskStatus.completed => Icons.check_circle_outline,
      TaskStatus.cancelled => Icons.cancel_outlined,
    };
    return Icon(icon, color: color, size: 20);
  }

  List<TaskModel> _applyFilters(List<TaskModel> tasks) {
    var filtered = tasks;
    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }
    if (_priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (t) =>
                t.title.toLowerCase().contains(query) ||
                (t.description?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }
    return filtered;
  }

  bool get _hasActiveFilters =>
      _statusFilter != null ||
      _priorityFilter != null ||
      _searchQuery.isNotEmpty;

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _priorityFilter = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _openTaskDetail(BuildContext context, TaskModel task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)),
    );
  }

  void _showCreateTaskDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _TaskFormDialog(
        title: 'Create Task',
        onSave: (task) async {
          await ref.read(createTaskProvider(task).future);
          ref.invalidate(taskListProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditTaskDialog(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) {
    showDialog(
      context: context,
      builder: (_) => _TaskFormDialog(
        title: 'Edit Task',
        task: task,
        onSave: (updated) async {
          await ref.read(
            updateTaskProvider((id: task.id, task: updated)).future,
          );
          ref.invalidate(taskListProvider);
          ref.invalidate(taskDetailProvider(task.id));
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _confirmDeleteTask(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
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
          'Delete Task',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
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

    if (confirmed == true && context.mounted) {
      await ref.read(deleteTaskProvider(task.id).future);
      ref.invalidate(taskListProvider);
    }
  }
}

class _TaskFormDialog extends StatefulWidget {
  final String title;
  final TaskModel? task;
  final Future<void> Function(TaskModel) onSave;

  const _TaskFormDialog({required this.title, this.task, required this.onSave});

  @override
  State<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<_TaskFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _status = widget.task?.status ?? TaskStatus.pending;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      title: Text(
        widget.title,
        style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(hint: 'Task title', controller: _titleController),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              hint: 'Description (optional)',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown<TaskPriority>(
                    value: _priority,
                    label: 'Priority',
                    items: TaskPriority.values,
                    labelBuilder: (v) => v.name.toUpperCase(),
                    onChanged: (v) => setState(() => _priority = v!),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildDropdown<TaskStatus>(
                    value: _status,
                    label: 'Status',
                    items: TaskStatus.values,
                    labelBuilder: (v) => v.name
                        .replaceAllMapped(
                          RegExp(r'([A-Z])'),
                          (m) => ' ${m.group(1)}',
                        )
                        .trim(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _dueDate = date);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  hintText: 'Due date (optional)',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
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
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ),
                child: Text(
                  _dueDate != null
                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                      : '',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(label: 'Save', isLoading: _isSaving, onPressed: _save),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dropdownColor: AppColors.surface,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(labelBuilder(e))))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final task = TaskModel(
        id: widget.task?.id ?? '',
        orgId: widget.task?.orgId ?? '',
        title: title,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        status: _status,
        assignedTo: widget.task?.assignedTo,
        dueDate: _dueDate,
        entityType: widget.task?.entityType,
        entityId: widget.task?.entityId,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await widget.onSave(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save task: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
