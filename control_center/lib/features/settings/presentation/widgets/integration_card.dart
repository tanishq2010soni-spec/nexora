import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/integration.dart';

class IntegrationCard extends StatelessWidget {
  final Integration integration;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;

  const IntegrationCard({
    super.key,
    required this.integration,
    this.onTap,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = integration.status == IntegrationStatus.connected;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected
                ? AppColors.success.withAlpha(60)
                : AppColors.surfaceBorder,
          ),
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
                    color: AppColors.surfaceHover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: integration.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            integration.logoUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.extension_outlined,
                              size: 24,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.extension_outlined,
                          size: 24,
                          color: AppColors.textTertiary,
                        ),
                ),
                const Spacer(),
                _buildStatusBadge(isConnected),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              integration.name,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              integration.description ?? integration.type,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (!isConnected)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onConnect,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Connect',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: AppColors.success),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Connected',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  const Spacer(),
                  if (integration.connectedAt != null)
                    Text(
                      'Since ${_formatDate(integration.connectedAt!)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isConnected
            ? AppColors.success.withAlpha(30)
            : AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isConnected ? 'Connected' : 'Disconnected',
        style: AppTypography.labelSmall.copyWith(
          color: isConnected ? AppColors.success : AppColors.textTertiary,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
