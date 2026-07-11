import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';

class AppointmentForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final void Function(Map<String, dynamic> data) onSave;

  const AppointmentForm({super.key, this.initialData, required this.onSave});

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dateTime = DateTime.now().add(const Duration(hours: 1));
  String _status = 'scheduled';

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] as String? ?? '';
      _notesController.text = widget.initialData!['notes'] as String? ?? '';
      if (widget.initialData!['date_time'] != null) {
        _dateTime = DateTime.parse(widget.initialData!['date_time'] as String);
      }
      _status = widget.initialData!['status'] as String? ?? 'scheduled';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialData != null ? 'Edit Appointment' : 'New Appointment',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: 20),
            Text('Title', style: AppTypography.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Appointment title',
                hintStyle: AppTypography.bodySmall,
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Date & Time', style: AppTypography.labelLarge),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dateTime,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
                  if (time != null) {
                    setState(() => _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      '${_dateTime.day}/${_dateTime.month}/${_dateTime.year} ${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Status', style: AppTypography.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _status,
              items: ['scheduled', 'completed', 'cancelled', 'no-show'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _status = v ?? 'scheduled'),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Notes', style: AppTypography.labelLarge),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Optional notes',
                hintStyle: AppTypography.bodySmall,
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: 12),
                AppButton(
                  label: 'Save',
                  onPressed: () {
                    widget.onSave({
                      'title': _titleController.text,
                      'date_time': _dateTime.toIso8601String(),
                      'status': _status,
                      'notes': _notesController.text,
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
