import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/team_member.dart';

class MemberTile extends StatelessWidget {
  final TeamMember member;
  final VoidCallback? onTap;

  const MemberTile({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.email,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (member.roleName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentMuted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      member.roleName!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                _buildStatusDot(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = member.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.accent.withAlpha(40),
      child: Text(
        initials,
        style: AppTypography.labelMedium.copyWith(color: AppColors.accent),
      ),
    );
  }

  Widget _buildStatusDot() {
    final isActive = member.status == 'active';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.success : AppColors.textTertiary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: AppTypography.labelSmall.copyWith(
            color: isActive ? AppColors.success : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
