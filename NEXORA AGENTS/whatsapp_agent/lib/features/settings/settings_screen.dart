import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user?.organizationId != null) {
        context.read<SettingsProvider>().loadSettings(auth.user!.organizationId!);
      }
      context.read<SettingsProvider>().loadPrompts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: AppTypography.displaySmall),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textMuted,
                    tabs: const [
                      Tab(text: 'Organization'),
                      Tab(text: 'Prompts'),
                      Tab(text: 'Models'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrganizationTab(provider),
                _buildPromptsTab(provider),
                _buildModelsTab(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationTab(SettingsProvider provider) {
    final settings = provider.settings;
    final nameCtrl = TextEditingController(text: settings?['name'] as String? ?? '');
    final tzCtrl = TextEditingController(text: settings?['timezone'] as String? ?? 'UTC');
    final whStartCtrl = TextEditingController(text: settings?['working_hours_start'] as String? ?? '09:00');
    final whEndCtrl = TextEditingController(text: settings?['working_hours_end'] as String? ?? '17:00');
    final brandCtrl = TextEditingController(text: settings?['brand_color'] as String? ?? '#4F46E5');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Organization Settings', style: AppTypography.headlineMedium),
            const SizedBox(height: 20),
            AppTextField(label: 'Organization Name', controller: nameCtrl),
            const SizedBox(height: 16),
            AppTextField(label: 'Timezone', controller: tzCtrl, hint: 'e.g., UTC, America/New_York'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AppTextField(label: 'Working Hours Start', controller: whStartCtrl, hint: '09:00')),
                const SizedBox(width: 12),
                Expanded(child: AppTextField(label: 'Working Hours End', controller: whEndCtrl, hint: '17:00')),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Brand Color', controller: brandCtrl, hint: '#4F46E5'),
            const SizedBox(height: 24),
            AppButton(
              label: 'Save Changes',
              onPressed: () {
                provider.updateSettings({
                  'name': nameCtrl.text,
                  'timezone': tzCtrl.text,
                  'working_hours_start': whStartCtrl.text,
                  'working_hours_end': whEndCtrl.text,
                  'brand_color': brandCtrl.text,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptsTab(SettingsProvider provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            children: [
              Text('Prompt Templates', style: AppTypography.headlineMedium),
              const Spacer(),
              AppButton(label: 'Add Prompt', icon: Icons.add, onPressed: () => _showPromptDialog(context, provider, null)),
            ],
          ),
        ),
        Expanded(
          child: provider.prompts.isEmpty
              ? Center(child: Text('No prompt templates', style: AppTypography.bodyMedium))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.prompts.length,
                  itemBuilder: (context, index) {
                    final prompt = provider.prompts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.surfaceBorder)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(prompt.name, style: AppTypography.titleMedium),
                                    if (prompt.isDefault)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text('Default', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w500)),
                                      ),
                                  ],
                                ),
                                if (prompt.category != null)
                                  Text(prompt.category!, style: AppTypography.bodySmall),
                              ],
                            ),
                          ),
                          AppButton(label: 'Edit', variant: AppButtonVariant.outline, onPressed: () => _showPromptDialog(context, provider, prompt)),
                          const SizedBox(width: 8),
                          AppButton(label: 'Delete', variant: AppButtonVariant.danger, onPressed: () {
                            provider.deletePrompt(prompt.id);
                          }),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildModelsTab(SettingsProvider provider) {
    final modelCtrl = TextEditingController(text: provider.defaultModel);
    final tempCtrl = TextEditingController(text: provider.temperature.toString());
    final tokensCtrl = TextEditingController(text: provider.maxTokens.toString());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model Configuration', style: AppTypography.headlineMedium),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Default Model', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.inputBorder)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.defaultModel,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceCard,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      items: ['gpt-4', 'gpt-3.5-turbo', 'claude-3', 'gemini-pro', 'llama-3'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          provider.updateSettings({'default_model': v});
                          setState(() => modelCtrl.text = v);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Temperature',
                    controller: tempCtrl,
                    hint: '0.7',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Max Tokens',
                    controller: tokensCtrl,
                    hint: '2048',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Save Model Settings',
              onPressed: () {
                provider.updateSettings({
                  'default_model': modelCtrl.text,
                  'temperature': double.tryParse(tempCtrl.text) ?? 0.7,
                  'max_tokens': int.tryParse(tokensCtrl.text) ?? 2048,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Model settings saved')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPromptDialog(BuildContext context, SettingsProvider provider, dynamic prompt) {
    final nameCtrl = TextEditingController(text: prompt?.name ?? '');
    final contentCtrl = TextEditingController(text: prompt?.content ?? '');
    final catCtrl = TextEditingController(text: prompt?.category ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prompt != null ? 'Edit Prompt' : 'New Prompt', style: AppTypography.displaySmall),
              const SizedBox(height: 20),
              AppTextField(label: 'Name *', hint: 'Prompt name', controller: nameCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Category', hint: 'e.g., greeting, handoff', controller: catCtrl),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 8,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Prompt Content *',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(label: 'Cancel', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(ctx)),
                  const SizedBox(width: 12),
                  AppButton(label: prompt != null ? 'Update' : 'Create', onPressed: () {
                    if (nameCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                      final data = <String, dynamic>{
                        'name': nameCtrl.text,
                        'content': contentCtrl.text,
                        'category': catCtrl.text,
                      };
                      if (prompt != null) {
                        provider.updatePrompt(prompt.id, data);
                      } else {
                        provider.createPrompt(data);
                      }
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
}
