import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model Configuration', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            _SettingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Model', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: provider.model,
                    dropdownColor: AppColors.surface,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceBorder)),
                    ),
                    items: ['gpt-4', 'gpt-3.5-turbo', 'claude-3', 'llama-3']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(color: AppColors.textPrimary))))
                        .toList(),
                    onChanged: (v) => provider.updateSetting('model', v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Temperature', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: provider.temperature,
                          min: 0,
                          max: 2,
                          divisions: 20,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.surfaceBorder,
                          onChanged: (v) => provider.updateSetting('temperature', v),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        provider.temperature.toStringAsFixed(1),
                        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Memory', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            _SettingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Memory Limit', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: provider.memoryLimit.toDouble(),
                          min: 10,
                          max: 500,
                          divisions: 49,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.surfaceBorder,
                          onChanged: (v) => provider.updateSetting('memory_limit', v.toInt()),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${provider.memoryLimit}',
                        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Preferences', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            _SettingCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Voice Enabled', style: AppTypography.body),
                    value: provider.voiceEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => provider.updateSetting('voice_enabled', v),
                  ),
                  const Divider(color: AppColors.surfaceBorder),
                  SwitchListTile(
                    title: Text('Dark Theme', style: AppTypography.body),
                    value: provider.darkTheme,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => provider.updateSetting('dark_theme', v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Workspace', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            _SettingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Workspace Name', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    hint: 'Enter workspace name',
                    controller: TextEditingController(text: provider.workspace),
                    onChanged: (v) => provider.updateSetting('workspace', v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Reset to Defaults',
              variant: AppButtonVariant.danger,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text('Are you sure you want to reset all settings to defaults?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          provider.resetDefaults();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;

  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: child,
    );
  }
}
