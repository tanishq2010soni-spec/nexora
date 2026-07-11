import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/organization_setting.dart';
import '../../domain/models/api_key.dart';
import '../../domain/models/integration.dart';
import '../../providers/settings_provider.dart';
import '../widgets/setting_tile.dart';
import '../widgets/integration_card.dart';

enum SettingsTab {
  organization,
  branding,
  security,
  apiKeys,
  integrations,
  backup,
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  SettingsTab _currentTab = SettingsTab.organization;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xl),
          _buildTabBar(),
          const SizedBox(height: AppSpacing.xl),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Settings',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SettingsTab.values.map((tab) {
          final isSelected = _currentTab == tab;
          final label = switch (tab) {
            SettingsTab.organization => 'Organization',
            SettingsTab.branding => 'Branding',
            SettingsTab.security => 'Security',
            SettingsTab.apiKeys => 'API Keys',
            SettingsTab.integrations => 'Integrations',
            SettingsTab.backup => 'Backup',
          };
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _currentTab = tab),
              selectedColor: AppColors.accentMuted,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.surfaceBorder,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_currentTab) {
      SettingsTab.organization => _buildOrganizationTab(),
      SettingsTab.branding => _buildBrandingTab(),
      SettingsTab.security => _buildSecurityTab(),
      SettingsTab.apiKeys => _buildApiKeysTab(),
      SettingsTab.integrations => _buildIntegrationsTab(),
      SettingsTab.backup => _buildBackupTab(),
    };
  }

  Widget _buildOrganizationTab() {
    final settingsAsync = ref.watch(settingsListProvider);

    return settingsAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(settingsListProvider),
      ),
      data: (settings) {
        if (settings.isEmpty) {
          return const EmptyState(
            icon: Icons.business_outlined,
            title: 'No Settings',
            subtitle: 'Organization settings will appear here.',
          );
        }
        return ListView.separated(
          itemCount: settings.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final setting = settings[index];
            return SettingTile(
              icon: Icons.settings_outlined,
              title: setting.key,
              subtitle: setting.value,
              onTap: () => _showEditSettingDialog(setting),
            );
          },
        );
      },
    );
  }

  Widget _buildBrandingTab() {
    return ListView(
      children: [
        SettingTile(
          icon: Icons.palette_outlined,
          title: 'Primary Color',
          subtitle: '#6366F1',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        SettingTile(
          icon: Icons.image_outlined,
          title: 'Logo',
          subtitle: 'Upload your organization logo',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        SettingTile(
          icon: Icons.text_fields_outlined,
          title: 'Company Name',
          subtitle: 'Nexora',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      children: [
        SettingTile(
          icon: Icons.lock_outline,
          title: 'Two-Factor Authentication',
          subtitle: 'Require 2FA for all users',
          trailing: Switch(
            value: false,
            onChanged: (v) {},
            activeThumbColor: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SettingTile(
          icon: Icons.schedule_outlined,
          title: 'Session Timeout',
          subtitle: '30 minutes',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        SettingTile(
          icon: Icons.password_outlined,
          title: 'Password Policy',
          subtitle: 'Minimum 8 characters',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        SettingTile(
          icon: Icons.web_outlined,
          title: 'IP Whitelisting',
          subtitle: 'Restrict access by IP',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildApiKeysTab() {
    final keysAsync = ref.watch(apiKeysProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'API Keys',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            AppButton(
              label: 'Generate Key',
              icon: Icons.add,
              onPressed: () => _showCreateApiKeyDialog(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: keysAsync.when(
            loading: () => const AppLoader(),
            error: (e, _) => ErrorView(
              exception: e is AppException ? e : UnknownException(e.toString()),
              onRetry: () => ref.invalidate(apiKeysProvider),
            ),
            data: (keys) {
              if (keys.isEmpty) {
                return const EmptyState(
                  icon: Icons.vpn_key_outlined,
                  title: 'No API Keys',
                  subtitle: 'Generate your first API key to get started.',
                );
              }
              return ListView.separated(
                itemCount: keys.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _buildApiKeyTile(keys[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyTile(ApiKey key) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.vpn_key, size: 20, color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${key.keyPrefix}...',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: key.isActive
                  ? AppColors.success.withAlpha(30)
                  : AppColors.error.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              key.isActive ? 'Active' : 'Inactive',
              style: AppTypography.labelSmall.copyWith(
                color: key.isActive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: AppColors.error,
            onPressed: () => _confirmDeleteApiKey(key),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsTab() {
    final integrationsAsync = ref.watch(integrationsProvider);

    return integrationsAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(integrationsProvider),
      ),
      data: (integrations) {
        if (integrations.isEmpty) {
          return const EmptyState(
            icon: Icons.extension_outlined,
            title: 'No Integrations',
            subtitle: 'Connect your favorite tools and services.',
          );
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.8,
          ),
          itemCount: integrations.length,
          itemBuilder: (context, index) {
            final integration = integrations[index];
            return IntegrationCard(
              integration: integration,
              onTap: () {},
              onConnect: () => _connectIntegration(integration),
            );
          },
        );
      },
    );
  }

  Widget _buildBackupTab() {
    return ListView(
      children: [
        SettingTile(
          icon: Icons.cloud_upload_outlined,
          title: 'Create Backup',
          subtitle: 'Download a backup of your organization data',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        SettingTile(
          icon: Icons.cloud_download_outlined,
          title: 'Restore Backup',
          subtitle: 'Restore from a previous backup',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        SettingTile(
          icon: Icons.schedule_outlined,
          title: 'Auto Backup',
          subtitle: 'Enabled - Daily at 2:00 AM',
          trailing: Switch(
            value: true,
            onChanged: (v) {},
            activeThumbColor: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SettingTile(
          icon: Icons.history_outlined,
          title: 'Backup History',
          subtitle: 'View previous backups',
          onTap: () {},
        ),
      ],
    );
  }

  void _showEditSettingDialog(OrganizationSetting setting) {
    final controller = TextEditingController(text: setting.value);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Edit ${setting.key}',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: AppTextField(controller: controller, hint: 'Enter value'),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: 'Save',
            onPressed: () async {
              await ref.read(
                updateSettingProvider((
                  key: setting.key,
                  value: controller.text,
                )).future,
              );
              ref.invalidate(settingsListProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showCreateApiKeyDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Generate API Key',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameController, hint: 'Key name'),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: descController,
              hint: 'Description (optional)',
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: 'Generate',
            onPressed: () async {
              await ref.read(
                createApiKeyProvider((
                  name: nameController.text,
                  description: descController.text.isEmpty
                      ? null
                      : descController.text,
                )).future,
              );
              ref.invalidate(apiKeysProvider);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteApiKey(ApiKey key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Delete API Key',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${key.name}"? This cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: 'Delete',
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(deleteApiKeyProvider(key.id).future);
      ref.invalidate(apiKeysProvider);
    }
  }

  void _connectIntegration(Integration integration) {
    ref.read(updateIntegrationProvider((id: integration.id, config: {})));
    ref.invalidate(integrationsProvider);
  }
}
