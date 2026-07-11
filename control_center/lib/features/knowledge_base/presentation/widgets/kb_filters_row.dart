import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/document.dart';

class KbFiltersRow extends StatelessWidget {
  final DocumentStatus? selectedStatus;
  final DocumentType? selectedType;
  final ValueChanged<DocumentStatus?> onStatusChanged;
  final ValueChanged<DocumentType?> onTypeChanged;

  const KbFiltersRow({
    super.key,
    this.selectedStatus,
    this.selectedType,
    required this.onStatusChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          label: 'All',
          selected: selectedStatus == null,
          onTap: () => onStatusChanged(null),
        ),
        _FilterChip(
          label: 'Processing',
          selected: selectedStatus == DocumentStatus.processing,
          onTap: () => onStatusChanged(DocumentStatus.processing),
          color: AppColors.warning,
        ),
        _FilterChip(
          label: 'Indexed',
          selected: selectedStatus == DocumentStatus.indexed,
          onTap: () => onStatusChanged(DocumentStatus.indexed),
          color: AppColors.success,
        ),
        _FilterChip(
          label: 'Error',
          selected: selectedStatus == DocumentStatus.error,
          onTap: () => onStatusChanged(DocumentStatus.error),
          color: AppColors.error,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'All Types',
          selected: selectedType == null,
          onTap: () => onTypeChanged(null),
        ),
        _FilterChip(
          label: 'PDF',
          selected: selectedType == DocumentType.pdf,
          onTap: () => onTypeChanged(DocumentType.pdf),
        ),
        _FilterChip(
          label: 'DOCX',
          selected: selectedType == DocumentType.docx,
          onTap: () => onTypeChanged(DocumentType.docx),
        ),
        _FilterChip(
          label: 'TXT',
          selected: selectedType == DocumentType.txt,
          onTap: () => onTypeChanged(DocumentType.txt),
        ),
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
    );
  }
}
