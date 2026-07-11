import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/customer.dart';
import '../../providers/customer_provider.dart';
import '../widgets/customer_analytics_row.dart';
import '../widgets/customer_data_table.dart';
import '../widgets/customer_detail_panel.dart';
import '../widgets/customer_filters_row.dart';
import '../widgets/customer_form_dialog.dart';
import '../widgets/customer_search_bar.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  String _searchQuery = '';
  CustomerSegment? _segmentFilter;
  String? _assignedFilter;
  Set<String> _selectedCustomerIds = {};
  bool _isExporting = false;
  Customer? _selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: AppSpacing.xl),
          CustomerAnalyticsRow(),
          const SizedBox(height: AppSpacing.xl),
          _buildSearchAndFilters(),
          const SizedBox(height: AppSpacing.lg),
          if (_selectedCustomerIds.isNotEmpty) ...[
            _buildBulkActionsBar(context, ref),
            const SizedBox(height: AppSpacing.sm),
          ],
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(context, ref)
                : _buildCustomersList(context, ref, customersAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Customers',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        Row(
          children: [
            AppButton(
              label: 'Export CSV',
              variant: AppButtonVariant.secondary,
              icon: Icons.download_outlined,
              isLoading: _isExporting,
              onPressed: () => _exportCsv(context, ref),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: 'Add Customer',
              icon: Icons.add,
              onPressed: () => _showCreateCustomerDialog(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        CustomerSearchBar(
          hintText: 'Search customers by name, email, company...',
          onSearch: (query) => setState(() => _searchQuery = query),
        ),
        const SizedBox(height: AppSpacing.md),
        CustomerFiltersRow(
          selectedSegment: _segmentFilter,
          onSegmentChanged: (segment) =>
              setState(() => _segmentFilter = segment),
          onClear: () => setState(() {
            _segmentFilter = null;
            _assignedFilter = null;
          }),
        ),
      ],
    );
  }

  Widget _buildBulkActionsBar(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${_selectedCustomerIds.length} customer(s) selected',
            style: AppTypography.labelMedium.copyWith(color: AppColors.accent),
          ),
          const Spacer(),
          AppButton(
            label: 'Delete Selected',
            variant: AppButtonVariant.danger,
            isCompact: true,
            icon: Icons.delete_outline,
            onPressed: () => _bulkDeleteCustomers(context, ref),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: 'Clear Selection',
            variant: AppButtonVariant.ghost,
            isCompact: true,
            onPressed: () => setState(() => _selectedCustomerIds = {}),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Customer>> customersAsync,
  ) {
    return customersAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(customerListProvider),
      ),
      data: (customers) {
        final filtered = _applyFilters(customers);

        if (filtered.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline,
            title: 'No Customers Found',
            subtitle: _hasActiveFilters
                ? 'Try adjusting your filters or search query.'
                : 'Create your first customer to get started.',
            action: _hasActiveFilters
                ? AppButton(
                    label: 'Clear Filters',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => setState(() {
                      _segmentFilter = null;
                      _assignedFilter = null;
                      _searchQuery = '';
                    }),
                  )
                : AppButton(
                    label: 'Add Customer',
                    icon: Icons.add,
                    onPressed: () => _showCreateCustomerDialog(context, ref),
                  ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: CustomerDataTable(
                customers: filtered,
                selectedIds: _selectedCustomerIds,
                onCustomerTap: (customer) => _selectCustomer(customer),
                onEdit: (customer) =>
                    _showEditCustomerDialog(context, ref, customer),
                onDelete: (customer) =>
                    _confirmDeleteCustomer(context, ref, customer),
                onView: (customer) => _selectCustomer(customer),
                onSelectionChanged: (ids) =>
                    setState(() => _selectedCustomerIds = ids),
              ),
            ),
            if (_selectedCustomer != null) ...[
              const SizedBox(width: AppSpacing.lg),
              SizedBox(
                width: 480,
                child: CustomerDetailPanel(
                  customer: _selectedCustomer!,
                  onClose: () => setState(() => _selectedCustomer = null),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(
      customerSearchProvider((
        query: _searchQuery,
        segment: _segmentFilter?.name,
      )),
    );

    return searchAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(
          customerSearchProvider((
            query: _searchQuery,
            segment: _segmentFilter?.name,
          )),
        ),
      ),
      data: (customers) {
        if (customers.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'No Results',
            subtitle: 'No customers match your search for "$_searchQuery".',
          );
        }

        return CustomerDataTable(
          customers: customers,
          selectedIds: _selectedCustomerIds,
          onCustomerTap: (customer) => _selectCustomer(customer),
          onEdit: (customer) => _showEditCustomerDialog(context, ref, customer),
          onDelete: (customer) =>
              _confirmDeleteCustomer(context, ref, customer),
          onView: (customer) => _selectCustomer(customer),
          onSelectionChanged: (ids) =>
              setState(() => _selectedCustomerIds = ids),
        );
      },
    );
  }

  List<Customer> _applyFilters(List<Customer> customers) {
    var filtered = customers;

    if (_segmentFilter != null) {
      filtered = filtered.where((c) => c.segment == _segmentFilter).toList();
    }
    if (_assignedFilter != null) {
      filtered = filtered
          .where((c) => c.assignedTo == _assignedFilter)
          .toList();
    }

    return filtered;
  }

  bool get _hasActiveFilters =>
      _segmentFilter != null ||
      _assignedFilter != null ||
      _searchQuery.isNotEmpty;

  void _selectCustomer(Customer customer) {
    setState(() => _selectedCustomer = customer);
    ref.invalidate(customerDetailProvider(customer.id));
    ref.invalidate(customerActivitiesProvider(customer.id));
  }

  void _showCreateCustomerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => CustomerFormDialog(
        title: 'Add New Customer',
        onSave: (customer) async {
          await ref.read(createCustomerProvider(customer).future);
          ref.invalidate(customerListProvider);
          ref.invalidate(customerAnalyticsProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditCustomerDialog(
    BuildContext context,
    WidgetRef ref,
    Customer customer,
  ) {
    showDialog(
      context: context,
      builder: (_) => CustomerFormDialog(
        title: 'Edit Customer',
        customer: customer,
        onSave: (updatedCustomer) async {
          await ref.read(
            updateCustomerProvider((
              id: customer.id,
              customer: updatedCustomer,
            )).future,
          );
          ref.invalidate(customerListProvider);
          ref.invalidate(customerDetailProvider(customer.id));
          ref.invalidate(customerAnalyticsProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _confirmDeleteCustomer(
    BuildContext context,
    WidgetRef ref,
    Customer customer,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Customer',
      message:
          'Are you sure you want to delete "${customer.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await ref.read(deleteCustomerProvider(customer.id).future);
      ref.invalidate(customerListProvider);
      ref.invalidate(customerAnalyticsProvider);
      _selectedCustomerIds.remove(customer.id);
      if (_selectedCustomer?.id == customer.id) {
        setState(() => _selectedCustomer = null);
      }
    }
  }

  Future<void> _bulkDeleteCustomers(BuildContext context, WidgetRef ref) async {
    final count = _selectedCustomerIds.length;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Customers',
      message:
          'Are you sure you want to delete $count selected customer(s)? This action cannot be undone.',
      confirmLabel: 'Delete All',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      final repo = ref.read(customerRepositoryProvider);
      await repo.deleteCustomers(_selectedCustomerIds.toList());
      setState(() {
        _selectedCustomerIds = {};
        _selectedCustomer = null;
      });
      ref.invalidate(customerListProvider);
      ref.invalidate(customerAnalyticsProvider);
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    setState(() => _isExporting = true);
    try {
      final url = await ref.read(exportCustomersCsvProvider.future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV exported: $url'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Export failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
