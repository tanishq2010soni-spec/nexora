import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FilterBar extends StatefulWidget {
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<FilterDropdown>? dropdowns;
  final DateTimeRange? dateRange;
  final VoidCallback? onDateRangeTap;
  final VoidCallback? onClear;

  const FilterBar({
    super.key,
    this.searchHint,
    this.onSearchChanged,
    this.dropdowns,
    this.dateRange,
    this.onDateRangeTap,
    this.onClear,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 240,
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.searchHint ?? 'Search...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                isDense: true,
                filled: true,
                fillColor: AppColors.inputBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputFocusedBorder),
                ),
              ),
            ),
          ),
          if (widget.dropdowns != null) ...[
            const SizedBox(width: 12),
            ...widget.dropdowns!.map((dropdown) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterDropdownWidget(dropdown: dropdown),
                )),
          ],
          if (widget.onDateRangeTap != null) ...[
            const SizedBox(width: 8),
            _DateRangeButton(
              dateRange: widget.dateRange,
              onTap: widget.onDateRangeTap,
            ),
          ],
          const Spacer(),
          if (widget.onClear != null)
            TextButton.icon(
              onPressed: widget.onClear,
              icon: const Icon(Icons.clear_all_rounded, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                textStyle: AppTypography.labelLarge,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class FilterDropdown {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
  });
}

class _FilterDropdownWidget extends StatelessWidget {
  final FilterDropdown dropdown;

  const _FilterDropdownWidget({required this.dropdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: dropdown.value,
          hint: Text(dropdown.label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          isDense: true,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          dropdownColor: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          items: dropdown.items,
          onChanged: dropdown.onChanged,
        ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  final DateTimeRange? dateRange;
  final VoidCallback? onTap;

  const _DateRangeButton({this.dateRange, this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = dateRange != null
        ? '${dateRange!.start.month}/${dateRange!.start.day} - ${dateRange!.end.month}/${dateRange!.end.day}'
        : 'Date Range';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
