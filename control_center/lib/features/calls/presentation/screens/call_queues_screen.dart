import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/call_queue.dart';
import '../../providers/calls_provider.dart';

class CallQueuesScreen extends ConsumerStatefulWidget {
  const CallQueuesScreen({super.key});

  @override
  ConsumerState<CallQueuesScreen> createState() => _CallQueuesScreenState();
}

class _CallQueuesScreenState extends ConsumerState<CallQueuesScreen> {
  @override
  Widget build(BuildContext context) {
    final queuesAsync = ref.watch(callQueueListProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.xl),
          Expanded(child: _buildQueueList(queuesAsync)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Call Queues',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        TextButton.icon(
          onPressed: () => _showCreateQueueDialog(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create Queue'),
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
        ),
      ],
    );
  }

  Widget _buildQueueList(AsyncValue<List<CallQueue>> queuesAsync) {
    return queuesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load queues',
              style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton(
              onPressed: () => ref.invalidate(callQueueListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (queues) {
        if (queues.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.queue_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No call queues',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Create a queue to manage incoming calls',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: queues.length,
          itemBuilder: (context, index) => _buildQueueTile(queues[index]),
        );
      },
    );
  }

  Widget _buildQueueTile(CallQueue queue) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  (queue.isActive ? AppColors.success : AppColors.textTertiary)
                      .withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.queue_outlined,
              size: 22,
              color: queue.isActive
                  ? AppColors.success
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      queue.name,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _buildActiveBadge(queue.isActive),
                  ],
                ),
                if (queue.description != null &&
                    queue.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    queue.description!,
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
              _buildRoutingBadge(queue.routingStrategy),
              const SizedBox(height: 4),
              Text(
                'Max wait: ${queue.maxWaitTime}s',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          IconButton(
            onPressed: () => _deleteQueue(queue.id),
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBadge(bool isActive) {
    final color = isActive ? AppColors.success : AppColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutingBadge(RoutingStrategy strategy) {
    final label = switch (strategy) {
      RoutingStrategy.roundRobin => 'Round Robin',
      RoutingStrategy.leastRecent => 'Least Recent',
      RoutingStrategy.random => 'Random',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentMuted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: AppColors.accent),
      ),
    );
  }

  void _showCreateQueueDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    RoutingStrategy selectedStrategy = RoutingStrategy.roundRobin;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: Text(
            'Create Queue',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Queue name',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceHover,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: descriptionController,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Description (optional)',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceHover,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<RoutingStrategy>(
                  initialValue: selectedStrategy,
                  dropdownColor: AppColors.surface,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Routing strategy',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceHover,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.surfaceBorder,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: RoutingStrategy.roundRobin,
                      child: Text('Round Robin'),
                    ),
                    DropdownMenuItem(
                      value: RoutingStrategy.leastRecent,
                      child: Text('Least Recent'),
                    ),
                    DropdownMenuItem(
                      value: RoutingStrategy.random,
                      child: Text('Random'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedStrategy = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  _createQueue(
                    name: nameController.text,
                    description: descriptionController.text.isNotEmpty
                        ? descriptionController.text
                        : null,
                    routingStrategy: selectedStrategy.name,
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _createQueue({
    required String name,
    String? description,
    String? routingStrategy,
  }) async {
    final result = await ref
        .read(callsRepositoryProvider)
        .createQueue(
          name: name,
          description: description,
          routingStrategy: routingStrategy,
        );
    if (result is ApiSuccess) {
      ref.invalidate(callQueueListProvider);
    }
  }

  void _deleteQueue(String id) async {
    final result = await ref.read(callsRepositoryProvider).deleteQueue(id);
    if (result is ApiSuccess) {
      ref.invalidate(callQueueListProvider);
    }
  }
}
