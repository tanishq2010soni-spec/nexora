import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../router/route_names.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  static const _navItems = [
    _NavItem(RouteNames.dashboard, '/dashboard', Icons.dashboard_outlined, 'Dashboard'),
    _NavItem(RouteNames.liveCalls, '/live-calls', Icons.phone_in_talk_outlined, 'Live Calls'),
    _NavItem(RouteNames.callQueue, '/call-queue', Icons.queue_outlined, 'Call Queue'),
    _NavItem(RouteNames.campaigns, '/campaigns', Icons.campaign_outlined, 'Campaigns'),
    _NavItem(RouteNames.leads, '/leads', Icons.people_outline, 'Leads'),
    _NavItem(RouteNames.crm, '/crm', Icons.contacts_outlined, 'CRM'),
    _NavItem(RouteNames.knowledge, '/knowledge', Icons.menu_book_outlined, 'Knowledge'),
    _NavItem(RouteNames.analytics, '/analytics', Icons.analytics_outlined, 'Analytics'),
    _NavItem(RouteNames.recordings, '/recordings', Icons.mic_outlined, 'Recordings'),
    _NavItem(RouteNames.scripts, '/scripts', Icons.description_outlined, 'Scripts'),
    _NavItem(RouteNames.monitoring, '/monitoring', Icons.monitor_heart_outlined, 'Monitoring'),
    _NavItem(RouteNames.settings, '/settings', Icons.settings_outlined, 'Settings'),
    _NavItem(RouteNames.permissions, '/permissions', Icons.lock_outline, 'Permissions'),
    _NavItem(RouteNames.models, '/models', Icons.smart_toy_outlined, 'Models'),
    _NavItem(RouteNames.logs, '/logs', Icons.history_outlined, 'Logs'),
    _NavItem(RouteNames.health, '/health', Icons.favorite_outline, 'Health'),
    _NavItem(RouteNames.plugins, '/plugins', Icons.extension_outlined, 'Plugins'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return Container(
      width: 220,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.headset_mic,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Calling Agent',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final active = location == item.path ||
                    (location.startsWith(item.path) && item.path != '/dashboard' && location.length > item.path.length);
                return _SidebarItem(
                  item: item,
                  active: active,
                  onTap: () {
                    if (!active) {
                      context.go(item.path);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String name;
  final String path;
  final IconData icon;
  final String label;
  const _NavItem(this.name, this.path, this.icon, this.label);
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              if (active) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
