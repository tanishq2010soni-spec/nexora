import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/lead.dart';

class LeadDetailPanel extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onEdit;
  final VoidCallback? onConvert;

  const LeadDetailPanel({
    super.key,
    required this.lead,
    this.onEdit,
    this.onConvert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(lead.name, style: AppTypography.headlineMedium),
              ),
              if (lead.status != 'won' && lead.status != 'lost') ...[
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  color: AppColors.textMuted,
                ),
                if (onConvert != null)
                  TextButton(
                    onPressed: onConvert,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                      backgroundColor: AppColors.success.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Convert to Customer'),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoChip(Icons.circle, lead.scoreLabel, lead.score >= 80 ? AppColors.success : lead.score >= 50 ? AppColors.warning : AppColors.textMuted),
              const SizedBox(width: 8),
              _infoChip(Icons.flag_rounded, lead.statusLabel, AppColors.primary),
              if (lead.source != null) ...[
                const SizedBox(width: 8),
                _infoChip(Icons.source_rounded, lead.source!, AppColors.info),
              ],
            ],
          ),
          const SizedBox(height: 20),
          if (lead.phone != null || lead.email != null) ...[
            Text('Contact', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            if (lead.phone != null) _detailRow(Icons.phone_rounded, lead.phone!),
            if (lead.email != null) _detailRow(Icons.email_rounded, lead.email!),
            const SizedBox(height: 16),
          ],
          if (lead.assignedToName != null) ...[
            Text('Assigned To', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            _detailRow(Icons.person_rounded, lead.assignedToName!),
            const SizedBox(height: 16),
          ],
          if (lead.notes != null && lead.notes!.isNotEmpty) ...[
            Text('Notes', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(lead.notes!, style: AppTypography.bodyMedium),
            ),
            const SizedBox(height: 16),
          ],
          if (lead.timeline != null && lead.timeline!.isNotEmpty) ...[
            Text('Timeline', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            ...lead.timeline!.map((event) => _buildTimelineEvent(event)),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(value, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event['action'] as String? ?? '', style: AppTypography.bodySmall),
          if (event['detail'] != null)
            Text(event['detail'] as String, style: AppTypography.bodyMedium),
          if (event['timestamp'] != null)
            Text(event['timestamp'] as String, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}
