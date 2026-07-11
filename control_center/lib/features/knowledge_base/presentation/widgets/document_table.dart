import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/models/document.dart';

class DocumentTable extends StatefulWidget {
  final List<KbDocument> documents;
  final Set<String> selectedIds;
  final ValueChanged<String> onDocumentTap;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onReindex;
  final ValueChanged<Set<String>> onSelectionChanged;
  final String emptyMessage;

  const DocumentTable({
    super.key,
    required this.documents,
    required this.selectedIds,
    required this.onDocumentTap,
    required this.onDelete,
    required this.onReindex,
    required this.onSelectionChanged,
    this.emptyMessage = 'No documents found',
  });

  @override
  State<DocumentTable> createState() => _DocumentTableState();
}

class _DocumentTableState extends State<DocumentTable> {
  int _sortColumnIndex = 5;
  bool _sortAscending = false;

  List<KbDocument> get _sortedDocs {
    final list = List<KbDocument>.from(widget.documents);
    switch (_sortColumnIndex) {
      case 1:
        list.sort(
          (a, b) => _sortAscending
              ? a.filename.compareTo(b.filename)
              : b.filename.compareTo(a.filename),
        );
      case 2:
        list.sort(
          (a, b) => _sortAscending
              ? a.fileType.index.compareTo(b.fileType.index)
              : b.fileType.index.compareTo(a.fileType.index),
        );
      case 3:
        list.sort(
          (a, b) => _sortAscending
              ? a.status.index.compareTo(b.status.index)
              : b.status.index.compareTo(a.status.index),
        );
      case 4:
        list.sort(
          (a, b) => _sortAscending
              ? a.chunkCount.compareTo(b.chunkCount)
              : b.chunkCount.compareTo(a.chunkCount),
        );
      case 5:
        list.sort(
          (a, b) => _sortAscending
              ? a.embeddingCount.compareTo(b.embeddingCount)
              : b.embeddingCount.compareTo(a.embeddingCount),
        );
      case 6:
        list.sort(
          (a, b) => _sortAscending
              ? a.fileSizeBytes.compareTo(b.fileSizeBytes)
              : b.fileSizeBytes.compareTo(a.fileSizeBytes),
        );
      case 7:
        list.sort((a, b) {
          final aDate = a.indexedAt ?? a.createdAt;
          final bDate = b.indexedAt ?? b.createdAt;
          return _sortAscending
              ? aDate.compareTo(bDate)
              : bDate.compareTo(aDate);
        });
    }
    return list;
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

  void _toggleAll() {
    if (widget.selectedIds.length == widget.documents.length) {
      widget.onSelectionChanged({});
    } else {
      widget.onSelectionChanged(widget.documents.map((d) => d.id).toSet());
    }
  }

  void _toggleRow(String id) {
    final newSelection = Set<String>.from(widget.selectedIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    widget.onSelectionChanged(newSelection);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _fileTypeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.docx:
        return 'DOCX';
      case DocumentType.txt:
        return 'TXT';
      case DocumentType.unknown:
        return 'Unknown';
    }
  }

  Color _fileTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return AppColors.error;
      case DocumentType.docx:
        return AppColors.info;
      case DocumentType.txt:
        return AppColors.success;
      case DocumentType.unknown:
        return AppColors.textTertiary;
    }
  }

  Color _statusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.processing:
        return AppColors.warning;
      case DocumentStatus.indexed:
        return AppColors.success;
      case DocumentStatus.error:
        return AppColors.error;
      case DocumentStatus.deleted:
        return AppColors.textTertiary;
    }
  }

  String _statusLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.processing:
        return 'Processing';
      case DocumentStatus.indexed:
        return 'Indexed';
      case DocumentStatus.error:
        return 'Error';
      case DocumentStatus.deleted:
        return 'Deleted';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.documents.isEmpty) {
      return EmptyState(
        icon: Icons.description_outlined,
        title: widget.emptyMessage,
        subtitle: 'Upload documents to this knowledge base to get started.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                ..._sortedDocs.asMap().entries.map((entry) {
                  final doc = entry.value;
                  return _buildRow(doc);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final allSelected =
        widget.selectedIds.length == widget.documents.length &&
        widget.documents.isNotEmpty;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: allSelected,
              onChanged: (_) => _toggleAll(),
              activeColor: AppColors.accent,
              side: const BorderSide(color: AppColors.surfaceBorder),
            ),
          ),
          _buildHeaderCell('Filename', 1, flex: 3),
          _buildHeaderCell('Type', 2, flex: 1),
          _buildHeaderCell('Status', 3, flex: 1),
          _buildHeaderCell('Chunks', 4, flex: 1),
          _buildHeaderCell('Embeddings', 5, flex: 1),
          _buildHeaderCell('Size', 6, flex: 1),
          _buildHeaderCell('Indexed At', 7, flex: 2),
          const SizedBox(width: 100),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, int columnIndex, {int flex = 1}) {
    final isSorted = _sortColumnIndex == columnIndex;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => _onSort(columnIndex),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSorted ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
            if (isSorted)
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(KbDocument doc) {
    final isSelected = widget.selectedIds.contains(doc.id);

    return Material(
      color: isSelected ? AppColors.accentMuted : Colors.transparent,
      child: InkWell(
        onTap: () => widget.onDocumentTap(doc.id),
        onHover: (hovering) {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.surfaceBorder, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleRow(doc.id),
                  activeColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  doc.filename,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: _TypeBadge(
                  type: doc.fileType,
                  label: _fileTypeLabel(doc.fileType),
                  color: _fileTypeColor(doc.fileType),
                ),
              ),
              Expanded(
                flex: 1,
                child: _StatusBadge(
                  status: doc.status,
                  label: _statusLabel(doc.status),
                  color: _statusColor(doc.status),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${doc.chunkCount}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${doc.embeddingCount}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  _formatFileSize(doc.fileSizeBytes),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  doc.indexedAt != null ? _formatDate(doc.indexedAt!) : '—',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionMenu(
                      document: doc,
                      onReindex: () => widget.onReindex(doc.id),
                      onDelete: () => widget.onDelete(doc.id),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${_pad(date.month)}-${_pad(date.day)} ${_pad(date.hour)}:${_pad(date.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _TypeBadge extends StatelessWidget {
  final DocumentType type;
  final String label;
  final Color color;

  const _TypeBadge({
    required this.type,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DocumentStatus status;
  final String label;
  final Color color;

  const _StatusBadge({
    required this.status,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == DocumentStatus.processing)
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
          )
        else
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
      ],
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final KbDocument document;
  final VoidCallback onReindex;
  final VoidCallback onDelete;

  const _ActionMenu({
    required this.document,
    required this.onReindex,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: const Icon(
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
      onSelected: (value) {
        switch (value) {
          case 'reindex':
            onReindex();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'view',
          enabled: false,
          child: Row(
            children: [
              const Icon(
                Icons.visibility_outlined,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'View Details',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reindex',
          child: Row(
            children: [
              const Icon(Icons.refresh, size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'Reindex',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Delete',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
