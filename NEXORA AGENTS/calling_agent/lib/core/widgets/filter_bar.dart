import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FilterBar extends StatelessWidget {
  final List<FilterChipOption> chips;
  final String? searchHint;
  final TextEditingController? searchController;
  final void Function(String)? onSearch;

  const FilterBar({
    super.key,
    required this.chips,
    this.searchHint,
    this.searchController,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (onSearch != null) ...[
            SizedBox(
              width: 240,
              child: TextField(
                controller: searchController,
                onChanged: onSearch,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: searchHint ?? 'Search...',
                  hintStyle: AppTypography.bodySmall,
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          ...chips.map((chip) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(chip.label),
                  selected: chip.selected,
                  onSelected: chip.onSelected,
                  selectedColor: AppColors.primary.withValues(alpha: 0.3),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: chip.selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  backgroundColor: AppColors.surfaceLight,
                  side: BorderSide(
                    color: chip.selected ? AppColors.primary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class FilterChipOption {
  final String label;
  final bool selected;
  final void Function(bool)? onSelected;

  FilterChipOption({
    required this.label,
    required this.selected,
    this.onSelected,
  });
}
