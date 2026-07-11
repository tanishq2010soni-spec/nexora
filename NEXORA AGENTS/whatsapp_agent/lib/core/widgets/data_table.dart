import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DataColumnConfig {
  final String label;
  final String key;
  final bool sortable;
  final double? flex;
  final double? fixedWidth;
  final Widget Function(dynamic value)? cellBuilder;
  final TextStyle? headerStyle;
  final TextStyle? cellStyle;
  final TextAlign? textAlign;

  const DataColumnConfig({
    required this.label,
    required this.key,
    this.sortable = true,
    this.flex,
    this.fixedWidth,
    this.cellBuilder,
    this.headerStyle,
    this.cellStyle,
    this.textAlign,
  });
}

class AppDataTable extends StatefulWidget {
  final List<DataColumnConfig> columns;
  final List<Map<String, dynamic>> rows;
  final String? sortColumn;
  final bool sortAscending;
  final Function(String column)? onSort;
  final Function(int index)? onRowTap;
  final Widget? Function(int index)? rowActions;
  final bool loading;
  final String? emptyMessage;
  final double? rowHeight;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumn,
    this.sortAscending = true,
    this.onSort,
    this.onRowTap,
    this.rowActions,
    this.loading = false,
    this.emptyMessage,
    this.rowHeight = 48,
  });

  @override
  State<AppDataTable> createState() => _AppDataTableState();
}

class _AppDataTableState extends State<AppDataTable> {
  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            widget.emptyMessage ?? 'No data available',
            style: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.rows.length,
                    itemExtent: widget.rowHeight,
                    itemBuilder: (context, index) {
                      return _buildRow(index);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Row(
        children: widget.columns.map((col) {
          final isSorted = widget.sortColumn == col.key;
          return _buildHeaderCell(col, isSorted);
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderCell(DataColumnConfig col, bool isSorted) {
    return SizedBox(
      width: col.fixedWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: GestureDetector(
          onTap: col.sortable && widget.onSort != null
              ? () => widget.onSort!(col.key)
              : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  col.label,
                  style: col.headerStyle ??
                      AppTypography.labelLarge.copyWith(
                        color: isSorted
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                  textAlign: col.textAlign,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (col.sortable && isSorted)
                Icon(
                  widget.sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int index) {
    final row = widget.rows[index];
    final isEven = index % 2 == 0;

    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.transparent : AppColors.surfaceHover.withValues(alpha: 0.3),
        border: const Border(
          bottom: BorderSide(color: AppColors.dividerColor, width: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onRowTap != null ? () => widget.onRowTap!(index) : null,
          hoverColor: AppColors.surfaceHover,
          child: Row(
            children: [
              ...widget.columns.map((col) {
                return SizedBox(
                  width: col.fixedWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: col.cellBuilder != null
                        ? col.cellBuilder!(row[col.key])
                        : Text(
                            '${row[col.key] ?? ''}',
                            style: col.cellStyle ?? AppTypography.bodyMedium,
                            textAlign: col.textAlign,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                  ),
                );
              }),
              if (widget.rowActions != null) widget.rowActions!(index) ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
