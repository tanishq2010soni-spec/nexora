import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/call.dart';
import '../../providers/calls_provider.dart';
import '../widgets/call_tile.dart';
import '../widgets/call_stats_card.dart';
import 'call_detail_screen.dart';

enum _DirectionFilter { all, inbound, outbound, missed }

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  _DirectionFilter _directionFilter = _DirectionFilter.all;
  String _searchQuery = '';
  String? _selectedCallId;

  List<VoiceCall> _filterCalls(List<VoiceCall> calls) {
    var filtered = calls;

    switch (_directionFilter) {
      case _DirectionFilter.inbound:
        filtered = filtered
            .where((c) => c.direction == CallDirection.inbound)
            .toList();
      case _DirectionFilter.outbound:
        filtered = filtered
            .where((c) => c.direction == CallDirection.outbound)
            .toList();
      case _DirectionFilter.missed:
        filtered = filtered
            .where((c) => c.status == CallStatus.missed)
            .toList();
      case _DirectionFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                c.callerNumber.toLowerCase().contains(query) ||
                c.calleeNumber.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final callListAsync = ref.watch(callListProvider);
    final analyticsAsync = ref.watch(callAnalyticsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xl),
          _buildAnalyticsSummary(analyticsAsync),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeftPanel(callListAsync),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: _buildRightPanel()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Calls',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSummary(AsyncValue analyticsAsync) {
    return analyticsAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox(height: 40),
      data: (analytics) => Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: [
          SizedBox(
            width: 200,
            child: CallStatsCard(
              title: 'Total Calls',
              value: '${analytics.totalCalls}',
              subtitle: '${analytics.completedCalls} completed',
              icon: Icons.phone_outlined,
              color: AppColors.info,
            ),
          ),
          SizedBox(
            width: 200,
            child: CallStatsCard(
              title: 'Answer Rate',
              value: '${analytics.answerRate.toStringAsFixed(1)}%',
              subtitle: '${analytics.missedCalls} missed',
              icon: Icons.call_merge,
              color: analytics.answerRate >= 80
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
          SizedBox(
            width: 200,
            child: CallStatsCard(
              title: 'Avg Duration',
              value: _formatDuration(analytics.avgDurationSeconds.toInt()),
              subtitle: '${analytics.totalDurationSeconds}s total',
              icon: Icons.timer_outlined,
              color: AppColors.accent,
            ),
          ),
          SizedBox(
            width: 200,
            child: CallStatsCard(
              title: 'Inbound',
              value: '${analytics.inboundCalls}',
              subtitle: '${analytics.outboundCalls} outbound',
              icon: Icons.call_received,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(AsyncValue<List<VoiceCall>> callListAsync) {
    final calls = callListAsync.when(
      loading: () => <VoiceCall>[],
      error: (_, _) => <VoiceCall>[],
      data: (data) => data,
    );

    final isLoading = callListAsync.isLoading;
    final filteredCalls = _filterCalls(calls);

    return Container(
      width: 350,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          _buildDirectionTabs(),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          Expanded(child: _buildCallItems(filteredCalls, isLoading)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search calls...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: AppColors.surfaceHover,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.surfaceBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.surfaceBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _buildTab('All', _DirectionFilter.all),
          const SizedBox(width: AppSpacing.xs),
          _buildTab('Inbound', _DirectionFilter.inbound),
          const SizedBox(width: AppSpacing.xs),
          _buildTab('Outbound', _DirectionFilter.outbound),
          const SizedBox(width: AppSpacing.xs),
          _buildTab('Missed', _DirectionFilter.missed),
        ],
      ),
    );
  }

  Widget _buildTab(String label, _DirectionFilter filter) {
    final isSelected = _directionFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _directionFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha(30)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCallItems(List<VoiceCall> calls, bool isLoading) {
    if (isLoading) {
      return _buildLoadingSkeleton();
    }

    if (calls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone_disabled_outlined,
              size: 40,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text('No calls found', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return CallTile(
          call: call,
          isSelected: call.id == _selectedCallId,
          onTap: () => setState(() => _selectedCallId = call.id),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 3,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceHover,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100 + (index * 20) % 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 160 + (index * 15) % 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRightPanel() {
    if (_selectedCallId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_outlined, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Select a call to view details',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return _buildCallDetailView();
  }

  Widget _buildCallDetailView() {
    final callAsync = ref.watch(callDetailProvider(_selectedCallId!));

    return callAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load call',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              e is Exception ? e.toString() : e.toString(),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton(
              onPressed: () =>
                  ref.invalidate(callDetailProvider(_selectedCallId!)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (call) => CallDetailScreen(callId: _selectedCallId!),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds.toString().padLeft(2, '0')}s';
  }
}
