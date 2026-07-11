import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/customer.dart';

class CustomerSegmentBadge extends StatelessWidget {
  final CustomerSegment segment;

  const CustomerSegmentBadge({super.key, required this.segment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getColor().withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getLabel(),
        style: AppTypography.labelSmall.copyWith(
          color: _getColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (segment) {
      case CustomerSegment.newCustomer:
        return AppColors.accent;
      case CustomerSegment.active:
        return AppColors.success;
      case CustomerSegment.vip:
        return AppColors.warning;
      case CustomerSegment.atRisk:
        return const Color(0xFFFF9800);
      case CustomerSegment.churned:
        return AppColors.error;
    }
  }

  String _getLabel() {
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
