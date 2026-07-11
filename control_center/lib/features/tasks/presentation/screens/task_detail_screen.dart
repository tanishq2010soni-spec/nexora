import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/task_model.dart';
import '../../domain/models/note.dart';
import '../../providers/tasks_provider.dart';
import '../widgets/priority_badge.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _noteController;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.pending;
  DateTime? _dueDate;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isAddingNote = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Task Details',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => ErrorView(
          exception: e is AppException ? e : UnknownException(e.toString()),
          onRetry: () => ref.invalidate(taskDetailProvider(widget.taskId)),
        ),
        data: (task) {
          if (!_isEditing) {
            _titleController.text = task.title;
            _descriptionController.text = task.description ?? '';
            _priority = task.priority;
            _status = task.status;
            _dueDate = task.dueDate;
          }
          return _buildContent(context, task);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TaskModel task) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskInfo(task),
                const SizedBox(height: AppSpacing.xl),
                _buildNotesSection(task),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskInfo(TaskModel task) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing) ...[
            AppTextField(hint: 'Task title', controller: _titleController),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              hint: 'Description',
              controller: _descriptionController,
              maxLines: 4,
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
                  hintText: 'Due date',
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
                      : 'Select date',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => setState(() => _isEditing = false),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: 'Save Changes',
                  isLoading: _isSaving,
                  onPressed: () => _saveTask(task),
                ),
              ],
            ),
          ] else ...[
            Text(
              task.title,
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                PriorityBadge(priority: task.priority),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusChip(task.status),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                task.description!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _buildSectionLabel('Assigned To'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              task.assignedTo ?? 'Unassigned',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionLabel('Due Date'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              task.dueDate != null
                  ? '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}'
                  : 'No due date',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionLabel('Created'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatDateTime(task.createdAt),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildSectionLabel('Updated'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatDateTime(task.updatedAt),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(TaskModel task) {
    final notesAsync = ref.watch(
      taskNotesProvider((entityType: 'task', entityId: task.id)),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Notes'),
          const SizedBox(height: AppSpacing.md),
          _buildAddNoteBar(),
          const SizedBox(height: AppSpacing.lg),
          notesAsync.when(
            loading: () => const AppLoader(),
            error: (e, _) => Text(
              'Failed to load notes',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            data: (notes) {
              if (notes.isEmpty) {
                return Text(
                  'No notes yet.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _buildNoteItem(notes[index]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddNoteBar() {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            hint: 'Add a note...',
            controller: _noteController,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton(
          label: 'Add',
          isCompact: true,
          isLoading: _isAddingNote,
          onPressed: _addNote,
        ),
      ],
    );
  }

  Widget _buildNoteItem(TaskNote note) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                note.createdBy ?? 'Unknown',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                _formatDateTime(note.createdAt),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            note.content,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTypography.labelLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    final (label, color) = switch (status) {
      TaskStatus.pending => ('Pending', AppColors.textSecondary),
      TaskStatus.inProgress => ('In Progress', AppColors.info),
      TaskStatus.completed => ('Completed', AppColors.success),
      TaskStatus.cancelled => ('Cancelled', AppColors.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
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

  Future<void> _saveTask(TaskModel task) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final updated = task.copyWith(
        title: title,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
        updatedAt: DateTime.now(),
      );
      await ref.read(updateTaskProvider((id: task.id, task: updated)).future);
      ref.invalidate(taskListProvider);
      ref.invalidate(taskDetailProvider(task.id));
      setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _addNote() async {
    final content = _noteController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isAddingNote = true);
    try {
      await ref.read(
        addTaskNoteProvider((
          entityType: 'task',
          entityId: widget.taskId,
          content: content,
        )).future,
      );
      _noteController.clear();
      ref.invalidate(
        taskNotesProvider((entityType: 'task', entityId: widget.taskId)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add note: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingNote = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
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
          'Are you sure you want to delete this task?',
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
      await ref.read(deleteTaskProvider(widget.taskId).future);
      ref.invalidate(taskListProvider);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
