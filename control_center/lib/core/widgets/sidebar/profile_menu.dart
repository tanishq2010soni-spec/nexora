import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/session_manager.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ProfileMenu extends ConsumerStatefulWidget {
  final bool isCollapsed;

  const ProfileMenu({super.key, this.isCollapsed = false});

  @override
  ConsumerState<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends ConsumerState<ProfileMenu> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionManagerProvider);

    if (widget.isCollapsed) {
      return GestureDetector(
        onTap: () => _showProfileSheet(context, session),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
          ),
          child: const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.accent,
            child: Icon(Icons.person, size: 14, color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isOpen = !_isOpen),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          session.email?.split('@').first ?? 'User',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          session.role ?? 'member',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isOpen ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_isOpen) ...[
            _buildMenuItem(
              icon: Icons.account_circle_outlined,
              label: 'My Profile',
              onTap: () {
                setState(() => _isOpen = false);
                context.go('/settings');
              },
            ),
            _buildMenuItem(
              icon: Icons.logout,
              label: 'Sign Out',
              onTap: () async {
                setState(() => _isOpen = false);
                await ref.read(sessionManagerProvider.notifier).forceLogout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: AppColors.sidebarHover,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context, session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session.email?.split('@').first ?? 'User',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    session.email ?? '',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _buildSheetItem(
              ctx,
              Icons.account_circle_outlined,
              'My Profile',
              () {
                Navigator.pop(ctx);
                context.go('/settings');
              },
            ),
            _buildSheetItem(ctx, Icons.logout, 'Sign Out', () async {
              Navigator.pop(ctx);
              await ref.read(sessionManagerProvider.notifier).forceLogout();
              if (context.mounted) context.go('/login');
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetItem(
    BuildContext ctx,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      onTap: onTap,
    );
  }
}
