import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/stat_card.dart';
import '../../providers/customer_provider.dart';

class CustomerAnalyticsRow extends ConsumerWidget {
  const CustomerAnalyticsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(customerAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (analytics) => Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Total Customers',
              value: '${analytics.totalCustomers}',
              icon: Icons.people_outline,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              title: 'Active Customers',
              value: '${analytics.activeCustomers}',
              icon: Icons.person_outline,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              title: 'VIP Customers',
              value: '${analytics.vipCustomers}',
              icon: Icons.star_outline,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              title: 'Churn Risk',
              value: '${analytics.churnRiskCount}',
              icon: Icons.warning_amber_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              title: 'Avg Health Score',
              value: analytics.averageHealthScore.toStringAsFixed(0),
              icon: Icons.favorite_outline,
            ),
          ),
        ],
      ),
    );
  }
}
