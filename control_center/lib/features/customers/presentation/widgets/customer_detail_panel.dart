import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/models/customer.dart';
import '../../providers/customer_provider.dart';
import '../widgets/customer_activity_timeline.dart';
import '../widgets/customer_health_score_card.dart';
import '../widgets/customer_notes_widget.dart';
import '../widgets/customer_segment_badge.dart';

class CustomerDetailPanel extends ConsumerStatefulWidget {
  final Customer customer;
  final VoidCallback onClose;

  const CustomerDetailPanel({
    super.key,
    required this.customer,
    required this.onClose,
  });

  @override
  ConsumerState<CustomerDetailPanel> createState() =>
      _CustomerDetailPanelState();
}

class _CustomerDetailPanelState extends ConsumerState<CustomerDetailPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(customerDetailProvider(widget.customer.id));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          _buildHeader(customerAsync),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(customerAsync),
                _buildTimelineTab(),
                _buildMemoryTab(),
                _buildNotesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AsyncValue<Customer> customerAsync) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accentMuted,
            child: Text(
              widget.customer.name.substring(0, 1).toUpperCase(),
              style: AppTypography.h3.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer.name,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.customer.email ?? widget.customer.company ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          CustomerSegmentBadge(segment: widget.customer.segment),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: widget.onClose,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.accent,
        labelStyle: AppTypography.labelMedium,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Timeline'),
          Tab(text: 'Memory'),
          Tab(text: 'Notes'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AsyncValue<Customer> customerAsync) {
    return customerAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => Center(
        child: Text(
          'Failed to load customer details',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (customer) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomerHealthScoreCard(customer: customer),
            const SizedBox(height: AppSpacing.xl),
            _buildInfoSection('Contact Information', [
              _buildInfoRow(
                Icons.email_outlined,
                'Email',
                customer.email ?? '-',
              ),
              _buildInfoRow(
                Icons.phone_outlined,
                'Phone',
                customer.phone ?? '-',
              ),
              _buildInfoRow(
                Icons.business_outlined,
                'Company',
                customer.company ?? '-',
              ),
              _buildInfoRow(
                Icons.work_outlined,
                'Job Title',
                customer.jobTitle ?? '-',
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),
            _buildInfoSection('Customer Details', [
              _buildInfoRow(
                Icons.star_outline,
                'Segment',
                customer.segment.name,
              ),
              _buildInfoRow(
                Icons.person_outline,
                'Assigned To',
                customer.assignedToName ?? '-',
              ),
              _buildInfoRow(
                Icons.link_outlined,
                'Lead Source',
                customer.leadId ?? '-',
              ),
              _buildInfoRow(
                Icons.calendar_today,
                'Created',
                _formatDate(customer.createdAt),
              ),
              _buildInfoRow(
                Icons.access_time,
                'Last Interaction',
                customer.lastInteractionAt != null
                    ? _formatDate(customer.lastInteractionAt!)
                    : '-',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    return CustomerActivityTimeline(customerId: widget.customer.id);
  }

  Widget _buildMemoryTab() {
    final memory = widget.customer.memory ?? {};
    final preferences = widget.customer.preferences ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Memory',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (memory.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Text(
                'No AI memory recorded yet.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            ...memory.entries.map(
              (entry) => _buildMemoryItem(entry.key, '${entry.value}'),
            ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Preferences',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (preferences.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Text(
                'No preferences recorded yet.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            ...preferences.entries.map(
              (entry) => _buildMemoryItem(entry.key, '${entry.value}'),
            ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Tags',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.customer.tags.isEmpty)
            Text(
              'No tags assigned.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: widget.customer.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: AppColors.accentMuted,
                      labelStyle: AppTypography.labelSmall.copyWith(
                        color: AppColors.accent,
                      ),
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMemoryItem(String key, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return CustomerNotesWidget(customerId: widget.customer.id);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
