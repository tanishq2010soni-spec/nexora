import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';

import '../../domain/models/whatsapp_agent.dart';

import '../../../shared/models/agent.dart';
import '../../../shared/models/whatsapp_config.dart';

class WhatsAppAgentForm extends StatefulWidget {
  final String title;
  final WhatsAppAgent? agent;
  final Future<void> Function(WhatsAppAgent agent) onSave;

  const WhatsAppAgentForm({
    super.key,
    required this.title,
    this.agent,
    required this.onSave,
  });

  @override
  State<WhatsAppAgentForm> createState() => _WhatsAppAgentFormState();
}

class _WhatsAppAgentFormState extends State<WhatsAppAgentForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _systemPromptController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _businessAccountIdController;

  String _selectedModel = 'llama3';
  double _temperature = 0.7;
  bool _autoReply = true;
  bool _leadExtraction = true;
  bool _isSaving = false;

  static const _models = [
    'llama3',
    'llama3.1',
    'gpt-4o',
    'gpt-4o-mini',
    'claude-3-sonnet',
    'claude-3-haiku',
  ];

  bool get _isEditing => widget.agent != null;

  @override
  void initState() {
    super.initState();
    final agent = widget.agent;
    _nameController = TextEditingController(text: agent?.name ?? '');
    _systemPromptController = TextEditingController(
      text: agent?.systemPrompt ?? '',
    );
    _phoneNumberController = TextEditingController(
      text: agent?.config.phoneNumberId ?? '',
    );
    _businessAccountIdController = TextEditingController(
      text: agent?.config.businessAccountId ?? '',
    );

    if (agent != null) {
      _selectedModel = agent.llmModel;
      _temperature = agent.temperature;
      _autoReply = agent.config.autoReply;
      _leadExtraction = agent.config.leadExtraction;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _systemPromptController.dispose();
    _phoneNumberController.dispose();
    _businessAccountIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) return;
    if (_systemPromptController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final agent = WhatsAppAgent(
      id: widget.agent?.id ?? '',
      orgId: widget.agent?.orgId ?? '',
      name: _nameController.text.trim(),
      systemPrompt: _systemPromptController.text.trim(),
      llmModel: _selectedModel,
      temperature: _temperature,
      status: widget.agent?.status ?? AgentStatus.idle,
      config: WhatsAppConfig(
        phoneNumberId: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
        businessAccountId: _businessAccountIdController.text.trim().isEmpty
            ? null
            : _businessAccountIdController.text.trim(),
        autoReply: _autoReply,
        leadExtraction: _leadExtraction,
      ),
      knowledgeBaseIds: widget.agent?.knowledgeBaseIds,
      lastActiveAt: widget.agent?.lastActiveAt,
      createdAt: widget.agent?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await widget.onSave(agent);
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
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
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
                label: 'Agent Name',
                hint: 'e.g. Sales Assistant',
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'System Prompt',
                hint: 'Define the agent behavior and personality...',
                controller: _systemPromptController,
                maxLines: 6,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildModelSelector(),
              const SizedBox(height: AppSpacing.lg),
              _buildTemperatureSlider(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'WhatsApp Configuration',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Phone Number ID',
                hint: 'WhatsApp phone number ID',
                controller: _phoneNumberController,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Business Account ID',
                hint: 'WhatsApp business account ID',
                controller: _businessAccountIdController,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildToggleRow('Auto Reply', _autoReply, (val) {
                setState(() => _autoReply = val);
              }),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleRow('Lead Extraction', _leadExtraction, (val) {
                setState(() => _leadExtraction = val);
              }),
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

  Widget _buildModelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LLM Model',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedModel,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              items: _models
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedModel = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Temperature',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              _temperature.toStringAsFixed(1),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.surfaceBorder,
            thumbColor: AppColors.accent,
            overlayColor: AppColors.accentMuted,
          ),
          child: Slider(
            value: _temperature,
            min: 0.0,
            max: 2.0,
            divisions: 20,
            onChanged: (val) => setState(() => _temperature = val),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.accent,
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentMuted;
            }
            return AppColors.surfaceBorder;
          }),
        ),
      ],
    );
  }
}
