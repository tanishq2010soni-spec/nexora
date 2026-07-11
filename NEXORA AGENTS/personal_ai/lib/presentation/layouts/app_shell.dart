import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/character_provider.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    context.watch<CharacterProvider>();

    return Container(
      width: 220,
      color: AppColors.surface,
      child: Column(
        children: [
          const _SidebarHeader(),
          const SizedBox(height: AppSpacing.lg),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            path: '/',
            isActive: location == '/',
            onTap: () => context.go('/'),
          ),
          _SidebarItem(
            icon: Icons.chat_outlined,
            label: 'Chat',
            path: '/chat',
            isActive: location.startsWith('/chat'),
            onTap: () => context.go('/chat'),
          ),
          _SidebarItem(
            icon: Icons.memory_outlined,
            label: 'Memory',
            path: '/memory',
            isActive: location == '/memory',
            onTap: () => context.go('/memory'),
          ),
          _SidebarItem(
            icon: Icons.task_alt_outlined,
            label: 'Tasks',
            path: '/tasks',
            isActive: location == '/tasks',
            onTap: () => context.go('/tasks'),
          ),
          _SidebarItem(
            icon: Icons.face_outlined,
            label: 'Character',
            path: '/character',
            isActive: location == '/character',
            onTap: () => context.go('/character'),
          ),
          _SidebarItem(
            icon: Icons.security_outlined,
            label: 'Permissions',
            path: '/permissions',
            isActive: location == '/permissions',
            onTap: () => context.go('/permissions'),
          ),
          _SidebarItem(
            icon: Icons.extension_outlined,
            label: 'Plugins',
            path: '/plugins',
            isActive: location == '/plugins',
            onTap: () => context.go('/plugins'),
          ),
          const Spacer(),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            path: '/settings',
            isActive: location == '/settings',
            onTap: () => context.go('/settings'),
          ),
          const SizedBox(height: AppSpacing.md),
          Consumer<CharacterProvider>(
            builder: (context, character, _) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: switch (character.expression) {
                          'talking' => AppColors.accent,
                          'thinking' => AppColors.warning,
                          'listening' => AppColors.primary,
                          _ => AppColors.textTertiary,
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      character.expression,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('Personal AI', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Material(
        color: isActive ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
