import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/lead.dart';
import 'lead_status_badge.dart';

class LeadDataTable extends StatefulWidget {
  final List<Lead> leads;
  final Set<String> selectedIds;
  final ValueChanged<Lead> onLeadTap;
  final ValueChanged<Lead> onEdit;
  final ValueChanged<Lead> onDelete;
  final ValueChanged<Lead> onAssign;
  final ValueChanged<Lead> onView;
  final ValueChanged<Set<String>> onSelectionChanged;

  const LeadDataTable({
    super.key,
    required this.leads,
    required this.selectedIds,
    required this.onLeadTap,
    required this.onEdit,
    required this.onDelete,
    required this.onAssign,
    required this.onView,
    required this.onSelectionChanged,
  });

  @override
  State<LeadDataTable> createState() => _LeadDataTableState();
}

class _LeadDataTableState extends State<LeadDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    if (widget.leads.isEmpty) {
      return _buildEmptyState();
    }

    final sortedLeads = _getSortedLeads();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _buildTableHeader(sortedLeads),
            Expanded(
              child: ListView.builder(
                itemCount: sortedLeads.length,
                itemBuilder: (context, index) {
                  final lead = sortedLeads[index];
                  return _buildTableRow(lead, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(List<Lead> leads) {
    final allSelected =
        leads.isNotEmpty &&
        leads.every((l) => widget.selectedIds.contains(l.id));
    final someSelected = leads.any((l) => widget.selectedIds.contains(l.id));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: allSelected
                  ? true
                  : someSelected
                  ? null
                  : false,
              tristate: someSelected,
              onChanged: (value) {
                if (value == true) {
                  widget.onSelectionChanged(leads.map((l) => l.id).toSet());
                } else {
                  widget.onSelectionChanged({});
                }
              },
              activeColor: AppColors.accent,
              side: const BorderSide(color: AppColors.surfaceBorder),
            ),
          ),
          Expanded(flex: 3, child: _buildSortableHeader('Name', 0)),
          Expanded(flex: 2, child: _buildSortableHeader('Email', 1)),
          SizedBox(width: 120, child: _buildSortableHeader('Status', 2)),
          SizedBox(width: 110, child: _buildSortableHeader('Source', 3)),
          SizedBox(width: 120, child: _buildSortableHeader('AI Score', 4)),
          SizedBox(width: 120, child: _buildSortableHeader('Assigned', 5)),
          SizedBox(width: 130, child: _buildSortableHeader('Last Contact', 6)),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String label, int columnIndex) {
    final isActive = _sortColumnIndex == columnIndex;
    return GestureDetector(
      onTap: () => _onSort(columnIndex),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 4),
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: AppColors.accent,
            ),
          ],
        ],
      ),
    );
  }

  void _onSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  List<Lead> _getSortedLeads() {
    final leads = List<Lead>.from(widget.leads);
    leads.sort((a, b) {
      int comparison;
      switch (_sortColumnIndex) {
        case 0:
          comparison = a.name.compareTo(b.name);
        case 1:
          comparison = (a.email ?? '').compareTo(b.email ?? '');
        case 2:
          comparison = a.status.index.compareTo(b.status.index);
        case 3:
          comparison = a.source.index.compareTo(b.source.index);
        case 4:
          comparison = a.aiScore.compareTo(b.aiScore);
        case 5:
          comparison = (a.assignedToName ?? '').compareTo(
            b.assignedToName ?? '',
          );
        case 6:
          final aDate = a.lastContactedAt ?? a.createdAt;
          final bDate = b.lastContactedAt ?? b.createdAt;
          comparison = aDate.compareTo(bDate);
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });
    return leads;
  }

  Widget _buildTableRow(Lead lead, int index) {
    final isSelected = widget.selectedIds.contains(lead.id);

    return InkWell(
      onTap: () => widget.onLeadTap(lead),
      onSecondaryTapUp: (details) => _showContextMenu(details, lead),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentMuted
                : index.isEven
                ? AppColors.background
                : AppColors.surface,
            border: const Border(
              bottom: BorderSide(color: AppColors.surfaceBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    final newIds = Set<String>.from(widget.selectedIds);
                    if (value == true) {
                      newIds.add(lead.id);
                    } else {
                      newIds.remove(lead.id);
                    }
                    widget.onSelectionChanged(newIds);
                  },
                  activeColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  lead.name,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  lead.email ?? '—',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 120, child: LeadStatusBadge(status: lead.status)),
              SizedBox(width: 110, child: _buildSourceBadge(lead.source)),
              SizedBox(width: 120, child: _buildAiScoreBar(lead.aiScore)),
              SizedBox(
                width: 120,
                child: Text(
                  lead.assignedToName ?? 'Unassigned',
                  style: AppTypography.bodySmall.copyWith(
                    color: lead.assignedToName != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 130,
                child: Text(
                  _formatDate(lead.lastContactedAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  color: AppColors.surface,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  onSelected: (value) => _handleAction(value, lead),
                  itemBuilder: (context) => [
                    _popupMenuItem('view', 'View', Icons.visibility_outlined),
                    _popupMenuItem('edit', 'Edit', Icons.edit_outlined),
                    _popupMenuItem(
                      'assign',
                      'Assign',
                      Icons.person_add_outlined,
                    ),
                    _popupMenuDivider(),
                    _popupMenuItem(
                      'delete',
                      'Delete',
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _popupMenuItem(
    String value,
    String label,
    IconData icon, {
    Color? color,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuDivider _popupMenuDivider() {
    return const PopupMenuDivider(height: 1, color: AppColors.surfaceBorder);
  }

  void _handleAction(String action, Lead lead) {
    switch (action) {
      case 'view':
        widget.onView(lead);
      case 'edit':
        widget.onEdit(lead);
      case 'assign':
        widget.onAssign(lead);
      case 'delete':
        widget.onDelete(lead);
    }
  }

  void _showContextMenu(TapUpDetails details, Lead lead) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu<String>(
      context: context,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        overlay.size.width - details.globalPosition.dx,
        overlay.size.height - details.globalPosition.dy,
      ),
      items: [
        _popupMenuItem('view', 'View', Icons.visibility_outlined),
        _popupMenuItem('edit', 'Edit', Icons.edit_outlined),
        _popupMenuItem('assign', 'Assign', Icons.person_add_outlined),
        const PopupMenuDivider(height: 1, color: AppColors.surfaceBorder),
        _popupMenuItem(
          'delete',
          'Delete',
          Icons.delete_outline,
          color: AppColors.error,
        ),
      ],
    ).then((value) {
      if (value != null) _handleAction(value, lead);
    });
  }

  Widget _buildSourceBadge(LeadSource source) {
    final config = _sourceConfig(source);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.$2.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: config.$2.withAlpha(80)),
      ),
      child: Text(
        config.$1,
        style: AppTypography.labelSmall.copyWith(color: config.$2),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  (String, Color) _sourceConfig(LeadSource source) {
    return switch (source) {
      LeadSource.whatsapp => ('WhatsApp', const Color(0xFF25D366)),
      LeadSource.callingAgent => ('Calling', AppColors.info),
      LeadSource.website => ('Website', AppColors.accent),
      LeadSource.manual => ('Manual', AppColors.textTertiary),
      LeadSource.import => ('Import', AppColors.warning),
    };
  }

  Widget _buildAiScoreBar(int score) {
    final color = _scoreColor(score);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (score / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$score',
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return const Color(0xFF84CC16);
    if (score >= 40) return AppColors.warning;
    if (score >= 20) return const Color(0xFFF97316);
    return AppColors.error;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.people_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No leads available',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Leads will appear here once created.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
