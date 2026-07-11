import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/task_model.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final config = _priorityConfig(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.$2.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: config.$2.withAlpha(80)),
      ),
      child: Text(
        config.$1,
        style: AppTypography.labelSmall.copyWith(color: config.$2),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  (String, Color) _priorityConfig(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => ('Low', AppColors.info),
      TaskPriority.medium => ('Medium', AppColors.warning),
      TaskPriority.high => ('High', const Color(0xFFF97316)),
      TaskPriority.urgent => ('Urgent', AppColors.error),
    };
  }
}
