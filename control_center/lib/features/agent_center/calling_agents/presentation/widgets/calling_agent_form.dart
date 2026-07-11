import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../domain/models/calling_agent.dart';
import '../../../shared/models/agent.dart';
import '../../../shared/models/voice_config.dart';

class CallingAgentForm extends StatefulWidget {
  final CallingAgent? agent;
  final Future<dynamic> Function(CallingAgent agent) onSubmit;

  const CallingAgentForm({super.key, this.agent, required this.onSubmit});

  @override
  State<CallingAgentForm> createState() => _CallingAgentFormState();
}

class _CallingAgentFormState extends State<CallingAgentForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _systemPromptController;
  late final TextEditingController _llmModelController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _voiceIdController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _sampleRateController;

  bool _recordCalls = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.agent != null;

  @override
  void initState() {
    super.initState();
    final agent = widget.agent;
    _nameController = TextEditingController(text: agent?.name ?? '');
    _systemPromptController = TextEditingController(
      text: agent?.systemPrompt ?? '',
    );
    _llmModelController = TextEditingController(
      text: agent?.llmModel ?? 'llama3',
    );
    _temperatureController = TextEditingController(
      text: '${agent?.temperature ?? 0.7}',
    );
    _voiceIdController = TextEditingController(
      text: agent?.voiceConfig.voiceId ?? 'alloy',
    );
    _phoneNumberController = TextEditingController(
      text: agent?.voiceConfig.phoneNumber ?? '',
    );
    _sampleRateController = TextEditingController(
      text: '${agent?.voiceConfig.sampleRate ?? 16000}',
    );
    _recordCalls = agent?.voiceConfig.recordCalls ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _systemPromptController.dispose();
    _llmModelController.dispose();
    _temperatureController.dispose();
    _voiceIdController.dispose();
    _phoneNumberController.dispose();
    _sampleRateController.dispose();
    super.dispose();
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
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isEditing ? 'Edit Calling Agent' : 'Create Calling Agent',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: 'Agent Name',
                  hint: 'Enter agent name',
                  controller: _nameController,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'System Prompt',
                  hint: 'Describe the agent role and behavior',
                  controller: _systemPromptController,
                  maxLines: 4,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'LLM Model',
                        hint: 'e.g. llama3',
                        controller: _llmModelController,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        label: 'Temperature',
                        hint: '0.0 - 1.0',
                        controller: _temperatureController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Voice Configuration',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Voice ID',
                  hint: 'e.g. alloy',
                  controller: _voiceIdController,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Phone Number',
                  hint: '+1 555 000 0000',
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Sample Rate',
                        hint: '16000',
                        controller: _sampleRateController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 22),
                        child: Row(
                          children: [
                            Switch(
                              value: _recordCalls,
                              onChanged: (value) =>
                                  setState(() => _recordCalls = value),
                              activeThumbColor: AppColors.accent,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Record Calls',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final systemPrompt = _systemPromptController.text.trim();

    if (name.isEmpty || systemPrompt.isEmpty) return;

    final temperature = double.tryParse(_temperatureController.text) ?? 0.7;
    final sampleRate = int.tryParse(_sampleRateController.text) ?? 16000;

    final now = DateTime.now();
    final voiceConfig = VoiceConfig(
      voiceId: _voiceIdController.text.trim().isEmpty
          ? 'alloy'
          : _voiceIdController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim().isEmpty
          ? null
          : _phoneNumberController.text.trim(),
      sampleRate: sampleRate,
      recordCalls: _recordCalls,
    );

    final agent = CallingAgent(
      id: widget.agent?.id ?? '',
      orgId: widget.agent?.orgId ?? '',
      name: name,
      systemPrompt: systemPrompt,
      llmModel: _llmModelController.text.trim().isEmpty
          ? 'llama3'
          : _llmModelController.text.trim(),
      temperature: temperature,
      status: widget.agent?.status ?? AgentStatus.idle,
      voiceConfig: voiceConfig,
      knowledgeBaseIds: widget.agent?.knowledgeBaseIds,
      lastActiveAt: widget.agent?.lastActiveAt,
      totalCalls: widget.agent?.totalCalls ?? 0,
      todayCalls: widget.agent?.todayCalls ?? 0,
      createdAt: widget.agent?.createdAt ?? now,
      updatedAt: now,
    );

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(agent);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
