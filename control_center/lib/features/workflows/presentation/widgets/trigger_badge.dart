import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/workflow_model.dart';

class TriggerBadge extends StatelessWidget {
  final WorkflowTriggerType triggerType;

  const TriggerBadge({super.key, required this.triggerType});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (triggerType) {
      WorkflowTriggerType.newLead => ('New Lead', AppColors.info),
      WorkflowTriggerType.customerReplied => (
        'Customer Replied',
        AppColors.accent,
      ),
      WorkflowTriggerType.callMissed => ('Call Missed', AppColors.warning),
      WorkflowTriggerType.appointmentBooked => (
        'Appointment Booked',
        AppColors.success,
      ),
      WorkflowTriggerType.manual => ('Manual', AppColors.textTertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}
