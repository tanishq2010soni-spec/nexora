import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/agent_capability.dart';
import '../../domain/models/agent_configuration.dart';
import '../../domain/models/agent_health.dart';
import '../../domain/models/agent_log.dart';
import '../../domain/models/agent_version.dart';
import '../../providers/agent_management_provider.dart';

class AgentManagementScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentManagementScreen({super.key, required this.agentId});

  @override
  ConsumerState<AgentManagementScreen> createState() =>
      _AgentManagementScreenState();
}

class _AgentManagementScreenState
    extends ConsumerState<AgentManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agent Management',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () {
                  ref.invalidate(agentVersionsProvider(widget.agentId));
                  ref.invalidate(agentCapabilitiesProvider(widget.agentId));
                  ref.invalidate(agentHealthProvider(widget.agentId));
                  ref.invalidate(agentLogsProvider(widget.agentId));
                  ref.invalidate(agentConfigurationsProvider(widget.agentId));
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.accent,
            tabs: const [
              Tab(text: 'Versions'),
              Tab(text: 'Capabilities'),
              Tab(text: 'Health'),
              Tab(text: 'Logs'),
              Tab(text: 'Config'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _VersionsTab(agentId: widget.agentId),
                _CapabilitiesTab(agentId: widget.agentId),
                _HealthTab(agentId: widget.agentId),
                _LogsTab(agentId: widget.agentId),
                _ConfigTab(agentId: widget.agentId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionsTab extends ConsumerWidget {
  final String agentId;

  const _VersionsTab({required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionsAsync = ref.watch(agentVersionsProvider(agentId));

    return versionsAsync.when(
      loading: () => const ListShimmer(),
      error: (e, _) => ErrorView(
        exception: e,
        onRetry: () => ref.invalidate(agentVersionsProvider(agentId)),
      ),
      data: (apiResult) => switch (apiResult) {
        ApiSuccess<List<AgentVersion>>(:final data) => data.isEmpty
            ? const EmptyState(
                icon: Icons.layers_outlined,
                title: 'No Versions',
                subtitle: 'No agent versions recorded yet.',
              )
            : ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final version = data[index];
                  return SlideFadeIn(
                    offset: const Offset(0, 12),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.accentMuted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tag, size: 18,
                                color: AppColors.accent),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'v${version.version}',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (version.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    version.description!,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            _formatDate(version.createdAt),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ApiError<List<AgentVersion>>(:final exception) => ErrorView(
          exception: exception,
          onRetry: () => ref.invalidate(agentVersionsProvider(agentId)),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.month}/${dt.day}/${dt.year}';
}

class _CapabilitiesTab extends ConsumerWidget {
  final String agentId;

  const _CapabilitiesTab({required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilitiesAsync = ref.watch(agentCapabilitiesProvider(agentId));

    return capabilitiesAsync.when(
      loading: () => const ListShimmer(),
      error: (e, _) => ErrorView(
        exception: e,
        onRetry: () => ref.invalidate(agentCapabilitiesProvider(agentId)),
      ),
      data: (apiResult) => switch (apiResult) {
        ApiSuccess<List<AgentCapability>>(:final data) => data.isEmpty
            ? const EmptyState(
                icon: Icons.widgets_outlined,
                title: 'No Capabilities',
                subtitle: 'No capabilities defined for this agent.',
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 2.0,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final cap = data[index];
                  return SlideFadeIn(
                    offset: const Offset(0, 12),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                cap.enabled
                                    ? Icons.check_circle
                                    : Icons.cancel_outlined,
                                size: 14,
                                color: cap.enabled
                                    ? AppColors.success
                                    : AppColors.textTertiary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  cap.capabilityName,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (cap.configJson != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              cap.configJson!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
        ApiError<List<AgentCapability>>(:final exception) => ErrorView(
          exception: exception,
          onRetry: () => ref.invalidate(agentCapabilitiesProvider(agentId)),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _HealthTab extends ConsumerWidget {
  final String agentId;

  const _HealthTab({required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(agentHealthProvider(agentId));

    return healthAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e,
        onRetry: () => ref.invalidate(agentHealthProvider(agentId)),
      ),
      data: (apiResult) => switch (apiResult) {
        ApiSuccess<AgentHealth>(:final data) => SingleChildScrollView(
            child: _HealthCard(health: data),
          ),
        ApiError<AgentHealth>(:final exception) => ErrorView(
          exception: exception,
          onRetry: () => ref.invalidate(agentHealthProvider(agentId)),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _HealthCard extends StatelessWidget {
  final AgentHealth health;

  const _HealthCard({required this.health});

  Color _statusColor() {
    return switch (health.status) {
      AgentHealthStatus.healthy => AppColors.success,
      AgentHealthStatus.degraded => AppColors.warning,
      AgentHealthStatus.down => AppColors.error,
      AgentHealthStatus.unknown => AppColors.textTertiary,
    };
  }

  String _statusLabel() {
    return switch (health.status) {
      AgentHealthStatus.healthy => 'Healthy',
      AgentHealthStatus.degraded => 'Degraded',
      AgentHealthStatus.down => 'Down',
      AgentHealthStatus.unknown => 'Unknown',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _statusColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _statusLabel(),
                style: AppTypography.h3.copyWith(color: _statusColor()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (health.latencyMs != null) ...[
            _HealthRow(
              label: 'Latency',
              value: '${health.latencyMs}ms',
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (health.lastHeartbeatAt != null) ...[
            _HealthRow(
              label: 'Last Heartbeat',
              value: _formatDateTime(health.lastHeartbeatAt!),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (health.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      health.errorMessage!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _HealthRow extends StatelessWidget {
  final String label;
  final String value;

  const _HealthRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LogsTab extends ConsumerWidget {
  final String agentId;

  const _LogsTab({required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(agentLogsProvider(agentId));

    return logsAsync.when(
      loading: () => const ListShimmer(),
      error: (e, _) => ErrorView(
        exception: e,
        onRetry: () => ref.invalidate(agentLogsProvider(agentId)),
      ),
      data: (apiResult) => switch (apiResult) {
        ApiSuccess<List<AgentLog>>(:final data) => data.isEmpty
            ? const EmptyState(
                icon: Icons.article_outlined,
                title: 'No Logs',
                subtitle: 'No logs recorded for this agent.',
              )
            : ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final log = data[index];
                  return _LogRow(log: log);
                },
              ),
        ApiError<List<AgentLog>>(:final exception) => ErrorView(
          exception: exception,
          onRetry: () => ref.invalidate(agentLogsProvider(agentId)),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _LogRow extends StatelessWidget {
  final AgentLog log;

  const _LogRow({required this.log});

  Color _levelColor() {
    return switch (log.level) {
      LogLevel.debug => AppColors.textTertiary,
      LogLevel.info => AppColors.info,
      LogLevel.warn => AppColors.warning,
      LogLevel.error => AppColors.error,
      LogLevel.fatal => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SlideFadeIn(
      offset: const Offset(0, 8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _levelColor().withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.level.name.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: _levelColor(),
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                log.message,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _formatTime(log.createdAt),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _ConfigTab extends ConsumerWidget {
  final String agentId;

  const _ConfigTab({required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(agentConfigurationsProvider(agentId));

    return configAsync.when(
      loading: () => const ListShimmer(),
      error: (e, _) => ErrorView(
        exception: e,
        onRetry: () => ref.invalidate(agentConfigurationsProvider(agentId)),
      ),
      data: (apiResult) => switch (apiResult) {
        ApiSuccess<List<AgentConfiguration>>(:final data) => data.isEmpty
            ? const EmptyState(
                icon: Icons.settings_outlined,
                title: 'No Configurations',
                subtitle: 'No configurations defined for this agent.',
              )
            : ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final config = data[index];
                  return SlideFadeIn(
                    offset: const Offset(0, 12),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.vpn_key_outlined,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.configKey,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  config.configValue,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceBorderLight.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              config.configType,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ApiError<List<AgentConfiguration>>(:final exception) => ErrorView(
          exception: exception,
          onRetry: () => ref.invalidate(agentConfigurationsProvider(agentId)),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
