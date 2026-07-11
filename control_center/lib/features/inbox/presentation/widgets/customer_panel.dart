import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/customer_side_panel.dart';

class CustomerPanel extends StatelessWidget {
  final CustomerSidePanel? customer;

  const CustomerPanel({super.key, this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Expanded(
            child: customer == null
                ? const Center(
                    child: Text(
                      'No customer data',
                      style: AppTypography.bodyMedium,
                    ),
                  )
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              customer?.name ?? '',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final c = customer!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.email_outlined,
            'Email',
            c.email ?? 'Not provided',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            Icons.phone_outlined,
            'Phone',
            c.phone ?? 'Not provided',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            Icons.group_outlined,
            'Segment',
            c.segment ?? 'General',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (c.tags.isNotEmpty) ...[
            _buildSectionTitle('Tags'),
            const SizedBox(height: AppSpacing.sm),
            _buildTags(c.tags),
            const SizedBox(height: AppSpacing.lg),
          ],
          _buildSectionTitle('Notes'),
          const SizedBox(height: AppSpacing.sm),
          _buildNotes(c.notes),
          const SizedBox(height: AppSpacing.lg),
          _buildSectionTitle('Activity'),
          const SizedBox(height: AppSpacing.sm),
          _buildActivityStats(c),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildTags(List<String> tags) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withAlpha(80)),
          ),
          child: Text(
            tag,
            style: AppTypography.labelSmall.copyWith(color: AppColors.accent),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotes(String? notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Text(
        notes ?? 'No notes',
        style: AppTypography.bodySmall.copyWith(
          color: notes != null
              ? AppColors.textSecondary
              : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildActivityStats(CustomerSidePanel c) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildStatRow('Total Conversations', '${c.totalConversations}'),
          const SizedBox(height: AppSpacing.sm),
          _buildStatRow('Total Messages', '${c.totalMessages}'),
          if (c.firstSeenAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildStatRow('First Seen', _formatDate(c.firstSeenAt!)),
          ],
          if (c.lastSeenAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildStatRow('Last Seen', _formatDate(c.lastSeenAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
