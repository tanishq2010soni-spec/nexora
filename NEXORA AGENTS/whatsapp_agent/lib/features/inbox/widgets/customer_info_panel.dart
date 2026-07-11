import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/conversation.dart';

class CustomerInfoPanel extends StatelessWidget {
  final Conversation conversation;

  const CustomerInfoPanel({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          left: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(),
                  const SizedBox(height: 20),
                  _buildTagsSection(),
                  const SizedBox(height: 20),
                  _buildLeadStatus(),
                  const SizedBox(height: 20),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              conversation.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            conversation.displayName,
            style: AppTypography.headlineSmall,
          ),
          if (conversation.customerPhone != null) ...[
            const SizedBox(height: 4),
            Text(
              conversation.customerPhone!,
              style: AppTypography.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Information', style: AppTypography.labelLarge),
        const SizedBox(height: 12),
        _infoRow('Status', conversation.statusLabel),
        _infoRow('Department', conversation.department ?? 'General'),
        _infoRow('Assigned To', conversation.assignedToName ?? 'AI Agent'),
        _infoRow('Created', conversation.createdAt.toString().split('.').first),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: AppTypography.labelLarge),
        const SizedBox(height: 8),
        if (conversation.tags.isEmpty)
          Text('No tags', style: AppTypography.bodySmall)
        else
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: conversation.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(tag, style: AppTypography.labelSmall),
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildLeadStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lead Status', style: AppTypography.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 6, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Active', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions', style: AppTypography.labelLarge),
        const SizedBox(height: 8),
        _actionButton(Icons.phone_rounded, 'Call'),
        const SizedBox(height: 4),
        _actionButton(Icons.email_rounded, 'Email'),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 14),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.inputBorder),
          padding: const EdgeInsets.symmetric(vertical: 8),
          textStyle: AppTypography.bodySmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

extension on Conversation {
  String get statusLabel {
    switch (status) {
      case 'active': return 'Active';
      case 'archived': return 'Archived';
      case 'resolved': return 'Resolved';
      default: return status;
    }
  }
}
