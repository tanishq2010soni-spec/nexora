import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_provider.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final conversationProvider = context.watch<ConversationProvider>();

    final items = [
      const SidebarItem(label: 'Dashboard', route: '/', icon: Icons.dashboard_rounded),
      SidebarItem(
        label: 'Inbox',
        route: '/inbox',
        icon: Icons.chat_rounded,
        badgeCount: conversationProvider.unreadCount,
      ),
      const SidebarItem(label: 'CRM', route: '/crm', icon: Icons.people_rounded),
      const SidebarItem(label: 'Knowledge', route: '/knowledge', icon: Icons.menu_book_rounded),
      const SidebarItem(label: 'Workflows', route: '/workflows', icon: Icons.alt_route_rounded),
      const SidebarItem(label: 'Campaigns', route: '/campaigns', icon: Icons.campaign_rounded),
      const SidebarItem(label: 'Analytics', route: '/analytics', icon: Icons.analytics_rounded),
      const SidebarItem(label: 'Settings', route: '/settings', icon: Icons.settings_rounded),
      const SidebarItem(label: 'Permissions', route: '/permissions', icon: Icons.admin_panel_settings_rounded),
      const SidebarItem(label: 'Models', route: '/models', icon: Icons.smart_toy_rounded),
      const SidebarItem(label: 'Logs', route: '/logs', icon: Icons.receipt_long_rounded),
      const SidebarItem(label: 'Health', route: '/health', icon: Icons.monitor_heart_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Row(
        children: [
          AppSidebar(
            items: items,
            currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
            organizationName: auth.user?.name,
            userName: auth.user?.name,
            onLogout: () => auth.logout(),
          ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, auth),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(context),
            style: AppTypography.headlineMedium.copyWith(fontSize: 15),
          ),
          const Spacer(),
          if (auth.user != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    auth.user!.role.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    (auth.user!.name.isNotEmpty ? auth.user!.name[0] : 'U').toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getPageTitle(BuildContext context) {
    final uri = Uri.base;
    final path = uri.path;
    if (path == '/' || path.isEmpty) return 'Dashboard';
    final parts = path.split('/');
    if (parts.length >= 2) {
      return '${parts[1][0].toUpperCase()}${parts[1].substring(1)}';
    }
    return 'Dashboard';
  }
}
