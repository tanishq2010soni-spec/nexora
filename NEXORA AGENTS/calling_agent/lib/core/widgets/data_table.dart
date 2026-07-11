import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final List<Widget>? actions;
  final String? title;
  final double? rowHeight;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.actions,
    this.title,
    this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || actions != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: AppTypography.titleLarge,
                    ),
                  const Spacer(),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 48,
              dataRowMinHeight: rowHeight ?? 52, dataRowMaxHeight: rowHeight ?? 52,
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              columns: columns
                  .map(
                    (col) => DataColumn(
                      label: Text(
                        col,
                        style: AppTypography.labelSmall,
                      ),
                    ),
                  )
                  .toList(),
              rows: rows
                  .map(
                    (row) => DataRow(
                      cells: row
                          .map(
                            (cell) => DataCell(
                              Text(
                                cell,
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
