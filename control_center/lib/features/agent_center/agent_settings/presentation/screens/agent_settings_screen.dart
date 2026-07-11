import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/errors/app_exception.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_text_field.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/error_view.dart';
import '../../domain/models/agent_settings.dart';
import '../../providers/settings_provider.dart';
import '../widgets/model_selector.dart';
import '../widgets/temperature_slider.dart';

class AgentSettingsScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentSettingsScreen({super.key, required this.agentId});

  @override
  ConsumerState<AgentSettingsScreen> createState() =>
      _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends ConsumerState<AgentSettingsScreen> {
  late TextEditingController _maxTokensController;
  late TextEditingController _timeoutController;
  late TextEditingController _systemPromptController;
  bool _streamingEnabled = true;
  double _temperature = 0.7;
  String? _selectedModelId;
  List<String> _selectedKnowledgeBaseIds = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _maxTokensController = TextEditingController(text: '1024');
    _timeoutController = TextEditingController(text: '30');
    _systemPromptController = TextEditingController(
      text: 'You are a helpful assistant.',
    );
  }

  @override
  void dispose() {
    _maxTokensController.dispose();
    _timeoutController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  void _loadSettings(AgentSettings settings) {
    _maxTokensController.text = settings.maxTokens.toString();
    _timeoutController.text = settings.timeoutSeconds.toString();
    _systemPromptController.text = settings.systemPrompt;
    _streamingEnabled = settings.streamingEnabled;
    _temperature = settings.temperature;
    _selectedModelId = settings.selectedModel;
    _selectedKnowledgeBaseIds = List<String>.from(
      settings.assignedKnowledgeBaseIds ?? [],
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(agentCenterSettingsRepositoryProvider);
      final settings = AgentSettings(
        agentId: widget.agentId,
        agentName: '',
        selectedModel: _selectedModelId ?? 'llama3',
        temperature: _temperature,
        maxTokens: int.tryParse(_maxTokensController.text) ?? 1024,
        streamingEnabled: _streamingEnabled,
        timeoutSeconds: int.tryParse(_timeoutController.text) ?? 30,
        assignedKnowledgeBaseIds: _selectedKnowledgeBaseIds,
        systemPrompt: _systemPromptController.text,
      );

      await repository.updateAgentSettings(widget.agentId, settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(agentSettingsProvider(widget.agentId));
    final modelsAsync = ref.watch(availableModelsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Agent Settings'), centerTitle: false),
      body: settingsAsync.when(
        loading: () => const AppLoader(),
        error: (error, stack) => ErrorView(
          exception: error is AppException
              ? error
              : UnknownException(error.toString()),
          onRetry: () => ref.invalidate(agentSettingsProvider(widget.agentId)),
        ),
        data: (settings) {
          _loadSettings(settings);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(settings),
                  const SizedBox(height: AppSpacing.xl),
                  _buildModelSection(modelsAsync),
                  const SizedBox(height: AppSpacing.xl),
                  _buildTemperatureSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildMaxTokensSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildTimeoutSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildStreamingToggle(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildKnowledgeBaseSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSystemPromptSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSaveButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AgentSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agent Settings',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          settings.agentName.isNotEmpty
              ? settings.agentName
              : 'Agent ${settings.agentId}',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildModelSection(AsyncValue<List<dynamic>> modelsAsync) {
    return modelsAsync.when(
      loading: () => const AppLoader(),
      error: (error, stack) => ErrorView(
        exception: error is AppException
            ? error
            : UnknownException(error.toString()),
        onRetry: () => ref.invalidate(availableModelsProvider),
      ),
      data: (models) => ModelSelector(
        models: models.cast(),
        selectedModelId: _selectedModelId,
        onModelChanged: (value) {
          setState(() => _selectedModelId = value);
        },
      ),
    );
  }

  Widget _buildTemperatureSection() {
    return TemperatureSlider(
      value: _temperature,
      onChanged: (value) {
        setState(() => _temperature = value);
      },
    );
  }

  Widget _buildMaxTokensSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Max Tokens',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _maxTokensController,
          label: 'Maximum tokens',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTimeoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeout (seconds)',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _timeoutController,
          label: 'Request timeout',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildStreamingToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Streaming',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            Text(
              'Enable streaming responses',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Switch(
          value: _streamingEnabled,
          onChanged: (value) {
            setState(() => _streamingEnabled = value);
          },
          activeThumbColor: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildKnowledgeBaseSection() {
    final availableKnowledgeBases = [
      'Product Documentation',
      'API Reference',
      'User Guide',
      'FAQ Database',
      'Troubleshooting Guide',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Knowledge Base Assignment',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableKnowledgeBases.map((kb) {
            final isSelected = _selectedKnowledgeBaseIds.contains(kb);
            return FilterChip(
              label: Text(kb),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedKnowledgeBaseIds.add(kb);
                  } else {
                    _selectedKnowledgeBaseIds.remove(kb);
                  }
                });
              },
              selectedColor: AppColors.accent.withValues(alpha: 0.2),
              checkmarkColor: AppColors.accent,
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSystemPromptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Prompt',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: _systemPromptController,
          label: 'System prompt',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: AppButton(
        label: _isSaving ? '' : 'Save Settings',
        onPressed: _isSaving ? null : _saveSettings,
        isLoading: _isSaving,
      ),
    );
  }
}
