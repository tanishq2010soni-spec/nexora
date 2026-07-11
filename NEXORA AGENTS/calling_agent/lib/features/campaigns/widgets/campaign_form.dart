import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class CampaignForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final void Function(Map<String, dynamic> data) onSave;

  const CampaignForm({super.key, this.initialData, required this.onSave});

  @override
  State<CampaignForm> createState() => _CampaignFormState();
}

class _CampaignFormState extends State<CampaignForm> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'outbound';
  String _schedule = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] as String? ?? '';
      _type = widget.initialData!['type'] as String? ?? 'outbound';
      _notesController.text = widget.initialData!['notes'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialData != null ? 'Edit Campaign' : 'Create Campaign',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Campaign Name',
              controller: _nameController,
              hint: 'Enter campaign name',
            ),
            const SizedBox(height: 16),
            Text('Type', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: ['outbound', 'inbound', 'follow-up', 'survey'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v ?? 'outbound'),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Schedule Config (JSON)',
              hint: '{"days": ["mon","wed","fri"], "hours": "9-5"}',
              maxLines: 2,
              controller: TextEditingController(text: _schedule),
              onChanged: (v) => _schedule = v,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Notes',
              hint: 'Optional notes',
              maxLines: 3,
              controller: _notesController,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: widget.initialData != null ? 'Update' : 'Create',
                  onPressed: () {
                    widget.onSave({
                      'name': _nameController.text,
                      'type': _type,
                      'notes': _notesController.text,
                      'schedule_config': _schedule,
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
