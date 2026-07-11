import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/filter_bar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/lead.dart';
import '../../providers/lead_provider.dart';
import 'widgets/lead_detail_panel.dart';
import 'widgets/lead_form.dart';

class CrmScreen extends StatefulWidget {
  const CrmScreen({super.key});

  @override
  State<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends State<CrmScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _expandedLeadId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeadProvider>().loadLeads();
      context.read<LeadProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeadProvider>();
    final leads = provider.filteredLeads;
    final customers = provider.customers;

    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        children: [
          _buildHeader(provider),
          Expanded(
            child: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLeadsTab(provider, leads),
                      _buildCustomersTab(provider, customers),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LeadProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CRM', style: AppTypography.displaySmall),
                    const SizedBox(height: 4),
                    Text('Manage leads and customers', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              AppButton(
                label: 'Add Lead',
                icon: Icons.add,
                onPressed: () => _showLeadForm(context, null),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: StatCard(icon: Icons.people_rounded, label: 'Total Leads', value: '${provider.leads.length}', iconColor: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.person_add_rounded, label: 'Qualified', value: '${provider.leads.where((l) => l.status == 'qualified').length}', iconColor: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.check_circle_rounded, label: 'Converted', value: '${provider.customers.length}', iconColor: AppColors.info)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.trending_up_rounded, label: 'Avg Score', value: '${provider.leads.isEmpty ? 0 : (provider.leads.fold<int>(0, (s, l) => s + l.score.toInt()) / provider.leads.length).toStringAsFixed(0)}%', iconColor: AppColors.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Leads'),
            Tab(text: 'Customers'),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsTab(LeadProvider provider, List leads) {
    return Column(
      children: [
        FilterBar(
          searchHint: 'Search leads...',
          onSearchChanged: (q) => provider.setSearchQuery(q),
          dropdowns: [
            FilterDropdown(
              label: 'Stage',
              value: '',
              items: [DropdownMenuItem(value: '', child: Text('All Stages')), ...Lead.stages.map((s) => DropdownMenuItem(value: s, child: Text(s[0].toUpperCase() + s.substring(1))))],
              onChanged: (v) => provider.setStageFilter(v ?? ''),
            ),
            FilterDropdown(
              label: 'Status',
              value: '',
              items: const [DropdownMenuItem(value: '', child: Text('All Status')), DropdownMenuItem(value: 'new', child: Text('New')), DropdownMenuItem(value: 'contacted', child: Text('Contacted')), DropdownMenuItem(value: 'qualified', child: Text('Qualified')), DropdownMenuItem(value: 'lost', child: Text('Lost'))],
              onChanged: (v) => provider.setStatusFilter(v ?? ''),
            ),
          ],
        ),
        Expanded(
          child: leads.isEmpty
              ? const EmptyState(icon: Icons.people_outline_rounded, title: 'No leads found', subtitle: 'Create your first lead to get started')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: leads.length,
                  itemExtent: _expandedLeadId != null ? 400 : 56,
                  itemBuilder: (context, index) {
                    final lead = leads[index];
                    final isExpanded = _expandedLeadId == lead.id;
                    return _buildLeadRow(provider, lead, isExpanded, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLeadRow(LeadProvider provider, dynamic lead, bool isExpanded, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isExpanded ? AppColors.primary.withValues(alpha: 0.3) : AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expandedLeadId = isExpanded ? null : lead.id),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: lead.score >= 80 ? AppColors.success.withValues(alpha: 0.2) : lead.score >= 50 ? AppColors.warning.withValues(alpha: 0.2) : AppColors.textMuted.withValues(alpha: 0.2),
                      child: Text(lead.name[0].toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: lead.score >= 80 ? AppColors.success : lead.score >= 50 ? AppColors.warning : AppColors.textMuted)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: Text(lead.name, style: AppTypography.titleMedium, overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 2, child: Text(lead.phone ?? '-', style: AppTypography.bodyMedium)),
                    Expanded(flex: 1, child: _statusBadge(lead.statusLabel, lead.status == 'won' ? AppColors.success : lead.status == 'lost' ? AppColors.error : AppColors.primary)),
                    Expanded(flex: 1, child: Text('${lead.score.toStringAsFixed(0)}%', style: AppTypography.bodyMedium.copyWith(color: lead.score >= 80 ? AppColors.success : lead.score >= 50 ? AppColors.warning : AppColors.textMuted))),
                    Expanded(flex: 1, child: Text(lead.source ?? '-', style: AppTypography.bodyMedium)),
                    Expanded(flex: 1, child: _statusBadge(lead.stage[0].toUpperCase() + lead.stage.substring(1), AppColors.info)),
                    Expanded(flex: 1, child: Text(lead.assignedToName ?? '-', style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 1, child: Text(lead.createdAt.toString().split('T').first, style: AppTypography.bodySmall)),
                    Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.all(16),
                child: LeadDetailPanel(
                  lead: lead,
                  onEdit: () => _showLeadForm(context, lead),
                  onConvert: lead.status != 'won' && lead.status != 'lost'
                      ? () async {
                          final converted = await provider.convertLead(lead.id, {});
                          if (converted != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lead converted to customer')),
                            );
                          }
                        }
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomersTab(LeadProvider provider, List customers) {
    return customers.isEmpty
        ? const EmptyState(icon: Icons.people_outline_rounded, title: 'No customers yet', subtitle: 'Convert leads to customers')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: Text(customer.initials, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: Text(customer.name, style: AppTypography.titleMedium)),
                    Expanded(flex: 2, child: Text(customer.phone ?? '-', style: AppTypography.bodyMedium)),
                    Expanded(flex: 2, child: Text(customer.email ?? '-', style: AppTypography.bodyMedium)),
                    Expanded(flex: 1, child: _statusBadge(customer.tier ?? 'Standard', AppColors.info)),
                    Expanded(flex: 1, child: Text(customer.lastContactAt?.toString().split('T').first ?? '-', style: AppTypography.bodySmall)),
                    Expanded(flex: 1, child: Text('\$${customer.totalSpent.toStringAsFixed(2)}', style: AppTypography.bodyMedium.copyWith(color: AppColors.success))),
                  ],
                ),
              );
            },
          );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  void _showLeadForm(BuildContext context, dynamic lead) {
    showDialog(
      context: context,
      builder: (ctx) => LeadFormDialog(lead: lead),
    ).then((result) {
      if (result != null && mounted) {
        final provider = context.read<LeadProvider>();
        if (lead != null) {
          provider.updateLead(lead.id, result as Map<String, dynamic>);
        } else {
          provider.createLead(result as Map<String, dynamic>);
        }
      }
    });
  }
}
