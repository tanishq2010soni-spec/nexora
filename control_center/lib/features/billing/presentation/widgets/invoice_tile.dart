import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/invoice.dart';

class InvoiceTile extends StatelessWidget {
  final Invoice invoice;

  const InvoiceTile({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          _buildStatusIcon(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(invoice.createdAt),
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  invoice.status.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: _statusColor(),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${invoice.amount.toStringAsFixed(2)}',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (invoice.invoiceUrl != null)
            IconButton(
              icon: const Icon(
                Icons.open_in_new,
                size: 16,
                color: AppColors.textTertiary,
              ),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    final color = _statusColor();
    final icon = switch (invoice.status.toLowerCase()) {
      'paid' => Icons.check_circle_outline,
      'pending' => Icons.schedule,
      'overdue' => Icons.error_outline,
      _ => Icons.receipt_long_outlined,
    };
    return Icon(icon, color: color, size: 20);
  }

  Color _statusColor() {
    return switch (invoice.status.toLowerCase()) {
      'paid' => AppColors.success,
      'pending' => AppColors.warning,
      'overdue' => AppColors.error,
      _ => AppColors.textTertiary,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
