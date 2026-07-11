import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/customer.dart';

class CustomerHealthScoreCard extends StatelessWidget {
  final Customer customer;

  const CustomerHealthScoreCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_outline,
                size: 20,
                color: _getHealthColor(customer.healthScore),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Overall Health: ${customer.healthScore}',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getHealthColor(customer.healthScore).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getHealthLabel(customer.healthScore),
                  style: AppTypography.labelSmall.copyWith(
                    color: _getHealthColor(customer.healthScore),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildScoreBar('Engagement', customer.engagementScore),
          const SizedBox(height: AppSpacing.md),
          _buildScoreBar('Retention', customer.retentionScore),
          const SizedBox(height: AppSpacing.md),
          _buildScoreBar('Satisfaction', customer.satisfactionScore),
          const SizedBox(height: AppSpacing.md),
          _buildScoreBar('Revenue', customer.revenueScore),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$score',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.surfaceBorder,
            valueColor: AlwaysStoppedAnimation<Color>(_getHealthColor(score)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Color _getHealthColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return const Color(0xFFFF9800);
    return AppColors.error;
  }

  String _getHealthLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }
}
