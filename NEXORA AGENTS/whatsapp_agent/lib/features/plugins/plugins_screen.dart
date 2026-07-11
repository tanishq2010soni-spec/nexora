import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/plugin_provider.dart';

class PluginsScreen extends StatefulWidget {
  const PluginsScreen({super.key});

  @override
  State<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends State<PluginsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PluginProvider>().loadPlugins();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PluginProvider>();

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
                      Text('Plugins', style: AppTypography.displaySmall),
                      const SizedBox(height: 4),
                      Text('Extend functionality with plugins', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                AppButton(
                  label: 'Install Plugin',
                  icon: Icons.add,
                  onPressed: () => _showInstallDialog(context, provider),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.plugins.isEmpty
                    ? const EmptyState(icon: Icons.extension_rounded, title: 'No plugins installed', subtitle: 'Install plugins to extend functionality', actionLabel: 'Install Plugin')
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: provider.plugins.length,
                        itemBuilder: (context, index) => _buildPluginCard(provider, provider.plugins[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPluginCard(PluginProvider provider, Map<String, dynamic> plugin) {
    final isEnabled = plugin['enabled'] as bool? ?? true;
    final name = plugin['name'] as String? ?? 'Unknown';
    final version = plugin['version'] as String? ?? '1.0.0';
    final description = plugin['description'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? AppColors.surfaceBorder : AppColors.surfaceBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isEnabled ? AppColors.primary : AppColors.textMuted).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.extension_rounded,
                  size: 20,
                  color: isEnabled ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Switch(
                value: isEnabled,
                onChanged: (v) => provider.togglePlugin(plugin['id'] as int, v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: AppTypography.titleMedium),
          const SizedBox(height: 2),
          Text('v$version', style: AppTypography.bodySmall),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AppButton(
                label: 'Configure',
                variant: AppButtonVariant.outline,
                onPressed: () => _showConfigDialog(context, provider, plugin),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInstallDialog(BuildContext context, PluginProvider provider) {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

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
              Text('Install Plugin', style: AppTypography.displaySmall),
              const SizedBox(height: 20),
              AppTextField(label: 'Plugin Name *', hint: 'e.g., Sentiment Analysis', controller: nameCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Package URL', hint: 'npm package or git URL', controller: urlCtrl),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(label: 'Cancel', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(ctx)),
                  const SizedBox(width: 12),
                  AppButton(label: 'Install', onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      provider.installPlugin({
                        'name': nameCtrl.text,
                        'source': urlCtrl.text,
                      });
                      Navigator.pop(ctx);
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

  void _showConfigDialog(BuildContext context, PluginProvider provider, Map<String, dynamic> plugin) {
    final config = plugin['config'] as Map<String, dynamic>? ?? {};
    final configCtrl = TextEditingController(
      text: config.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configure ${plugin['name'] ?? 'Plugin'}', style: AppTypography.displaySmall),
              const SizedBox(height: 20),
              TextField(
                controller: configCtrl,
                maxLines: 6,
                style: AppTypography.code,
                decoration: InputDecoration(
                  hintText: 'key: value (one per line)',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(label: 'Cancel', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(ctx)),
                  const SizedBox(width: 12),
                  AppButton(label: 'Save Config', onPressed: () {
                    final lines = configCtrl.text.split('\n').where((l) => l.contains(':'));
                    final newConfig = <String, dynamic>{};
                    for (final line in lines) {
                      final parts = line.split(':');
                      if (parts.length >= 2) {
                        newConfig[parts[0].trim()] = parts.sublist(1).join(':').trim();
                      }
                    }
                    provider.updatePluginConfig(plugin['id'] as int, newConfig);
                    Navigator.pop(ctx);
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
