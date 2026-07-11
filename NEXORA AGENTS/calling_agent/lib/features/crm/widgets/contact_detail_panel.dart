import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ContactDetailPanel extends StatelessWidget {
  final Map<String, String> contact;
  final VoidCallback? onEdit;
  final VoidCallback? onCall;

  const ContactDetailPanel({
    super.key,
    required this.contact,
    this.onEdit,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                child: Text(
                  (contact['name'] ?? '?')[0],
                  style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact['name'] ?? '', style: AppTypography.titleLarge),
                    Text(contact['company'] ?? '', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.phone_in_talk, color: AppColors.success), onPressed: onCall),
            ],
          ),
          const Divider(height: 24),
          _buildDetailRow(Icons.phone, contact['phone'] ?? ''),
          _buildDetailRow(Icons.email, contact['email'] ?? ''),
          _buildDetailRow(Icons.business, contact['title'] ?? ''),
          if (contact['notes'] != null && contact['notes']!.isNotEmpty) ...[
            const Divider(height: 16),
            Text('Notes', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Text(contact['notes']!, style: AppTypography.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Text(value, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
