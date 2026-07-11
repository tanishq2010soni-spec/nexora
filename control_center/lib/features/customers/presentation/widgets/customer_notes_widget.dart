import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/models/customer_activity.dart';
import '../../providers/customer_provider.dart';

class CustomerNotesWidget extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerNotesWidget({super.key, required this.customerId});

  @override
  ConsumerState<CustomerNotesWidget> createState() =>
      _CustomerNotesWidgetState();
}

class _CustomerNotesWidgetState extends ConsumerState<CustomerNotesWidget> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAddNoteSection(),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: _buildNotesList()),
      ],
    );
  }

  Widget _buildAddNoteSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Note',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _noteController,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write a note about this customer...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.surface,
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
                borderSide: const BorderSide(color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Add Note',
              isCompact: true,
              icon: Icons.add,
              onPressed: _addNote,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    final activitiesAsync = ref.watch(
      customerActivitiesProvider(widget.customerId),
    );

    return activitiesAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => Center(
        child: Text(
          'Failed to load notes',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (activities) {
        final notes = activities
            .where((a) => a.type == CustomerActivityType.noteAdded)
            .toList();

        if (notes.isEmpty) {
          return Center(
            child: Text(
              'No notes yet. Add your first note above.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (note.performedByName != null) ...[
                        Text(
                          'By: ${note.performedByName}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Text(
                        _formatDate(note.createdAt),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addNote() async {
    final content = _noteController.text.trim();
    if (content.isEmpty) return;

    try {
      await ref.read(
        addCustomerNoteProvider((
          customerId: widget.customerId,
          content: content,
        )).future,
      );
      _noteController.clear();
      ref.invalidate(customerActivitiesProvider(widget.customerId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add note: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
