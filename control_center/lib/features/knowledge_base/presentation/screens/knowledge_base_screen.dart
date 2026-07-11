import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/stat_card.dart';

import '../../domain/models/knowledge_base.dart';
import '../../domain/models/document.dart';
import '../../providers/knowledge_base_provider.dart';
import '../widgets/kb_card.dart';
import '../widgets/kb_form_dialog.dart';
import '../widgets/kb_search_bar.dart';
import '../widgets/kb_filters_row.dart';
import '../widgets/document_table.dart';
import '../widgets/upload_dialog.dart';

class KnowledgeBaseScreen extends ConsumerStatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  ConsumerState<KnowledgeBaseScreen> createState() =>
      _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends ConsumerState<KnowledgeBaseScreen> {
  String? _selectedKbId;
  String _searchQuery = '';
  DocumentStatus? _statusFilter;
  DocumentType? _typeFilter;
  Set<String> _selectedDocIds = {};

  @override
  Widget build(BuildContext context) {
    final kbListAsync = ref.watch(kbListProvider);
    final statsAsync = ref.watch(kbStatisticsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: AppSpacing.xl),
          _buildStatsRow(statsAsync),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: _selectedKbId == null
                ? _buildKbList(context, ref, kbListAsync)
                : _buildDocumentView(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (_selectedKbId != null) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                color: AppColors.textSecondary,
                onPressed: () => setState(() {
                  _selectedKbId = null;
                  _searchQuery = '';
                  _statusFilter = null;
                  _typeFilter = null;
                  _selectedDocIds = {};
                }),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(
              _selectedKbId == null ? 'Knowledge Base' : _selectedKbName(ref),
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        Row(
          children: [
            if (_selectedKbId != null) ...[
              AppButton(
                label: 'Upload Document',
                icon: Icons.upload_file,
                onPressed: () => _showUploadDialog(context, ref),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (_selectedDocIds.isNotEmpty)
                AppButton(
                  label: 'Delete (${_selectedDocIds.length})',
                  variant: AppButtonVariant.danger,
                  icon: Icons.delete_outline,
                  onPressed: () => _bulkDeleteDocuments(context, ref),
                ),
            ] else
              AppButton(
                label: 'Create Knowledge Base',
                icon: Icons.add,
                onPressed: () => _showCreateKbDialog(context, ref),
              ),
          ],
        ),
      ],
    );
  }

  String _selectedKbName(WidgetRef ref) {
    final kbListAsync = ref.watch(kbListProvider);
    return kbListAsync.when(
      data: (kbs) {
        final kb = kbs.where((k) => k.id == _selectedKbId).firstOrNull;
        return kb?.name ?? 'Knowledge Base';
      },
      loading: () => 'Knowledge Base',
      error: (_, _) => 'Knowledge Base',
    );
  }

  Widget _buildStatsRow(AsyncValue statsAsync) {
    return statsAsync.when(
      loading: () => const SizedBox(height: 80, child: AppLoader()),
      error: (e, _) => const SizedBox(height: 40),
      data: (stats) => Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Total KBs',
              value: '${stats.totalKnowledgeBases}',
              subtitle: 'Knowledge bases',
              icon: Icons.library_books_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StatCard(
              title: 'Total Documents',
              value: '${stats.totalDocuments}',
              subtitle: '${stats.indexedDocuments} indexed',
              icon: Icons.description_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StatCard(
              title: 'Total Chunks',
              value: '${stats.totalChunks}',
              subtitle: '${stats.totalEmbeddings} embeddings',
              icon: Icons.view_module_outlined,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: StatCard(
              title: 'Processing',
              value: '${stats.processingDocuments}',
              subtitle: '${stats.errorDocuments} errors',
              icon: Icons.sync_outlined,
              trendColor: stats.processingDocuments > 0
                  ? AppColors.warning
                  : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKbList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<KnowledgeBase>> kbListAsync,
  ) {
    return kbListAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(kbListProvider),
      ),
      data: (kbs) {
        if (kbs.isEmpty) {
          return EmptyState(
            icon: Icons.library_books_outlined,
            title: 'No Knowledge Bases',
            subtitle: 'Create your first knowledge base to get started.',
            action: AppButton(
              label: 'Create Knowledge Base',
              icon: Icons.add,
              onPressed: () => _showCreateKbDialog(context, ref),
            ),
          );
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.5,
          ),
          itemCount: kbs.length,
          itemBuilder: (context, index) {
            final kb = kbs[index];
            return KbCard(
              kb: kb,
              onViewDocuments: () => setState(() => _selectedKbId = kb.id),
              onEdit: () => _showEditKbDialog(context, ref, kb),
              onDelete: () => _confirmDeleteKb(context, ref, kb),
            );
          },
        );
      },
    );
  }

  Widget _buildDocumentView(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(kbDocumentsProvider(_selectedKbId!));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: KbSearchBar(
                hintText: 'Search documents...',
                onSearch: (query) => setState(() => _searchQuery = query),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            KbFiltersRow(
              selectedStatus: _statusFilter,
              selectedType: _typeFilter,
              onStatusChanged: (status) =>
                  setState(() => _statusFilter = status),
              onTypeChanged: (type) => setState(() => _typeFilter = type),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: documentsAsync.when(
            loading: () => const AppLoader(),
            error: (e, _) => ErrorView(
              exception: e is AppException ? e : UnknownException(e.toString()),
              onRetry: () =>
                  ref.invalidate(kbDocumentsProvider(_selectedKbId!)),
            ),
            data: (documents) {
              final filtered = _applyFilters(documents);

              if (_searchQuery.isNotEmpty && _selectedKbId != null) {
                return _buildSearchResults(context, ref);
              }

              return DocumentTable(
                documents: filtered,
                selectedIds: _selectedDocIds,
                onDocumentTap: (id) {},
                onDelete: (id) => _confirmDeleteDocument(context, ref, id),
                onReindex: (id) => _reindexDocument(ref, id),
                onSelectionChanged: (ids) =>
                    setState(() => _selectedDocIds = ids),
                emptyMessage: _searchQuery.isNotEmpty
                    ? 'No matching documents'
                    : 'No documents yet',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, WidgetRef ref) {
    if (_selectedKbId == null) return const SizedBox.shrink();

    final searchAsync = ref.watch(
      kbSearchProvider((kbId: _selectedKbId!, query: _searchQuery)),
    );

    return searchAsync.when(
      loading: () => const AppLoader(),
      error: (e, _) => ErrorView(
        exception: e is AppException ? e : UnknownException(e.toString()),
        onRetry: () => ref.invalidate(
          kbSearchProvider((kbId: _selectedKbId!, query: _searchQuery)),
        ),
      ),
      data: (documents) {
        final filtered = _applyFilters(documents);
        return DocumentTable(
          documents: filtered,
          selectedIds: _selectedDocIds,
          onDocumentTap: (id) {},
          onDelete: (id) => _confirmDeleteDocument(context, ref, id),
          onReindex: (id) => _reindexDocument(ref, id),
          onSelectionChanged: (ids) => setState(() => _selectedDocIds = ids),
          emptyMessage: 'No documents match your search',
        );
      },
    );
  }

  List<KbDocument> _applyFilters(List<KbDocument> documents) {
    var filtered = documents;
    if (_statusFilter != null) {
      filtered = filtered.where((d) => d.status == _statusFilter).toList();
    }
    if (_typeFilter != null) {
      filtered = filtered.where((d) => d.fileType == _typeFilter).toList();
    }
    return filtered;
  }

  void _showCreateKbDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => KbFormDialog(
        title: 'Create Knowledge Base',
        onSave: (name, description) async {
          await ref.read(
            createKnowledgeBaseProvider((
              name: name,
              description: description,
            )).future,
          );
          ref.invalidate(kbListProvider);
          ref.invalidate(kbStatisticsProvider);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditKbDialog(
    BuildContext context,
    WidgetRef ref,
    KnowledgeBase kb,
  ) {
    showDialog(
      context: context,
      builder: (_) => KbFormDialog(
        title: 'Edit Knowledge Base',
        knowledgeBase: kb,
        onSave: (name, description) async {
          final repo = ref.read(kbRepositoryProvider);
          await repo.updateKnowledgeBase(kb.id, name, description);
          ref.invalidate(kbListProvider);
          if (_selectedKbId == kb.id) {
            ref.invalidate(kbDetailProvider(kb.id));
          }
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _confirmDeleteKb(
    BuildContext context,
    WidgetRef ref,
    KnowledgeBase kb,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Knowledge Base',
      message:
          'Are you sure you want to delete "${kb.name}"? This will also delete all ${kb.documentCount} document(s) and their embeddings. This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await ref.read(deleteKnowledgeBaseProvider(kb.id).future);
      ref.invalidate(kbListProvider);
      ref.invalidate(kbStatisticsProvider);
      if (_selectedKbId == kb.id) {
        setState(() => _selectedKbId = null);
      }
    }
  }

  void _showUploadDialog(BuildContext context, WidgetRef ref) {
    if (_selectedKbId == null) return;

    showDialog(
      context: context,
      builder: (_) => UploadDialog(
        knowledgeBaseId: _selectedKbId!,
        onUpload: (files) async {
          final repo = ref.read(kbRepositoryProvider);
          for (final file in files) {
            await repo.uploadDocument(
              _selectedKbId!,
              file.bytes,
              file.filename,
            );
          }
          ref.invalidate(kbDocumentsProvider(_selectedKbId!));
          ref.invalidate(kbListProvider);
          ref.invalidate(kbStatisticsProvider);
        },
      ),
    );
  }

  Future<void> _confirmDeleteDocument(
    BuildContext context,
    WidgetRef ref,
    String docId,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Document',
      message:
          'Are you sure you want to delete this document? The embeddings will also be removed.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      await ref.read(deleteDocumentProvider(docId).future);
      if (_selectedKbId != null) {
        ref.invalidate(kbDocumentsProvider(_selectedKbId!));
      }
      ref.invalidate(kbListProvider);
      ref.invalidate(kbStatisticsProvider);
      _selectedDocIds.remove(docId);
    }
  }

  void _reindexDocument(WidgetRef ref, String docId) {
    ref.read(reindexDocumentProvider(docId));
    if (_selectedKbId != null) {
      Future.delayed(const Duration(seconds: 2), () {
        ref.invalidate(kbDocumentsProvider(_selectedKbId!));
      });
    }
  }

  Future<void> _bulkDeleteDocuments(BuildContext context, WidgetRef ref) async {
    final count = _selectedDocIds.length;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Documents',
      message:
          'Are you sure you want to delete $count selected document(s)? This action cannot be undone.',
      confirmLabel: 'Delete All',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      final repo = ref.read(kbRepositoryProvider);
      for (final docId in _selectedDocIds) {
        await repo.deleteDocument(docId);
      }
      setState(() => _selectedDocIds = {});
      if (_selectedKbId != null) {
        ref.invalidate(kbDocumentsProvider(_selectedKbId!));
      }
      ref.invalidate(kbListProvider);
      ref.invalidate(kbStatisticsProvider);
    }
  }
}
