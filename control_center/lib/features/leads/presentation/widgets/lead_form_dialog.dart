import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/models/lead.dart';

class LeadFormDialog extends StatefulWidget {
  final String title;
  final Lead? lead;
  final Future<void> Function(Lead lead) onSave;

  const LeadFormDialog({
    super.key,
    required this.title,
    this.lead,
    required this.onSave,
  });

  @override
  State<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends State<LeadFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _notesController;
  late LeadStatus _selectedStatus;
  late LeadSource _selectedSource;
  bool _isSaving = false;

  bool get _isEditing => widget.lead != null;

  @override
  void initState() {
    super.initState();
    final lead = widget.lead;
    _nameController = TextEditingController(text: lead?.name ?? '');
    _emailController = TextEditingController(text: lead?.email ?? '');
    _phoneController = TextEditingController(text: lead?.phone ?? '');
    _companyController = TextEditingController(text: lead?.company ?? '');
    _jobTitleController = TextEditingController(text: lead?.jobTitle ?? '');
    _notesController = TextEditingController(text: lead?.notes ?? '');
    _selectedStatus = lead?.status ?? LeadStatus.newLead;
    _selectedSource = lead?.source ?? LeadSource.manual;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Invalid email address';
      }
    }
    return null;
  }

  Future<void> _handleSave() async {
    final nameError = _validateName(_nameController.text);
    if (nameError != null) return;

    final emailError = _validateEmail(_emailController.text);
    if (emailError != null) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final lead = Lead(
        id: widget.lead?.id ?? '',
        orgId: widget.lead?.orgId ?? '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        jobTitle: _jobTitleController.text.trim().isEmpty
            ? null
            : _jobTitleController.text.trim(),
        status: _selectedStatus,
        source: _selectedSource,
        assignedTo: widget.lead?.assignedTo,
        assignedToName: widget.lead?.assignedToName,
        aiScore: widget.lead?.aiScore ?? 0,
        intentScore: widget.lead?.intentScore ?? 0,
        budgetScore: widget.lead?.budgetScore ?? 0,
        engagementScore: widget.lead?.engagementScore ?? 0,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        metadata: widget.lead?.metadata,
        conversationId: widget.lead?.conversationId,
        lastContactedAt: widget.lead?.lastContactedAt,
        qualifiedAt: widget.lead?.qualifiedAt,
        wonAt: widget.lead?.wonAt,
        lostAt: widget.lead?.lostAt,
        createdAt: widget.lead?.createdAt ?? now,
        updatedAt: now,
      );

      await widget.onSave(lead);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Name *',
                hint: 'e.g. John Smith',
                controller: _nameController,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Email',
                      hint: 'john@company.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Phone',
                      hint: '+1 (555) 000-0000',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Company',
                      hint: 'Acme Inc.',
                      controller: _companyController,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Job Title',
                      hint: 'Product Manager',
                      controller: _jobTitleController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<LeadStatus>(
                      label: 'Status',
                      value: _selectedStatus,
                      items: LeadStatus.values,
                      labelBuilder: _statusLabel,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildDropdown<LeadSource>(
                      label: 'Source',
                      value: _selectedSource,
                      items: LeadSource.values,
                      labelBuilder: _sourceLabel,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSource = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Notes',
                hint: 'Additional notes about this lead...',
                controller: _notesController,
                maxLines: 3,
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
                    label: _isEditing ? 'Update Lead' : 'Create Lead',
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            underline: const SizedBox.shrink(),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(labelBuilder(item)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _statusLabel(LeadStatus status) {
    return switch (status) {
      LeadStatus.newLead => 'New',
      LeadStatus.contacted => 'Contacted',
      LeadStatus.qualified => 'Qualified',
      LeadStatus.proposalSent => 'Proposal Sent',
      LeadStatus.negotiation => 'Negotiation',
      LeadStatus.won => 'Won',
      LeadStatus.lost => 'Lost',
    };
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
}
