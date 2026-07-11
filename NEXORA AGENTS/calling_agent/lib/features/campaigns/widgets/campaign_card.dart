import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CampaignCard extends StatelessWidget {
  final String name;
  final String type;
  final String status;
  final int total;
  final int answered;
  final int converted;
  final double cost;
  final VoidCallback? onTap;
  final VoidCallback? onActivate;
  final VoidCallback? onPause;
  final VoidCallback? onDelete;

  const CampaignCard({
    super.key,
    required this.name,
    required this.type,
    required this.status,
    required this.total,
    required this.answered,
    required this.converted,
    required this.cost,
    this.onTap,
    this.onActivate,
    this.onPause,
    this.onDelete,
  });

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
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.campaign, color: _statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: AppTypography.titleMedium),
                        const SizedBox(width: 8),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('$type | $total leads', style: AppTypography.bodySmall),
                        const Spacer(),
                        Text('\$${cost.toStringAsFixed(2)}', style: AppTypography.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildMiniStat('Answered', answered.toString()),
                        const SizedBox(width: 12),
                        _buildMiniStat('Converted', converted.toString()),
                        const SizedBox(width: 12),
                        _buildMiniStat('Rate', '${total > 0 ? (converted / total * 100).toStringAsFixed(0) : 0}%'),
                      ],
                    ),
                  ],
                ),
              ),
              if (onActivate != null || onPause != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 18),
                  onSelected: (v) {
                    if (v == 'activate') onActivate?.call();
                    if (v == 'pause') onPause?.call();
                    if (v == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    if (status == 'paused')
                      const PopupMenuItem(value: 'activate', child: Text('Activate'))
                    else
                      const PopupMenuItem(value: 'pause', child: Text('Pause')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'paused':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(fontSize: 10, color: _statusColor, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}
