import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/memory_entry.dart';
import '../../providers/memory_provider.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<MemoryProvider>().search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MemoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Memory')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search memories...',
                      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: AppColors.primary,
                  onPressed: _search,
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.loading
                ? const AppLoader()
                : provider.memories.isEmpty
                    ? const EmptyState(
                        icon: Icons.memory_outlined,
                        title: 'No memories found',
                        subtitle: 'Search for memories or interact with the AI to create them',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
                        itemCount: provider.memories.length,
                        itemBuilder: (context, index) {
                          final memory = provider.memories[index];
                          return _MemoryCard(memory: memory);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryEntry memory;

  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    memory.type,
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                  ),
                ),
                const Spacer(),
                if (memory.score > 0)
                  Text(
                    memory.score.toStringAsFixed(2),
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              memory.content,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (memory.tags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 4,
                children: memory.tags.map((tag) => Chip(
                  label: Text(tag, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                )).toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              memory.source,
              style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
