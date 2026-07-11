import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/knowledge_provider.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final _searchController = TextEditingController();
  int? _expandedDocId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KnowledgeProvider>().loadDocuments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KnowledgeProvider>();
    final docs = provider.filteredDocuments;

    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        children: [
          _buildHeader(provider),
          _buildQueryBar(provider),
          _buildSearchBar(provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : docs.isEmpty
                    ? const EmptyState(icon: Icons.menu_book_rounded, title: 'No documents yet', subtitle: 'Upload your first document', actionLabel: 'Upload Document')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) => _buildDocRow(provider, docs[index]),
                      ),
          ),
          if (provider.queryResult != null) _buildQueryResult(provider),
        ],
      ),
    );
  }

  Widget _buildHeader(KnowledgeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Knowledge Base', style: AppTypography.displaySmall),
                const SizedBox(height: 4),
                Text('Manage documents and query your knowledge', style: AppTypography.bodyMedium),
              ],
            ),
          ),
          AppButton(
            label: 'Upload Document',
            icon: Icons.upload_file_rounded,
            onPressed: () => _showUploadDialog(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryBar(KnowledgeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              hint: 'Ask a question about your knowledge base...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
              onChanged: (v) => provider.setSearchQuery(v),
            ),
          ),
          const SizedBox(width: 12),
          AppButton(
            label: 'Search',
            icon: Icons.search_rounded,
            onPressed: () {
              final query = _searchController.text;
              if (query.isNotEmpty) provider.queryKnowledge(query);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(KnowledgeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => provider.setSearchQuery(v),
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Filter documents by title or tags...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.filter_list_rounded, size: 18, color: AppColors.textMuted),
                isDense: true,
                filled: true,
                fillColor: AppColors.inputBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputFocusedBorder),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocRow(KnowledgeProvider provider, dynamic doc) {
    final isExpanded = _expandedDocId == doc.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandedDocId = isExpanded ? null : doc.id),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.description_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Text(doc.title, style: AppTypography.titleMedium, overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 1, child: _badge(doc.typeLabel, AppColors.info)),
                  Expanded(flex: 2, child: Wrap(
                    spacing: 4,
                    children: doc.tags.map<Widget>((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.chipBg, borderRadius: BorderRadius.circular(4)),
                      child: Text(t, style: AppTypography.labelSmall),
                    )).toList(),
                  )),
                  Expanded(flex: 1, child: _badge(doc.isIndexed ? 'Indexed' : 'Pending', doc.isIndexed ? AppColors.success : AppColors.warning)),
                  Expanded(flex: 1, child: Text(doc.createdAt.toString().split('T').first, style: AppTypography.bodySmall)),
                  if (doc.chunkCount > 0) Expanded(flex: 1, child: Text('${doc.chunkCount} chunks', style: AppTypography.bodySmall)),
                  IconButton(
                    onPressed: () => _confirmDelete(context, provider, doc),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    color: AppColors.error,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Icon(isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          if (isExpanded && doc.content != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(doc.content!, style: AppTypography.bodyMedium),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQueryResult(KnowledgeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(top: BorderSide(color: AppColors.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('AI Response', style: AppTypography.titleMedium),
              const Spacer(),
              IconButton(
                onPressed: () => provider.clearQueryResult(),
                icon: const Icon(Icons.close_rounded, size: 16),
                color: AppColors.textMuted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(provider.queryResult!, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }

  void _showUploadDialog(BuildContext context, KnowledgeProvider provider) {
    final nameCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    String docType = 'text';
    List<String> tags = [];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Upload Document', style: AppTypography.displaySmall),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder)),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.inputBorder)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: docType,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceCard,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: ['text', 'pdf', 'csv', 'url'].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                    onChanged: (v) => setState(() => docType = v!),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 5,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagCtrl,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Tags (comma separated)',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    onPressed: () {
                      if (tagCtrl.text.isNotEmpty) {
                        setState(() => tags = tagCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList());
                        tagCtrl.clear();
                      }
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder)),
                ),
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 4, children: tags.map((t) => Chip(
                  label: Text(t, style: AppTypography.labelSmall),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  onDeleted: () => setState(() => tags.remove(t)),
                  backgroundColor: AppColors.chipBg,
                  side: BorderSide.none,
                  labelPadding: const EdgeInsets.only(right: 4),
                )).toList()),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(label: 'Cancel', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(ctx)),
                  const SizedBox(width: 12),
                  AppButton(label: 'Upload', onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      provider.uploadDocument({
                        'title': nameCtrl.text,
                        'content': contentCtrl.text,
                        'document_type': docType,
                        'tags': tags,
                      });
                      Navigator.pop(ctx);
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, KnowledgeProvider provider, dynamic doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${doc.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () {
            provider.deleteDocument(doc.id);
            Navigator.pop(ctx);
          }, child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}
