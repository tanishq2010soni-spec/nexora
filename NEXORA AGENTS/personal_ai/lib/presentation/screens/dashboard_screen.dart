import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/app_loader.dart';
import '../../providers/health_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/task_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().startPolling(5);
      context.read<ConversationProvider>().loadConversations();
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();
    final convProvider = context.watch<ConversationProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(child: _StatCard(
                    icon: Icons.favorite_outline,
                    label: 'Status',
                    value: healthProvider.health?.status ?? 'Unknown',
                    color: healthProvider.connected ? AppColors.success : AppColors.error,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _StatCard(
                    icon: Icons.timer_outlined,
                    label: 'Uptime',
                    value: healthProvider.health != null
                        ? '${healthProvider.health!.uptime.toStringAsFixed(1)}h'
                        : '--',
                    color: AppColors.primary,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _StatCard(
                    icon: Icons.chat_outlined,
                    label: 'Conversations',
                    value: '${convProvider.conversations.length}',
                    color: AppColors.secondary,
                  )),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _StatCard(
                    icon: Icons.task_alt_outlined,
                    label: 'Active Tasks',
                    value: '${taskProvider.tasks.where((t) => t.status == 'running').length}',
                    color: AppColors.accent,
                  )),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Quick Actions', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _QuickActionCard(
                    icon: Icons.chat_outlined,
                    label: 'New Chat',
                    onTap: () => context.go('/chat'),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _QuickActionCard(
                    icon: Icons.memory_outlined,
                    label: 'Search Memory',
                    onTap: () => context.go('/memory'),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _QuickActionCard(
                    icon: Icons.task_alt_outlined,
                    label: 'View Tasks',
                    onTap: () => context.go('/tasks'),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _QuickActionCard(
                    icon: Icons.face_outlined,
                    label: 'Character',
                    onTap: () => context.go('/character'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Recent Activity', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.lg),
              if (convProvider.loading)
                const AppLoader()
              else if (convProvider.conversations.isEmpty)
                _EmptyActivity()
              else
                ...convProvider.conversations.take(5).map(
                  (c) => _ActivityItem(
                    title: c.title,
                    subtitle: '${c.messages.length} messages',
                    time: c.updatedAt,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(value, style: AppTypography.h2.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                Icon(icon, size: 28, color: AppColors.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(label, style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime time;

  const _ActivityItem({required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            _formatTime(time),
            style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _EmptyActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Center(
        child: Text(
          'No recent activity. Start a conversation!',
          style: AppTypography.body.copyWith(color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
