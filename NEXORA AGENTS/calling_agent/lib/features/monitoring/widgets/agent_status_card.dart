import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AgentStatusCard extends StatelessWidget {
  final String name;
  final String status;
  final String currentCall;
  final int callsToday;
  final double avgSentiment;

  const AgentStatusCard({
    super.key,
    required this.name,
    required this.status,
    this.currentCall = '',
    this.callsToday = 0,
    this.avgSentiment = 0,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'on-call':
        return AppColors.activeCall;
      case 'available':
        return AppColors.success;
      case 'break':
        return AppColors.warning;
      case 'offline':
        return AppColors.textMuted;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _statusColor.withValues(alpha: 0.2),
            child: Text(name[0], style: TextStyle(color: _statusColor, fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleMedium),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
                    if (currentCall.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(currentCall, style: AppTypography.caption),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${callsToday} calls', style: AppTypography.bodySmall),
              if (avgSentiment > 0)
                Text('${(avgSentiment * 100).toInt()}%', style: TextStyle(fontSize: 11, color: avgSentiment >= 0.6 ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
