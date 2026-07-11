import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';

class TemperatureSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const TemperatureSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _getTemperatureLabel(double value) {
    if (value <= 0.3) return 'Precise';
    if (value <= 0.7) return 'Balanced';
    return 'Creative';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Temperature',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${value.toStringAsFixed(1)} - ${_getTemperatureLabel(value)}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '0.0',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Slider(
                value: value,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                onChanged: onChanged,
                activeColor: AppColors.accent,
                inactiveColor: AppColors.surfaceBorder,
              ),
            ),
            Text(
              '2.0',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Precise',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Balanced',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Creative',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
