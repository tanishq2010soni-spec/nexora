import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class LiveCallCard extends StatelessWidget {
  final String callerName;
  final String callerNumber;
  final String duration;
  final String status;
  final String agent;
  final double sentiment;
  final bool expanded;
  final VoidCallback onTap;

  const LiveCallCard({
    super.key,
    required this.callerName,
    required this.callerNumber,
    required this.duration,
    required this.status,
    required this.agent,
    required this.sentiment,
    required this.expanded,
    required this.onTap,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.activeCall;
      case 'ringing':
        return AppColors.ringing;
      case 'holding':
        return AppColors.holding;
      default:
        return AppColors.textMuted;
    }
  }

  Color get _sentimentColor {
    if (sentiment >= 0.6) return AppColors.success;
    if (sentiment >= 0.3) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(callerName, style: AppTypography.titleMedium),
                        Text(callerNumber, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _sentimentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          sentiment >= 0.6 ? Icons.sentiment_satisfied : sentiment >= 0.3 ? Icons.sentiment_neutral : Icons.sentiment_dissatisfied,
                          size: 14,
                          color: _sentimentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(sentiment * 100).toInt()}%',
                          style: TextStyle(fontSize: 11, color: _sentimentColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(duration, style: AppTypography.bodyMedium),
                  if (expanded) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.expand_less, color: AppColors.textSecondary, size: 20),
                  ],
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(agent, style: AppTypography.bodySmall),
                    const Spacer(),
                    _buildQuickAction(Icons.description_outlined, 'Script'),
                    const SizedBox(width: 8),
                    _buildQuickAction(Icons.note_add_outlined, 'Note'),
                    const SizedBox(width: 8),
                    _buildQuickAction(Icons.person_add_outlined, 'Lead'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
