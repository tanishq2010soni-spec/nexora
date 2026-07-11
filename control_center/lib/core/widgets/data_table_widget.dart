import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DataTableColumn<T> {
  final String label;
  final Widget Function(T item) cellBuilder;
  final bool sortable;
  final double? width;

  const DataTableColumn({
    required this.label,
    required this.cellBuilder,
    this.sortable = false,
    this.width,
  });
}

class AppDataTable<T> extends StatelessWidget {
  final List<DataTableColumn<T>> columns;
  final List<T> items;
  final ValueChanged<T>? onRowTap;
  final Widget Function(T item)? actions;
  final bool isLoading;
  final String emptyMessage;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.items,
    this.onRowTap,
    this.actions,
    this.isLoading = false,
    this.emptyMessage = 'No data',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surface),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.surfaceHover;
            }
            return null;
          }),
          columns: columns
              .map(
                (col) => DataColumn(
                  label: Text(
                    col.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
              .toList(),
          rows: items
              .map(
                (item) => DataRow(
                  onSelectChanged: onRowTap != null
                      ? (_) => onRowTap!(item)
                      : null,
                  cells: columns
                      .map((col) => DataCell(col.cellBuilder(item)))
                      .toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
