import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/models/knowledge_base.dart';

class KbFormDialog extends StatefulWidget {
  final String title;
  final KnowledgeBase? knowledgeBase;
  final Future<void> Function(String name, String? description) onSave;

  const KbFormDialog({
    super.key,
    required this.title,
    this.knowledgeBase,
    required this.onSave,
  });

  @override
  State<KbFormDialog> createState() => _KbFormDialogState();
}

class _KbFormDialogState extends State<KbFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isSaving = false;

  bool get _isEditing => widget.knowledgeBase != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.knowledgeBase?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.knowledgeBase?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  Future<void> _handleSave() async {
    final nameError = _validateName(_nameController.text);
    if (nameError != null) return;

    setState(() => _isSaving = true);
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    try {
      await widget.onSave(_nameController.text.trim(), description);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Name',
                hint: 'e.g. Product Documentation',
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Description (optional)',
                hint: 'Brief description of this knowledge base',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: _isEditing ? 'Update' : 'Create',
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
