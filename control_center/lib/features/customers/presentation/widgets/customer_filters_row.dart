import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/customer.dart';

class CustomerFiltersRow extends StatelessWidget {
  final CustomerSegment? selectedSegment;
  final ValueChanged<CustomerSegment?> onSegmentChanged;
  final VoidCallback onClear;

  const CustomerFiltersRow({
    super.key,
    this.selectedSegment,
    required this.onSegmentChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Filter by:',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildSegmentFilter('All', null),
        const SizedBox(width: AppSpacing.sm),
        ...CustomerSegment.values.map((segment) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _buildSegmentFilter(_getSegmentLabel(segment), segment),
          );
        }),
        if (selectedSegment != null) ...[
          const Spacer(),
          TextButton(
            onPressed: onClear,
            child: Text(
              'Clear Filters',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSegmentFilter(String label, CustomerSegment? segment) {
    final isSelected = selectedSegment == segment;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSegmentChanged(segment),
      backgroundColor: AppColors.surfaceHover,
      selectedColor: AppColors.accentMuted,
      checkmarkColor: AppColors.accent,
      side: BorderSide(
        color: isSelected ? AppColors.accent : AppColors.surfaceBorder,
      ),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: isSelected ? AppColors.accent : AppColors.textSecondary,
      ),
    );
  }

  String _getSegmentLabel(CustomerSegment segment) {
    switch (segment) {
      case CustomerSegment.newCustomer:
        return 'New';
      case CustomerSegment.active:
        return 'Active';
      case CustomerSegment.vip:
        return 'VIP';
      case CustomerSegment.atRisk:
        return 'At Risk';
      case CustomerSegment.churned:
        return 'Churned';
    }
  }
}
