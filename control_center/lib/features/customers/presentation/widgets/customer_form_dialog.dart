import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/models/customer.dart';

class CustomerFormDialog extends StatefulWidget {
  final String title;
  final Customer? customer;
  final ValueChanged<Customer> onSave;

  const CustomerFormDialog({
    super.key,
    required this.title,
    this.customer,
    required this.onSave,
  });

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _jobTitleController;
  late CustomerSegment _selectedSegment;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _emailController = TextEditingController(
      text: widget.customer?.email ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? '',
    );
    _companyController = TextEditingController(
      text: widget.customer?.company ?? '',
    );
    _jobTitleController = TextEditingController(
      text: widget.customer?.jobTitle ?? '',
    );
    _selectedSegment = widget.customer?.segment ?? CustomerSegment.newCustomer;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      title: Text(
        widget.title,
        style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Name', _nameController, required: true),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Email', _emailController),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Phone', _phoneController),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Company', _companyController),
                const SizedBox(height: AppSpacing.md),
                _buildTextField('Job Title', _jobTitleController),
                const SizedBox(height: AppSpacing.md),
                _buildSegmentDropdown(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: widget.customer != null ? 'Update' : 'Create',
          onPressed: _submit,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surfaceHover,
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
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildSegmentDropdown() {
    return DropdownButtonFormField<CustomerSegment>(
      initialValue: _selectedSegment,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Segment',
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surfaceHover,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      items: CustomerSegment.values.map((segment) {
        return DropdownMenuItem(value: segment, child: Text(segment.name));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedSegment = value);
        }
      },
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final now = DateTime.now();
      final customer = Customer(
        id: widget.customer?.id ?? '',
        orgId: widget.customer?.orgId ?? '',
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
        segment: _selectedSegment,
        healthScore: widget.customer?.healthScore ?? 0,
        engagementScore: widget.customer?.engagementScore ?? 0,
        retentionScore: widget.customer?.retentionScore ?? 0,
        satisfactionScore: widget.customer?.satisfactionScore ?? 0,
        revenueScore: widget.customer?.revenueScore ?? 0,
        assignedTo: widget.customer?.assignedTo,
        assignedToName: widget.customer?.assignedToName,
        leadId: widget.customer?.leadId,
        totalInteractions: widget.customer?.totalInteractions ?? 0,
        totalRevenue: widget.customer?.totalRevenue ?? 0,
        tags: widget.customer?.tags ?? [],
        preferences: widget.customer?.preferences,
        memory: widget.customer?.memory,
        lastInteractionAt: widget.customer?.lastInteractionAt,
        lastPurchaseAt: widget.customer?.lastPurchaseAt,
        churnedAt: widget.customer?.churnedAt,
        createdAt: widget.customer?.createdAt ?? now,
        updatedAt: now,
      );
      widget.onSave(customer);
    }
  }
}
