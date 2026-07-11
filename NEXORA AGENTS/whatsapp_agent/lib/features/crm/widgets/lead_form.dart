import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/lead.dart';

class LeadFormDialog extends StatefulWidget {
  final Lead? lead;

  const LeadFormDialog({super.key, this.lead});

  @override
  State<LeadFormDialog> createState() => _LeadFormDialogState();
}

class _LeadFormDialogState extends State<LeadFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _notesCtrl;
  String _selectedSource = 'whatsapp';
  String _selectedStage = 'new';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.lead?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.lead?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.lead?.email ?? '');
    _notesCtrl = TextEditingController(text: widget.lead?.notes ?? '');
    _selectedSource = widget.lead?.source ?? 'whatsapp';
    _selectedStage = widget.lead?.stage ?? 'new';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lead != null;
    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Lead' : 'New Lead',
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Name *',
                hint: 'Enter lead name',
                controller: _nameCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Phone',
                      hint: '+1234567890',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Email',
                      hint: 'email@example.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown('Source', _selectedSource, ['whatsapp', 'website', 'referral', 'manual', 'other'],
                        (v) => setState(() => _selectedSource = v!)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown('Stage', _selectedStage, Lead.stages,
                        (v) => setState(() => _selectedStage = v!)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Notes',
                hint: 'Add notes...',
                controller: _notesCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: isEditing ? 'Update' : 'Create',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'name': _nameCtrl.text,
                          'phone': _phoneCtrl.text,
                          'email': _emailCtrl.text,
                          'source': _selectedSource,
                          'stage': _selectedStage,
                          'notes': _notesCtrl.text,
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceCard,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item[0].toUpperCase() + item.substring(1)),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
