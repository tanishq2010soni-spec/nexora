import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CoachingPanel extends StatelessWidget {
  final List<String> suggestions;
  final VoidCallback? onBargeIn;

  const CoachingPanel({
    super.key,
    this.suggestions = const [],
    this.onBargeIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Text('Coaching Suggestions', style: AppTypography.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: InkWell(
                  onTap: onBargeIn,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.record_voice_over, size: 14, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text('Barge-in', style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (suggestions.isEmpty)
            Text('No suggestions at this time.', style: AppTypography.bodySmall)
          else
            ...suggestions.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s, style: AppTypography.bodySmall)),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
