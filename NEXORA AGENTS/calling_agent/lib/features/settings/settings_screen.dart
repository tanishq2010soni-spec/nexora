import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text('Settings', style: AppTypography.displayMedium),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Organization'),
                    Tab(text: 'Voice'),
                    Tab(text: 'Phone Providers'),
                    Tab(text: 'Prompts'),
                  ],
                ),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrganizationTab(),
                      _buildVoiceTab(),
                      _buildProvidersTab(),
                      _buildPromptsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organization Settings', style: AppTypography.headlineMedium),
          const SizedBox(height: 20),
          const AppTextField(label: 'Organization Name', initialValue: 'My Company'),
          const SizedBox(height: 16),
          const AppTextField(label: 'Timezone', initialValue: 'America/New_York'),
          const SizedBox(height: 16),
          const AppTextField(label: 'Business Hours', initialValue: 'Mon-Fri 9:00-17:00'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildToggle('Enable Recording', true),
                const Divider(height: 16),
                _buildToggle('Enable Transcription', true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(label: 'Save Changes', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value) {
    return Row(
      children: [
        Text(label, style: AppTypography.bodyLarge),
        const Spacer(),
        Switch(value: value, onChanged: (v) {}, activeThumbColor: AppColors.primary),
      ],
    );
  }

  Widget _buildVoiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Voice Settings', style: AppTypography.headlineMedium),
          const SizedBox(height: 20),
          _buildDropdown('STT Provider', 'Default', ['Default', 'Google', 'Azure', 'Deepgram']),
          const SizedBox(height: 16),
          _buildDropdown('TTS Provider', 'Default', ['Default', 'Google', 'Azure', 'ElevenLabs']),
          const SizedBox(height: 16),
          _buildDropdown('VAD Provider', 'Default', ['Default', 'Silero', 'WebRTC']),
          const SizedBox(height: 16),
          _buildDropdown('Voice', 'Default', ['Default', 'Female 1', 'Male 1', 'Custom']),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Speed', style: AppTypography.bodyMedium),
                  Slider(value: 1.0, min: 0.5, max: 2.0, onChanged: (_) {}, activeColor: AppColors.primary),
                ],
              )),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pitch', style: AppTypography.bodyMedium),
                  Slider(value: 1.0, min: 0.5, max: 2.0, onChanged: (_) {}, activeColor: AppColors.primary),
                ],
              )),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdown('Emotion', 'Neutral', ['Neutral', 'Happy', 'Sad', 'Angry', 'Excited']),
          const SizedBox(height: 24),
          AppButton(label: 'Save Voice Settings', onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (_) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersTab() {
    final providers = ['Twilio', 'Vonage', 'Telnyx'];
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: providers.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text('Phone Providers', style: AppTypography.headlineMedium),
                const Spacer(),
                AppButton(label: 'Add Provider', icon: Icons.add, onPressed: () {}),
              ],
            ),
          );
        }
        final p = providers[i - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(p, style: AppTypography.bodyLarge)),
              Text('•••••••••••', style: AppTypography.bodyMedium),
              const SizedBox(width: 12),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: () {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromptsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 4,
      itemBuilder: (_, i) {
        final prompts = ['Sales Intro', 'Objection: Price', 'Follow-up Greeting', 'Support Opening'];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(prompts[i], style: AppTypography.bodyLarge)),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary), onPressed: () {}),
            ],
          ),
        );
      },
    );
  }
}
