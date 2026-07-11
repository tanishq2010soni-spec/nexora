import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/customer.dart';
import 'customer_health_score_badge.dart';
import 'customer_segment_badge.dart';

class CustomerDataTable extends StatefulWidget {
  final List<Customer> customers;
  final Set<String> selectedIds;
  final ValueChanged<Customer> onCustomerTap;
  final ValueChanged<Customer> onEdit;
  final ValueChanged<Customer> onDelete;
  final ValueChanged<Customer> onView;
  final ValueChanged<Set<String>> onSelectionChanged;

  const CustomerDataTable({
    super.key,
    required this.customers,
    required this.selectedIds,
    required this.onCustomerTap,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
    required this.onSelectionChanged,
  });

  @override
  State<CustomerDataTable> createState() => _CustomerDataTableState();
}

class _CustomerDataTableState extends State<CustomerDataTable> {
  String? _sortColumn;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(child: _buildTableBody()),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          _buildCheckboxHeader(),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: 2, child: _buildSortableHeader('Name', 'name')),
          Expanded(flex: 2, child: _buildSortableHeader('Email', 'email')),
          Expanded(flex: 1, child: _buildSortableHeader('Segment', 'segment')),
          Expanded(flex: 1, child: _buildSortableHeader('Health', 'health')),
          Expanded(
            flex: 1,
            child: _buildSortableHeader('Interactions', 'interactions'),
          ),
          Expanded(flex: 1, child: _buildSortableHeader('Revenue', 'revenue')),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCheckboxHeader() {
    final allSelected =
        widget.customers.isNotEmpty &&
        widget.selectedIds.length == widget.customers.length;
    final someSelected = widget.selectedIds.isNotEmpty && !allSelected;

    return SizedBox(
      width: 20,
      child: Checkbox(
        value: allSelected ? true : (someSelected ? null : false),
        tristate: someSelected,
        onChanged: (value) {
          if (value == true) {
            widget.onSelectionChanged(
              widget.customers.map((c) => c.id).toSet(),
            );
          } else {
            widget.onSelectionChanged({});
          }
        },
        activeColor: AppColors.accent,
        side: const BorderSide(color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildSortableHeader(String label, String column) {
    final isSorted = _sortColumn == column;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_sortColumn == column) {
            _sortAscending = !_sortAscending;
          } else {
            _sortColumn = column;
            _sortAscending = true;
          }
        });
      },
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSorted ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
          if (isSorted) ...[
            const SizedBox(width: 4),
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: AppColors.accent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableBody() {
    final sortedCustomers = _sortCustomers(widget.customers);

    return ListView.builder(
      itemCount: sortedCustomers.length,
      itemBuilder: (context, index) {
        final customer = sortedCustomers[index];
        final isSelected = widget.selectedIds.contains(customer.id);

        return _buildTableRow(customer, isSelected);
      },
    );
  }

  Widget _buildTableRow(Customer customer, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onCustomerTap(customer),
      onSecondaryTapUp: (details) => _showContextMenu(details, customer),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentMuted : null,
          border: Border(
            bottom: BorderSide(color: AppColors.surfaceBorder.withAlpha(128)),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  final newIds = Set<String>.from(widget.selectedIds);
                  if (value == true) {
                    newIds.add(customer.id);
                  } else {
                    newIds.remove(customer.id);
                  }
                  widget.onSelectionChanged(newIds);
                },
                activeColor: AppColors.accent,
                side: const BorderSide(color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: Text(
                customer.name,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                customer.email ?? '-',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: CustomerSegmentBadge(segment: customer.segment),
            ),
            Expanded(
              flex: 1,
              child: CustomerHealthScoreBadge(score: customer.healthScore),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${customer.totalInteractions}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '\$${customer.totalRevenue.toStringAsFixed(0)}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.textTertiary,
              ),
              onSelected: (value) => _handleMenuAction(value, customer),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(TapUpDetails details, Customer customer) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: [
        const PopupMenuItem(value: 'view', child: Text('View Details')),
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    ).then((value) {
      if (value != null) _handleMenuAction(value, customer);
    });
  }

  void _handleMenuAction(String action, Customer customer) {
    switch (action) {
      case 'view':
        widget.onView(customer);
        break;
      case 'edit':
        widget.onEdit(customer);
        break;
      case 'delete':
        widget.onDelete(customer);
        break;
    }
  }

  List<Customer> _sortCustomers(List<Customer> customers) {
    if (_sortColumn == null) return customers;

    final sorted = List<Customer>.from(customers);
    sorted.sort((a, b) {
      int comparison;
      switch (_sortColumn) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'email':
          comparison = (a.email ?? '').compareTo(b.email ?? '');
          break;
        case 'segment':
          comparison = a.segment.index.compareTo(b.segment.index);
          break;
        case 'health':
          comparison = a.healthScore.compareTo(b.healthScore);
          break;
        case 'interactions':
          comparison = a.totalInteractions.compareTo(b.totalInteractions);
          break;
        case 'revenue':
          comparison = a.totalRevenue.compareTo(b.totalRevenue);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return sorted;
  }
}
