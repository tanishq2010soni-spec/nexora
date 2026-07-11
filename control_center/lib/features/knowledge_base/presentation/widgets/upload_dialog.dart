import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/document.dart';

class UploadDialog extends StatefulWidget {
  final String knowledgeBaseId;
  final Future<void> Function(List<UploadFileItem> files) onUpload;

  const UploadDialog({
    super.key,
    required this.knowledgeBaseId,
    required this.onUpload,
  });

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class UploadFileItem {
  final String filename;
  final List<int> bytes;
  final DocumentType fileType;
  bool uploading;
  bool error;

  UploadFileItem({
    required this.filename,
    required this.bytes,
    required this.fileType,
    this.uploading = false,
    this.error = false,
  });
}

class _UploadDialogState extends State<UploadDialog> {
  final List<UploadFileItem> _files = [];
  bool _isUploading = false;
  bool _isDragging = false;

  static const _allowedExtensions = ['pdf', 'docx', 'txt'];
  static const _maxFileSize = 50 * 1024 * 1024;

  DocumentType _fileTypeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return DocumentType.pdf;
      case 'docx':
        return DocumentType.docx;
      case 'txt':
        return DocumentType.txt;
      default:
        return DocumentType.unknown;
    }
  }

  IconData _fileIcon(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf;
      case DocumentType.docx:
        return Icons.description;
      case DocumentType.txt:
        return Icons.text_snippet;
      case DocumentType.unknown:
        return Icons.insert_drive_file;
    }
  }

  Color _fileColor(DocumentType type) {
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

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: _allowedExtensions,
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        for (final file in result.files) {
          if (file.size > _maxFileSize) continue;
          final ext = file.extension ?? '';
          final type = _fileTypeFromExtension(ext);
          _files.add(
            UploadFileItem(
              filename: file.name,
              bytes: file.bytes!,
              fileType: type,
            ),
          );
        }
      });
    }
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
  }

  Future<void> _handleUpload() async {
    if (_files.isEmpty) return;
    setState(() => _isUploading = true);
    try {
      await widget.onUpload(_files);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Documents',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildDropZone(),
              const SizedBox(height: AppSpacing.lg),
              if (_files.isNotEmpty) ...[
                Text(
                  '${_files.length} file(s) selected',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      return _buildFileItem(file, index);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                'Supported formats: PDF, DOCX, TXT (max 50 MB)',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: 'Upload',
                    icon: Icons.cloud_upload_outlined,
                    isLoading: _isUploading,
                    onPressed: _files.isEmpty ? null : _handleUpload,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropZone() {
    return GestureDetector(
      onTap: _pickFiles,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) {
          setState(() => _isDragging = true);
          return true;
        },
        onLeave: (_) => setState(() => _isDragging = false),
        onAcceptWithDetails: (_) {
          setState(() => _isDragging = false);
          _pickFiles();
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 120,
            decoration: BoxDecoration(
              color: _isDragging ? AppColors.accentMuted : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isDragging ? AppColors.accent : AppColors.surfaceBorder,
                width: _isDragging ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 36,
                  color: _isDragging
                      ? AppColors.accent
                      : AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Drag & drop files or click to browse',
                  style: AppTypography.bodyMedium.copyWith(
                    color: _isDragging
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileItem(UploadFileItem file, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(
            _fileIcon(file.fileType),
            size: 18,
            color: _fileColor(file.fileType),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.filename,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatSize(file.bytes.length),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (file.uploading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.textTertiary,
              ),
              onPressed: () => _removeFile(index),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
