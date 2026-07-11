import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/models/lead.dart';
import '../../domain/models/lead_activity.dart';
import '../../providers/lead_provider.dart';
import 'lead_activity_timeline.dart';
import 'lead_status_badge.dart';

class LeadDetailPanel extends ConsumerStatefulWidget {
  final Lead lead;
  final VoidCallback? onClose;
  final ValueChanged<Lead>? onEdit;

  const LeadDetailPanel({
    super.key,
    required this.lead,
    this.onClose,
    this.onEdit,
  });

  @override
  ConsumerState<LeadDetailPanel> createState() => _LeadDetailPanelState();
}

class _LeadDetailPanelState extends ConsumerState<LeadDetailPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _noteController;
  bool _isAddingNote = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Column(
        children: [
          _buildPanelHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildActivityTab(),
                _buildNotesTab(),
                _buildConversationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lead.name,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.lead.email ?? widget.lead.phone ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onEdit != null)
            AppButton(
              label: 'Edit',
              variant: AppButtonVariant.secondary,
              isCompact: true,
              icon: Icons.edit_outlined,
              onPressed: () => widget.onEdit!(widget.lead),
            ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: AppColors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.surfaceBorder,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Activity'),
          Tab(text: 'Notes'),
          Tab(text: 'Conversations'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final lead = widget.lead;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Contact Information'),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(Icons.person_outline, 'Name', lead.name),
          _buildInfoRow(Icons.email_outlined, 'Email', lead.email ?? '—'),
          _buildInfoRow(Icons.phone_outlined, 'Phone', lead.phone ?? '—'),
          _buildInfoRow(
            Icons.business_outlined,
            'Company',
            lead.company ?? '—',
          ),
          _buildInfoRow(Icons.work_outline, 'Job Title', lead.jobTitle ?? '—'),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Lead Details'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildInfoRow(Icons.flag_outlined, 'Status', ''),
              const SizedBox(width: 8),
              LeadStatusBadge(status: lead.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            Icons.source_outlined,
            'Source',
            _sourceLabel(lead.source),
          ),
          _buildInfoRow(
            Icons.person_add_outlined,
            'Assigned To',
            lead.assignedToName ?? 'Unassigned',
          ),
          if (lead.conversationId != null)
            _buildInfoRow(
              Icons.chat_outlined,
              'Conversation',
              lead.conversationId!,
            ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('AI Scores'),
          const SizedBox(height: AppSpacing.md),
          _buildScoreRow('Overall AI Score', lead.aiScore),
          _buildScoreRow('Intent Score', lead.intentScore),
          _buildScoreRow('Budget Score', lead.budgetScore),
          _buildScoreRow('Engagement Score', lead.engagementScore),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionTitle('Timestamps'),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            Icons.access_time,
            'Created',
            _formatDateTime(lead.createdAt),
          ),
          _buildInfoRow(
            Icons.update,
            'Updated',
            _formatDateTime(lead.updatedAt),
          ),
          if (lead.lastContactedAt != null)
            _buildInfoRow(
              Icons.phone_in_talk_outlined,
              'Last Contacted',
              _formatDateTime(lead.lastContactedAt!),
            ),
          if (lead.qualifiedAt != null)
            _buildInfoRow(
              Icons.check_circle_outline,
              'Qualified At',
              _formatDateTime(lead.qualifiedAt!),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    final activitiesAsync = ref.watch(leadActivitiesProvider(widget.lead.id));

    return activitiesAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(leadActivitiesProvider(widget.lead.id)),
      ),
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timeline_outlined,
                  size: 40,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Activity Yet',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Activity events will appear here.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return LeadActivityTimeline(activities: activities);
      },
    );
  }

  Widget _buildNotesTab() {
    final notesAsync = ref.watch(leadActivitiesProvider(widget.lead.id));

    return Column(
      children: [
        _buildAddNoteSection(),
        const Divider(height: 1, color: AppColors.surfaceBorder),
        Expanded(
          child: notesAsync.when(
            loading: () => const AppLoader(),
            error: (e, _) => ErrorView(
              exception: e is AppException ? e : UnknownException(e.toString()),
              onRetry: () =>
                  ref.invalidate(leadActivitiesProvider(widget.lead.id)),
            ),
            data: (activities) {
              final notes = activities
                  .where((a) => a.type == ActivityType.noteAdded)
                  .toList();

              if (notes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.note_add_outlined,
                        size: 40,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Notes',
                        style: AppTypography.h4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a note to get started.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: notes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return _buildNoteCard(note);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddNoteSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            hint: 'Add a note...',
            controller: _noteController,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Add Note',
              isCompact: true,
              isLoading: _isAddingNote,
              onPressed: _addNote,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNote() async {
    final content = _noteController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isAddingNote = true);
    try {
      await ref.read(
        addLeadNoteProvider((leadId: widget.lead.id, content: content)).future,
      );
      _noteController.clear();
      ref.invalidate(leadActivitiesProvider(widget.lead.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add note: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingNote = false);
    }
  }

  Widget _buildNoteCard(LeadActivity note) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                note.performedBy ?? 'Unknown',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                _formatDateTime(note.createdAt),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            note.description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsTab() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Conversations',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            widget.lead.conversationId != null
                ? 'View conversation history for this lead.'
                : 'No conversations linked to this lead.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (widget.lead.conversationId != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'View Conversation',
              icon: Icons.open_in_new,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                // Navigate to conversation detail
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, int score) {
    final color = _scoreColor(score);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (score / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$score',
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return const Color(0xFF84CC16);
    if (score >= 40) return AppColors.warning;
    if (score >= 20) return const Color(0xFFF97316);
    return AppColors.error;
  }

  String _sourceLabel(LeadSource source) {
    return switch (source) {
      LeadSource.whatsapp => 'WhatsApp',
      LeadSource.callingAgent => 'Calling Agent',
      LeadSource.website => 'Website',
      LeadSource.manual => 'Manual',
      LeadSource.import => 'Import',
    };
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
