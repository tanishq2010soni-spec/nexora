import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_text_field.dart';
import '../../../shared/models/agent.dart';
import '../../domain/models/agent_template.dart';

class TemplateForm extends ConsumerStatefulWidget {
  final AgentTemplate? template;
  final ValueChanged<AgentTemplate>? onSubmit;

  const TemplateForm({super.key, this.template, this.onSubmit});

  @override
  ConsumerState<TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends ConsumerState<TemplateForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _systemPromptController;
  late final TextEditingController _modelController;
  late final TextEditingController _temperatureController;
  AgentPlatform _selectedPlatform = AgentPlatform.whatsapp;
  bool _isSubmitting = false;

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.template?.description ?? '',
    );
    _systemPromptController = TextEditingController(
      text: widget.template?.systemPrompt ?? '',
    );
    _modelController = TextEditingController(
      text: widget.template?.llmModel ?? 'llama3',
    );
    _temperatureController = TextEditingController(
      text: (widget.template?.temperature ?? 0.7).toString(),
    );
    if (widget.template != null) {
      _selectedPlatform = widget.template!.platform;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _systemPromptController.dispose();
    _modelController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            _isEditing ? 'Edit Template' : 'Create Template',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Template Name',
            hint: 'e.g., Sales Outreach Bot',
            controller: _nameController,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Description',
            hint: 'Brief description of this template',
            controller: _descriptionController,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Platform',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: AgentPlatform.values.map((platform) {
              final isSelected = _selectedPlatform == platform;
              final label = switch (platform) {
                AgentPlatform.whatsapp => 'WhatsApp',
                AgentPlatform.calling => 'Calling',
                AgentPlatform.web => 'Web',
              };
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedPlatform = platform),
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.surfaceHover,
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.textInverse
                        : AppColors.textSecondary,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.surfaceBorder,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'System Prompt',
            hint: 'Enter the system prompt for this template',
            controller: _systemPromptController,
            maxLines: 5,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'LLM Model',
                  hint: 'llama3',
                  controller: _modelController,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppTextField(
                  label: 'Temperature',
                  hint: '0.7',
                  controller: _temperatureController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: _isEditing ? 'Update' : 'Create',
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final systemPrompt = _systemPromptController.text.trim();
    final model = _modelController.text.trim();
    final temperature = double.tryParse(_temperatureController.text) ?? 0.7;

    if (name.isEmpty || systemPrompt.isEmpty) return;

    setState(() => _isSubmitting = true);

    final template = AgentTemplate(
      id: widget.template?.id ?? '',
      name: name,
      description: description.isEmpty ? null : description,
      platform: _selectedPlatform,
      systemPrompt: systemPrompt,
      llmModel: model.isEmpty ? 'llama3' : model,
      temperature: temperature,
      platformConfig: widget.template?.platformConfig,
      isSystemTemplate: widget.template?.isSystemTemplate ?? false,
      createdAt: widget.template?.createdAt ?? DateTime.now(),
    );

    widget.onSubmit?.call(template);
    setState(() => _isSubmitting = false);
  }
}
