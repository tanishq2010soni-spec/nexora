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
import '../../domain/models/lead.dart';
import '../../providers/lead_provider.dart';
import '../widgets/lead_analytics_row.dart';
import '../widgets/lead_data_table.dart';
import '../widgets/lead_filters_row.dart';
import '../widgets/lead_form_dialog.dart';
import '../widgets/lead_search_bar.dart';

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  String _searchQuery = '';
  LeadStatus? _statusFilter;
  LeadSource? _sourceFilter;
  String? _assignedFilter;
  Set<String> _selectedLeadIds = {};
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(leadListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: AppSpacing.xl),
          LeadAnalyticsRow(),
          const SizedBox(height: AppSpacing.xl),
          _buildSearchAndFilters(),
          const SizedBox(height: AppSpacing.lg),
          if (_selectedLeadIds.isNotEmpty) ...[
            _buildBulkActionsBar(context, ref),
            const SizedBox(height: AppSpacing.sm),
          ],
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(context, ref)
                : _buildLeadsList(context, ref, leadsAsync),
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
          'Leads',
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
              label: 'Add Lead',
              icon: Icons.add,
              onPressed: () => _showCreateLeadDialog(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        LeadSearchBar(
          hintText: 'Search leads by name, email, company...',
          onSearch: (query) => setState(() => _searchQuery = query),
        ),
        const SizedBox(height: AppSpacing.md),
        LeadFiltersRow(
          selectedStatus: _statusFilter,
          selectedSource: _sourceFilter,
          onStatusChanged: (status) => setState(() => _statusFilter = status),
          onSourceChanged: (source) => setState(() => _sourceFilter = source),
          onClear: () => setState(() {
            _statusFilter = null;
            _sourceFilter = null;
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
            '${_selectedLeadIds.length} lead(s) selected',
            style: AppTypography.labelMedium.copyWith(color: AppColors.accent),
          ),
          const Spacer(),
          AppButton(
            label: 'Delete Selected',
            variant: AppButtonVariant.danger,
            isCompact: true,
            icon: Icons.delete_outline,
            onPressed: () => _bulkDeleteLeads(context, ref),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: 'Clear Selection',
            variant: AppButtonVariant.ghost,
            isCompact: true,
            onPressed: () => setState(() => _selectedLeadIds = {}),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Lead>> leadsAsync,
  ) {
    return leadsAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(leadListProvider),
      ),
      data: (leads) {
        final filtered = _applyFilters(leads);

        if (filtered.isEmpty) {
          return EmptyState(
            icon: Icons.people_outline,
            title: 'No Leads Found',
            subtitle: _hasActiveFilters
                ? 'Try adjusting your filters or search query.'
                : 'Create your first lead to get started.',
            action: _hasActiveFilters
                ? AppButton(
                    label: 'Clear Filters',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => setState(() {
                      _statusFilter = null;
                      _sourceFilter = null;
                      _assignedFilter = null;
                      _searchQuery = '';
                    }),
                  )
                : AppButton(
                    label: 'Add Lead',
                    icon: Icons.add,
                    onPressed: () => _showCreateLeadDialog(context, ref),
                  ),
          );
        }

        return LeadDataTable(
          leads: filtered,
          selectedIds: _selectedLeadIds,
          onLeadTap: (lead) => _showLeadDetail(context, ref, lead),
          onEdit: (lead) => _showEditLeadDialog(context, ref, lead),
          onDelete: (lead) => _confirmDeleteLead(context, ref, lead),
          onAssign: (lead) => _showAssignDialog(context, ref, lead),
          onView: (lead) => _showLeadDetail(context, ref, lead),
          onSelectionChanged: (ids) => setState(() => _selectedLeadIds = ids),
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(
      leadSearchProvider((
        query: _searchQuery,
        status: _statusFilter?.name,
        source: _sourceFilter?.name,
      )),
    );

    return searchAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(
          leadSearchProvider((
            query: _searchQuery,
            status: _statusFilter?.name,
            source: _sourceFilter?.name,
          )),
        ),
      ),
      data: (leads) {
        if (leads.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            title: 'No Results',
            subtitle: 'No leads match your search for "$_searchQuery".',
          );
        }

        return LeadDataTable(
          leads: leads,
          selectedIds: _selectedLeadIds,
          onLeadTap: (lead) => _showLeadDetail(context, ref, lead),
          onEdit: (lead) => _showEditLeadDialog(context, ref, lead),
          onDelete: (lead) => _confirmDeleteLead(context, ref, lead),
          onAssign: (lead) => _showAssignDialog(context, ref, lead),
          onView: (lead) => _showLeadDetail(context, ref, lead),
          onSelectionChanged: (ids) => setState(() => _selectedLeadIds = ids),
        );
      },
    );
  }

  List<Lead> _applyFilters(List<Lead> leads) {
    var filtered = leads;

    if (_statusFilter != null) {
      filtered = filtered.where((l) => l.status == _statusFilter).toList();
    }
    if (_sourceFilter != null) {
      filtered = filtered.where((l) => l.source == _sourceFilter).toList();
    }
    if (_assignedFilter != null) {
      filtered = filtered
          .where((l) => l.assignedTo == _assignedFilter)
          .toList();
    }

    return filtered;
  }

  bool get _hasActiveFilters =>
      _statusFilter != null ||
      _sourceFilter != null ||
      _assignedFilter != null ||
      _searchQuery.isNotEmpty;

  void _showCreateLeadDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => LeadFormDialog(
        title: 'Add New Lead',
        onSave: (lead) async {
          await ref.read(createLeadProvider(lead).future);
          ref.invalidate(leadListProvider);
          ref.invalidate(leadAnalyticsProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditLeadDialog(BuildContext context, WidgetRef ref, Lead lead) {
    showDialog(
      context: context,
      builder: (_) => LeadFormDialog(
        title: 'Edit Lead',
        lead: lead,
        onSave: (updatedLead) async {
          await ref.read(
            updateLeadProvider((id: lead.id, lead: updatedLead)).future,
          );
          ref.invalidate(leadListProvider);
          ref.invalidate(leadDetailProvider(lead.id));
          ref.invalidate(leadAnalyticsProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showLeadDetail(BuildContext context, WidgetRef ref, Lead lead) {
    // Lead detail panel would be shown in a split view or side panel on desktop
    ref.invalidate(leadDetailProvider(lead.id));
    ref.invalidate(leadActivitiesProvider(lead.id));
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref, Lead lead) {
    // Show a simple dialog with user selection - placeholder for assign logic
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Assign Lead',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Assignment functionality requires user list integration.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          AppButton(
            label: 'Close',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteLead(
    BuildContext context,
    WidgetRef ref,
    Lead lead,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Lead',
      message:
          'Are you sure you want to delete "${lead.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await ref.read(deleteLeadProvider(lead.id).future);
      ref.invalidate(leadListProvider);
      ref.invalidate(leadAnalyticsProvider);
      _selectedLeadIds.remove(lead.id);
    }
  }

  Future<void> _bulkDeleteLeads(BuildContext context, WidgetRef ref) async {
    final count = _selectedLeadIds.length;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Leads',
      message:
          'Are you sure you want to delete $count selected lead(s)? This action cannot be undone.',
      confirmLabel: 'Delete All',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      final repo = ref.read(leadRepositoryProvider);
      await repo.deleteLeads(_selectedLeadIds.toList());
      setState(() => _selectedLeadIds = {});
      ref.invalidate(leadListProvider);
      ref.invalidate(leadAnalyticsProvider);
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    setState(() => _isExporting = true);
    try {
      final url = await ref.read(exportLeadsCsvProvider.future);
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
