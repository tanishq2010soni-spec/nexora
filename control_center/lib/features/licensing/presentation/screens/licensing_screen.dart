import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/enums/license_type.dart';
import '../../domain/models/license_model.dart';
import '../../providers/license_provider.dart';

class LicensingScreen extends ConsumerStatefulWidget {
  final String orgId;

  const LicensingScreen({super.key, required this.orgId});

  @override
  ConsumerState<LicensingScreen> createState() => _LicensingScreenState();
}

class _LicensingScreenState extends ConsumerState<LicensingScreen> {
  final _activationController = TextEditingController();
  bool _isActivating = false;

  @override
  void dispose() {
    _activationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final licenseAsync = ref.watch(licenseProvider(widget.orgId));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Licensing',
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xl),
            licenseAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => ErrorView(
                exception: e,
                onRetry: () =>
                    ref.invalidate(licenseProvider(widget.orgId)),
              ),
              data: (apiResult) => switch (apiResult) {
                ApiSuccess<LicenseModel>(:final data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LicenseDetailsCard(license: data),
                      const SizedBox(height: AppSpacing.xl),
                      _ActivateLicenseForm(
                        controller: _activationController,
                        isActivating: _isActivating,
                        onActivate: _activateLicense,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _UsageStatisticsSection(license: data),
                    ],
                  ),
                ApiError<LicenseModel>(:final exception) => ErrorView(
                  exception: exception,
                  onRetry: () =>
                      ref.invalidate(licenseProvider(widget.orgId)),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activateLicense() async {
    final code = _activationController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isActivating = true);
    try {
      // Activation would use a mutation provider
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('License activation requires mutation provider.'),
            backgroundColor: AppColors.info,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActivating = false);
    }
  }
}

class _LicenseDetailsCard extends StatelessWidget {
  final LicenseModel license;

  const _LicenseDetailsCard({required this.license});

  String _licenseTypeLabel() {
    return switch (license.licenseType) {
      LicenseType.community => 'Community',
      LicenseType.professional => 'Professional',
      LicenseType.enterprise => 'Enterprise',
      LicenseType.educational => 'Educational',
      LicenseType.trial => 'Trial',
      LicenseType.custom => 'Custom',
    };
  }

  Color _statusColor() {
    if (license.isActive) return AppColors.success;
    return AppColors.error;
  }

  String _statusLabel() {
    if (license.isActive) return 'Active';
    return 'Inactive';
  }

  @override
  Widget build(BuildContext context) {
    return SlideFadeIn(
      offset: const Offset(0, 20),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.verified_outlined,
                    size: 24,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _licenseTypeLabel(),
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusLabel(),
                        style: AppTypography.labelLarge.copyWith(
                          color: _statusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _statusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Divider(color: AppColors.surfaceBorder),
            const SizedBox(height: AppSpacing.lg),
            _LicenseRow(label: 'License ID', value: license.id),
            const SizedBox(height: AppSpacing.sm),
            _LicenseRow(
              label: 'Seats',
              value: license.seats.toString(),
            ),
            if (license.isTrial && license.trialEndsAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _LicenseRow(
                label: 'Trial Ends',
                value: _formatDate(license.trialEndsAt!),
              ),
            ],
            if (license.expiresAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _LicenseRow(
                label: 'Expires',
                value: _formatDate(license.expiresAt!),
              ),
            ],
            if (license.activatedAt != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _LicenseRow(
                label: 'Activated',
                value: _formatDate(license.activatedAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _LicenseRow extends StatelessWidget {
  final String label;
  final String value;

  const _LicenseRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ActivateLicenseForm extends StatelessWidget {
  final TextEditingController controller;
  final bool isActivating;
  final VoidCallback onActivate;

  const _ActivateLicenseForm({
    required this.controller,
    required this.isActivating,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return SlideFadeIn(
      offset: const Offset(0, 20),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vpn_key_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Activate License',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: controller,
              hint: 'Enter activation code',
              prefix: const Icon(Icons.key, size: 16, color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Activate',
              isLoading: isActivating,
              onPressed: onActivate,
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageStatisticsSection extends StatelessWidget {
  final LicenseModel license;

  const _UsageStatisticsSection({required this.license});

  @override
  Widget build(BuildContext context) {
    return SlideFadeIn(
      offset: const Offset(0, 20),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Usage Statistics',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (license.usageJson != null)
              Text(
                license.usageJson!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              Text(
                'No usage data available.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            if (license.featuresJson != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Divider(color: AppColors.surfaceBorder),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(Icons.widgets_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Features',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                license.featuresJson!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
