import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/app_loader.dart';
import '../../providers/permission_provider.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionProvider>().loadPending();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PermissionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.refresh(),
          ),
        ],
      ),
      body: provider.loading
          ? const AppLoader()
          : provider.pending.isEmpty
              ? const EmptyState(
                  icon: Icons.security_outlined,
                  title: 'No pending permissions',
                  subtitle: 'All permissions have been handled',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: provider.pending.length,
                  itemBuilder: (context, index) {
                    final perm = provider.pending[index];
                    return FadeIn(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.security, size: 18, color: AppColors.warning),
                                const SizedBox(width: AppSpacing.sm),
                                Text(perm.action, style: AppTypography.body.copyWith(color: AppColors.textPrimary)),
                              ],
                            ),
                            if (perm.details.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                perm.details.toString(),
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppButton(
                                  label: 'Deny',
                                  variant: AppButtonVariant.text,
                                  onPressed: () => provider.deny(perm.id),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                AppButton(
                                  label: 'Approve',
                                  icon: Icons.check,
                                  onPressed: () => provider.approve(perm.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
