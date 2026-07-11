import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sidebar/app_sidebar.dart';
import '../../core/widgets/topbar/app_topbar.dart';
import '../../core/widgets/search/command_palette.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;

  String _getTitle(String path) {
    if (path.startsWith('/dashboard')) return 'Dashboard';
    if (path.startsWith('/agents')) return 'Agents';
    if (path.startsWith('/knowledge-base')) return 'Knowledge Base';
    if (path.startsWith('/leads')) return 'Leads';
    if (path.startsWith('/customers')) return 'Customers';
    if (path.startsWith('/conversations')) return 'Conversations';
    if (path.startsWith('/analytics')) return 'Analytics';
    if (path.startsWith('/system-health')) return 'System Health';
    if (path.startsWith('/audit-logs')) return 'Audit Logs';
    if (path.startsWith('/billing')) return 'Billing';
    if (path.startsWith('/settings')) return 'Settings';
    if (path.startsWith('/inbox')) return 'Inbox';
    if (path.startsWith('/tasks')) return 'Tasks';
    if (path.startsWith('/workflows')) return 'Workflows';
    if (path.startsWith('/calls')) return 'Calls';
    if (path.startsWith('/memory')) return 'Memory';
    if (path.startsWith('/team')) return 'Team';
    if (path.startsWith('/copilot')) return 'AI Copilot';
    return 'Nexora';
  }

  int _getBottomNavIndex(String path) {
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/leads') || path.startsWith('/customers')) return 1;
    if (path.startsWith('/inbox') || path.startsWith('/conversations')) {
      return 2;
    }
    if (path.startsWith('/analytics')) return 3;
    if (path.startsWith('/settings') || path.startsWith('/billing')) return 4;
    return 0;
  }

  void _onBottomNavTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/leads');
      case 2:
        context.go('/inbox');
      case 3:
        context.go('/analytics');
      case 4:
        context.go('/settings');
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyK &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed)) {
      CommandPalette.show(context, []);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < _mobileBreakpoint;
    final isTablet =
        screenWidth >= _mobileBreakpoint && screenWidth < _tabletBreakpoint;

    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: isMobile
          ? _buildMobileLayout(currentPath)
          : _buildDesktopLayout(currentPath, isTablet),
    );
  }

  Widget _buildMobileLayout(String currentPath) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_getTitle(currentPath)),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () => CommandPalette.show(context, []),
            tooltip: 'Search',
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.sidebarBackground,
        child: AppSidebar(
          isCollapsed: false,
          onToggle: () => Navigator.of(context).pop(),
        ),
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textTertiary,
        currentIndex: _getBottomNavIndex(currentPath),
        onTap: (i) => _onBottomNavTap(i, context),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_outlined, size: 20),
            label: 'Leads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined, size: 20),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined, size: 20),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: 20),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(String currentPath, bool isTablet) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            isCollapsed: _sidebarCollapsed || isTablet,
            onToggle: () =>
                setState(() => _sidebarCollapsed = !_sidebarCollapsed),
          ),
          Expanded(
            child: Column(
              children: [
                AppTopBar(title: _getTitle(currentPath)),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
