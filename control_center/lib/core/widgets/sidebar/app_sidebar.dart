import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'sidebar_item.dart';
import 'profile_menu.dart';
import 'organization_switcher.dart';

class AppSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const AppSidebar({
    super.key,
    this.isCollapsed = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isCollapsed
          ? AppSpacing.sidebarCollapsedWidth
          : AppSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(right: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          Expanded(child: _buildNavigation(context, currentPath)),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(child: OrganizationSwitcher(isCollapsed: isCollapsed)),
        if (!isCollapsed)
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: onToggle,
            color: AppColors.textTertiary,
          ),
        if (isCollapsed)
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: onToggle,
            color: AppColors.textTertiary,
          ),
      ],
    );
  }

  Widget _buildNavigation(BuildContext context, String currentPath) {
    final isAgentSection = currentPath.startsWith('/agents');

    final items = [
      SidebarItem(
        icon: Icons.dashboard_outlined,
        label: 'Dashboard',
        route: '/dashboard',
        isSelected: currentPath == '/dashboard',
        onTap: () => context.go('/dashboard'),
        isCollapsed: isCollapsed,
      ),
      SidebarItem(
        icon: Icons.smart_toy_outlined,
        label: 'Agent Center',
        route: '/agents',
        isSelected: isAgentSection,
        onTap: () => context.go('/agents'),
        isExpandable: true,
        isExpanded: isAgentSection,
        isCollapsed: isCollapsed,
        children: isCollapsed
            ? []
            : [
                SidebarItem(
                  icon: Icons.chat_outlined,
                  label: 'WhatsApp',
                  route: '/agents/whatsapp',
                  isSelected: currentPath.startsWith('/agents/whatsapp'),
                  onTap: () => context.go('/agents/whatsapp'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.call_outlined,
                  label: 'Calling',
                  route: '/agents/calling',
                  isSelected: currentPath.startsWith('/agents/calling'),
                  onTap: () => context.go('/agents/calling'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.copy_outlined,
                  label: 'Templates',
                  route: '/agents/templates',
                  isSelected: currentPath.startsWith('/agents/templates'),
                  onTap: () => context.go('/agents/templates'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  route: '/agents/analytics',
                  isSelected: currentPath.startsWith('/agents/analytics'),
                  onTap: () => context.go('/agents/analytics'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
              ],
      ),
      SidebarItem(
        icon: Icons.book_outlined,
        label: 'Knowledge Base',
        route: '/knowledge-base',
        isSelected: currentPath.startsWith('/knowledge-base'),
        onTap: () => context.go('/knowledge-base'),
        isCollapsed: isCollapsed,
      ),
      SidebarItem(
        icon: Icons.person_add_outlined,
        label: 'Leads',
        route: '/leads',
        isSelected: currentPath.startsWith('/leads'),
        onTap: () => context.go('/leads'),
        isCollapsed: isCollapsed,
      ),
      SidebarItem(
        icon: Icons.people_outlined,
        label: 'Customers',
        route: '/customers',
        isSelected: currentPath.startsWith('/customers'),
        onTap: () => context.go('/customers'),
        isCollapsed: isCollapsed,
      ),
      SidebarItem(
        icon: Icons.chat_outlined,
        label: 'Conversations',
        route: '/conversations',
        isSelected: currentPath.startsWith('/conversations'),
        onTap: () => context.go('/conversations'),
        isCollapsed: isCollapsed,
      ),
      SidebarItem(
        icon: Icons.analytics_outlined,
        label: 'Analytics',
        route: '/analytics',
        isSelected:
            currentPath.startsWith('/analytics') &&
            !currentPath.startsWith('/agents/analytics'),
        onTap: () => context.go('/analytics'),
        isCollapsed: isCollapsed,
      ),
    ];

    final platformSection = currentPath.startsWith('/agent-management') ||
        currentPath.startsWith('/providers') ||
        currentPath.startsWith('/models') ||
        currentPath.startsWith('/tools') ||
        currentPath.startsWith('/knowledge-sources') ||
        currentPath.startsWith('/workflow-engine') ||
        currentPath.startsWith('/licensing') ||
        currentPath.startsWith('/plugins');

    final platformItems = [
      SidebarItem(
        icon: Icons.extension_outlined,
        label: 'Platform',
        route: '/agent-management',
        isSelected: platformSection,
        onTap: () => context.go('/agent-management'),
        isExpandable: true,
        isExpanded: platformSection && !isCollapsed,
        isCollapsed: isCollapsed,
        children: isCollapsed
            ? []
            : [
                SidebarItem(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Agent Mgmt',
                  route: '/agent-management',
                  isSelected: currentPath.startsWith('/agent-management'),
                  onTap: () => context.go('/agent-management'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.cloud_outlined,
                  label: 'Providers',
                  route: '/providers',
                  isSelected: currentPath.startsWith('/providers'),
                  onTap: () => context.go('/providers'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.model_training_outlined,
                  label: 'Models',
                  route: '/models',
                  isSelected: currentPath.startsWith('/models'),
                  onTap: () => context.go('/models'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.build_outlined,
                  label: 'Tools',
                  route: '/tools',
                  isSelected: currentPath.startsWith('/tools'),
                  onTap: () => context.go('/tools'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.source_outlined,
                  label: 'Knowledge',
                  route: '/knowledge-sources',
                  isSelected: currentPath.startsWith('/knowledge-sources'),
                  onTap: () => context.go('/knowledge-sources'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.account_tree_outlined,
                  label: 'Workflows',
                  route: '/workflow-engine',
                  isSelected: currentPath.startsWith('/workflow-engine'),
                  onTap: () => context.go('/workflow-engine'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.vpn_key_outlined,
                  label: 'Licensing',
                  route: '/licensing',
                  isSelected: currentPath.startsWith('/licensing'),
                  onTap: () => context.go('/licensing'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
                SidebarItem(
                  icon: Icons.extension_outlined,
                  label: 'Plugins',
                  route: '/plugins',
                  isSelected: currentPath.startsWith('/plugins'),
                  onTap: () => context.go('/plugins'),
                  isSubItem: true,
                  isCollapsed: isCollapsed,
                ),
              ],
      ),
    ];

    final bottomItems = [
      SidebarItem(
        icon: Icons.monitor_heart_outlined,
        label: 'System Health',
        route: '/system-health',
        isSelected: currentPath.startsWith('/system-health'),
        onTap: () => context.go('/system-health'),
        isCollapsed: isCollapsed,
      ),
      SidebarItem(
        icon: Icons.description_outlined,
        label: 'Audit Logs',
        route: '/audit-logs',
        isSelected: currentPath.startsWith('/audit-logs'),
        onTap: () => context.go('/audit-logs'),
        isCollapsed: isCollapsed,
      ),
      SidebarItem(
        icon: Icons.credit_card_outlined,
        label: 'Billing',
        route: '/billing',
        isSelected: currentPath.startsWith('/billing'),
        onTap: () => context.go('/billing'),
        isCollapsed: isCollapsed,
      ),
      SidebarItem(
        icon: Icons.settings_outlined,
        label: 'Settings',
        route: '/settings',
        isSelected: currentPath.startsWith('/settings'),
        onTap: () => context.go('/settings'),
        isCollapsed: isCollapsed,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        ...items,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Divider(color: AppColors.surfaceBorder),
        ),
        ...platformItems,
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Divider(color: AppColors.surfaceBorder),
        ),
        ...bottomItems,
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return ProfileMenu(isCollapsed: isCollapsed);
  }
}
