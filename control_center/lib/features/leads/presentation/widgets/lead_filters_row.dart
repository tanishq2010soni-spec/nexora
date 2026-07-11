import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/lead.dart';

class LeadFiltersRow extends StatelessWidget {
  final LeadStatus? selectedStatus;
  final LeadSource? selectedSource;
  final ValueChanged<LeadStatus?> onStatusChanged;
  final ValueChanged<LeadSource?> onSourceChanged;
  final VoidCallback onClear;

  const LeadFiltersRow({
    super.key,
    this.selectedStatus,
    this.selectedSource,
    required this.onStatusChanged,
    required this.onSourceChanged,
    required this.onClear,
  });

  bool get _hasFilters => selectedStatus != null || selectedSource != null;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Status:',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        _FilterChip(
          label: 'All',
          selected: selectedStatus == null,
          onTap: () => onStatusChanged(null),
        ),
        _FilterChip(
          label: 'New',
          selected: selectedStatus == LeadStatus.newLead,
          onTap: () => onStatusChanged(LeadStatus.newLead),
          color: AppColors.info,
        ),
        _FilterChip(
          label: 'Contacted',
          selected: selectedStatus == LeadStatus.contacted,
          onTap: () => onStatusChanged(LeadStatus.contacted),
          color: AppColors.warning,
        ),
        _FilterChip(
          label: 'Qualified',
          selected: selectedStatus == LeadStatus.qualified,
          onTap: () => onStatusChanged(LeadStatus.qualified),
          color: AppColors.success,
        ),
        _FilterChip(
          label: 'Proposal',
          selected: selectedStatus == LeadStatus.proposalSent,
          onTap: () => onStatusChanged(LeadStatus.proposalSent),
          color: AppColors.accent,
        ),
        _FilterChip(
          label: 'Negotiation',
          selected: selectedStatus == LeadStatus.negotiation,
          onTap: () => onStatusChanged(LeadStatus.negotiation),
          color: const Color(0xFFF97316),
        ),
        _FilterChip(
          label: 'Won',
          selected: selectedStatus == LeadStatus.won,
          onTap: () => onStatusChanged(LeadStatus.won),
          color: AppColors.success,
        ),
        _FilterChip(
          label: 'Lost',
          selected: selectedStatus == LeadStatus.lost,
          onTap: () => onStatusChanged(LeadStatus.lost),
          color: AppColors.error,
        ),
        const SizedBox(width: 12),
        Text(
          'Source:',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        _FilterChip(
          label: 'All',
          selected: selectedSource == null,
          onTap: () => onSourceChanged(null),
        ),
        _FilterChip(
          label: 'WhatsApp',
          selected: selectedSource == LeadSource.whatsapp,
          onTap: () => onSourceChanged(LeadSource.whatsapp),
          color: const Color(0xFF25D366),
        ),
        _FilterChip(
          label: 'Calling',
          selected: selectedSource == LeadSource.callingAgent,
          onTap: () => onSourceChanged(LeadSource.callingAgent),
          color: AppColors.info,
        ),
        _FilterChip(
          label: 'Website',
          selected: selectedSource == LeadSource.website,
          onTap: () => onSourceChanged(LeadSource.website),
          color: AppColors.accent,
        ),
        _FilterChip(
          label: 'Manual',
          selected: selectedSource == LeadSource.manual,
          onTap: () => onSourceChanged(LeadSource.manual),
          color: AppColors.textTertiary,
        ),
        _FilterChip(
          label: 'Import',
          selected: selectedSource == LeadSource.import,
          onTap: () => onSourceChanged(LeadSource.import),
          color: AppColors.warning,
        ),
        if (_hasFilters) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withAlpha(60)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, size: 12, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    'Clear',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? chipColor.withAlpha(30) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? chipColor : AppColors.surfaceBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: selected ? chipColor : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
