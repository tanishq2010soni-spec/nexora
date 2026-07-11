import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});

  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  List<Map<String, dynamic>> _providers = [
    {'id': 1, 'name': 'OpenAI', 'model': 'gpt-4', 'base_url': 'https://api.openai.com/v1', 'enabled': true, 'is_default': true},
    {'id': 2, 'name': 'Anthropic', 'model': 'claude-3-opus', 'base_url': 'https://api.anthropic.com/v1', 'enabled': true, 'is_default': false},
    {'id': 3, 'name': 'Google', 'model': 'gemini-pro', 'base_url': 'https://generativelanguage.googleapis.com/v1', 'enabled': false, 'is_default': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Models', style: AppTypography.displaySmall),
                      const SizedBox(height: 4),
                      Text('Configure AI model providers and settings', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                AppButton(label: 'Add Provider', icon: Icons.add, onPressed: () => _showProviderDialog(context, null)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _providers.length,
              itemBuilder: (context, index) => _buildProviderCard(_providers[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(provider['name'] as String, style: AppTypography.headlineSmall),
                    if (provider['is_default'] as bool)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('Default', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Model: ${provider['model']}', style: AppTypography.bodyMedium),
                Text('${provider['base_url']}', style: AppTypography.bodySmall),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: provider['enabled'] as bool,
                onChanged: (v) => setState(() => provider['enabled'] = v),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connection test successful')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: AppTypography.labelSmall,
                    side: const BorderSide(color: AppColors.inputBorder),
                  ),
                  child: const Text('Test'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _showProviderDialog(context, provider),
            icon: const Icon(Icons.edit_rounded, size: 18),
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  void _showProviderDialog(BuildContext context, Map<String, dynamic>? existing) {
    final nameCtrl = TextEditingController(text: existing?['name'] as String? ?? '');
    final apiKeyCtrl = TextEditingController(text: existing?['api_key'] as String? ?? '');
    final modelCtrl = TextEditingController(text: existing?['model'] as String? ?? '');
    final urlCtrl = TextEditingController(text: existing?['base_url'] as String? ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing != null ? 'Edit Provider' : 'Add Provider', style: AppTypography.displaySmall),
              const SizedBox(height: 20),
              AppTextField(label: 'Provider Name *', hint: 'e.g., OpenAI', controller: nameCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'API Key', hint: 'sk-...', controller: apiKeyCtrl, obscureText: true),
              const SizedBox(height: 12),
              AppTextField(label: 'Model *', hint: 'e.g., gpt-4', controller: modelCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Base URL', hint: 'https://api.openai.com/v1', controller: urlCtrl),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(label: 'Cancel', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(ctx)),
                  const SizedBox(width: 12),
                  AppButton(label: existing != null ? 'Save' : 'Add', onPressed: () {
                    if (nameCtrl.text.isNotEmpty && modelCtrl.text.isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${existing != null ? "Updated" : "Added"} provider "${nameCtrl.text}"')),
                      );
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
