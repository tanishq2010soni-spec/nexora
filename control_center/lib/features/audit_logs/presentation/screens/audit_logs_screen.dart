import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../providers/audit_logs_provider.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(auditLogsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xl),
          _buildCategoryFilter(),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: logsAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => ErrorView(
                exception: e as dynamic,
                onRetry: () => ref.invalidate(auditLogsProvider),
              ),
              data: (logs) {
                final filtered = _filterLogs(logs);
                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history_outlined,
                    title: 'No Audit Logs',
                    subtitle: 'System activity will be recorded here.',
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _buildLogTile(filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterLogs(List<Map<String, dynamic>> logs) {
    if (_selectedCategory == 'all') return logs;
    return logs.where((log) {
      final action = (log['action'] as String? ?? '').toLowerCase();
      final resource = (log['resource'] as String? ?? '').toLowerCase();
      if (_selectedCategory == 'user') {
        return action.contains('login') ||
            action.contains('logout') ||
            resource.contains('user');
      }
      if (_selectedCategory == 'system') {
        return action.contains('create') ||
            action.contains('update') ||
            action.contains('delete');
      }
      if (_selectedCategory == 'security') {
        return action.contains('login') ||
            resource.contains('auth') ||
            resource.contains('api_key');
      }
      return true;
    }).toList();
  }

  Widget _buildHeader() {
    return Text(
      'Audit Logs',
      style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['all', 'user', 'system', 'security', 'settings'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          final label = cat[0].toUpperCase() + cat.substring(1);
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              selectedColor: AppColors.accentMuted,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.surfaceBorder,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogTile(Map<String, dynamic> log) {
    final action = log['action'] as String? ?? 'Unknown';
    final resource = log['resource'] as String? ?? '';
    final detail = log['detail'] as String? ?? '';
    final userEmail = log['user_email'] as String? ?? '';
    final createdAt = log['created_at'] as String? ?? '';

    final icon = switch (action.toUpperCase()) {
      'CREATE' || 'LOGIN' => Icons.add_circle_outline,
      'UPDATE' => Icons.edit_outlined,
      'DELETE' => Icons.delete_outline,
      'LOGOUT' => Icons.logout,
      _ => Icons.circle_outlined,
    };

    final color = switch (action.toUpperCase()) {
      'CREATE' || 'LOGIN' => AppColors.success,
      'UPDATE' => AppColors.info,
      'DELETE' => AppColors.error,
      'LOGOUT' => AppColors.warning,
      _ => AppColors.textTertiary,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$action ${resource.isNotEmpty ? resource : ''}',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (userEmail.isNotEmpty)
                Text(
                  userEmail,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                _formatTimestamp(createdAt),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return timestamp;
    }
  }
}
