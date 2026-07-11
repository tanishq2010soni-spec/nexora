import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SidebarItem {
  final String label;
  final String route;
  final IconData icon;
  final int? badgeCount;

  const SidebarItem({
    required this.label,
    required this.route,
    required this.icon,
    this.badgeCount,
  });
}

class AppSidebar extends StatelessWidget {
  final List<SidebarItem> items;
  final String currentRoute;
  final String? organizationName;
  final String? userName;
  final String? userAvatar;
  final VoidCallback? onLogout;

  const AppSidebar({
    super.key,
    required this.items,
    required this.currentRoute,
    this.organizationName,
    this.userName,
    this.userAvatar,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: items.map((item) => _buildNavItem(context, item)).toList(),
              ),
            ),
          ),
          _buildUserSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'WA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              organizationName ?? 'WhatsApp Agent',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, SidebarItem item) {
    final isActive = _isActive(item.route);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(item.route),
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.sidebarHover,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.sidebarActive.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive
                  ? const Border(
                      left: BorderSide(color: AppColors.sidebarActive, width: 3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: isActive ? AppColors.primary : AppColors.sidebarItem,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isActive ? AppColors.textPrimary : AppColors.sidebarItem,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.unreadBadge,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              (userName ?? 'U').substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              userName ?? 'User',
              style: AppTypography.bodyMedium.copyWith(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onLogout != null)
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, size: 16),
              color: AppColors.textMuted,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            ),
        ],
      ),
    );
  }

  bool _isActive(String route) {
    if (route == '/') return currentRoute == '/';
    return currentRoute.startsWith(route);
  }
}
