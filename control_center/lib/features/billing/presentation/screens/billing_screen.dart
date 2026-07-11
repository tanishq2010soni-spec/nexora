import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/plan.dart';
import '../../domain/models/subscription.dart';
import '../../providers/billing_provider.dart';
import '../widgets/plan_card.dart';
import '../widgets/invoice_tile.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen>
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xl),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlansTab(),
                _buildSubscriptionTab(),
                _buildInvoicesTab(),
                _buildUsageTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Billing & Subscriptions',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: AppColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.surfaceBorder,
        tabs: const [
          Tab(text: 'Plans'),
          Tab(text: 'Subscription'),
          Tab(text: 'Invoices'),
          Tab(text: 'Usage'),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    final plansAsync = ref.watch(planListProvider);

    return plansAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(planListProvider),
      ),
      data: (plans) {
        if (plans.isEmpty) {
          return EmptyState(
            icon: Icons.credit_card_outlined,
            title: 'No Plans Available',
            subtitle: 'Plans will appear here when configured.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          itemCount: plans.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) => PlanCard(
            plan: plans[index],
            onSelect: () => _subscribeToPlan(context, plans[index]),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionTab() {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return subscriptionAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(subscriptionProvider),
      ),
      data: (sub) => _buildSubscriptionInfo(sub),
    );
  }

  Widget _buildSubscriptionInfo(Subscription sub) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Current Plan',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildStatusBadge(sub.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildInfoRow('Plan', sub.planName),
            _buildInfoRow(
              'Amount',
              '\$${sub.amount.toStringAsFixed(2)}/${sub.interval}',
            ),
            if (sub.currentPeriodStart != null)
              _buildInfoRow(
                'Period Start',
                _formatDate(sub.currentPeriodStart!),
              ),
            if (sub.currentPeriodEnd != null)
              _buildInfoRow('Period End', _formatDate(sub.currentPeriodEnd!)),
            if (sub.cancelAt != null)
              _buildInfoRow('Cancels At', _formatDate(sub.cancelAt!)),
            const SizedBox(height: AppSpacing.xl),
            if (sub.status != 'cancelled')
              AppButton(
                label: 'Cancel Subscription',
                variant: AppButtonVariant.danger,
                onPressed: () => _cancelSubscription(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = switch (status.toLowerCase()) {
      'active' => AppColors.success,
      'cancelled' => AppColors.error,
      'past_due' => AppColors.warning,
      _ => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }

  Widget _buildInvoicesTab() {
    final invoicesAsync = ref.watch(invoiceListProvider);

    return invoicesAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(invoiceListProvider),
      ),
      data: (invoices) {
        if (invoices.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No Invoices',
            subtitle: 'Your invoices will appear here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          itemCount: invoices.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) =>
              InvoiceTile(invoice: invoices[index]),
        );
      },
    );
  }

  Widget _buildUsageTab() {
    final usageAsync = ref.watch(usageProvider);

    return usageAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(usageProvider),
      ),
      data: (usage) => _buildUsageContent(usage),
    );
  }

  Widget _buildUsageContent(Map<String, dynamic> usage) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        children: [
          _buildUsageCard(
            title: 'Messages Sent',
            current: (usage['messagesSent'] as num?)?.toInt() ?? 0,
            limit: (usage['messagesLimit'] as num?)?.toInt() ?? 0,
            icon: Icons.message_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildUsageCard(
            title: 'API Calls',
            current: (usage['apiCalls'] as num?)?.toInt() ?? 0,
            limit: (usage['apiCallsLimit'] as num?)?.toInt() ?? 0,
            icon: Icons.api_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildUsageCard(
            title: 'Storage',
            current: (usage['storageUsedMb'] as num?)?.toInt() ?? 0,
            limit: (usage['storageLimitMb'] as num?)?.toInt() ?? 0,
            icon: Icons.storage_outlined,
            unit: 'MB',
          ),
        ],
      ),
    );
  }

  Widget _buildUsageCard({
    required String title,
    required int current,
    required int limit,
    required IconData icon,
    String unit = '',
  }) {
    final percentage = limit > 0 ? (current / limit).clamp(0.0, 1.0) : 0.0;
    final color = percentage > 0.9
        ? AppColors.error
        : percentage > 0.7
        ? AppColors.warning
        : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$current$unit / $limit$unit',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.surfaceBorder,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _subscribeToPlan(BuildContext context, Plan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Subscribe to ${plan.name}',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Subscribe to ${plan.name} for \$${plan.price.toStringAsFixed(0)}/${plan.interval}?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: 'Subscribe',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(createSubscriptionProvider(plan.id).future);
      ref.invalidate(subscriptionProvider);
    }
  }

  void _cancelSubscription(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: Text(
          'Cancel Subscription',
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to cancel your subscription?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          AppButton(
            label: 'Keep',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: 'Cancel Subscription',
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(cancelSubscriptionProvider.future);
      ref.invalidate(subscriptionProvider);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
