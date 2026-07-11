import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/filter_bar.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  int? _expandedIndex;

  final _mockLeads = [
    {'name': 'Alice Williams', 'phone': '+1 (555) 111-2233', 'company': 'Acme Corp', 'status': 'New', 'score': '85', 'last': 'Never', 'next': 'Today 2pm', 'dnc': 'No'},
    {'name': 'Bob Davis', 'phone': '+1 (555) 222-3344', 'company': 'TechCo', 'status': 'Contacted', 'score': '72', 'last': '2 days ago', 'next': 'Tomorrow', 'dnc': 'No'},
    {'name': 'Carol White', 'phone': '+1 (555) 333-4455', 'company': 'DataSys', 'status': 'Qualified', 'score': '91', 'last': 'Yesterday', 'next': 'Today 4pm', 'dnc': 'No'},
    {'name': 'Dan Miller', 'phone': '+1 (555) 444-5566', 'company': 'Cloud Inc', 'status': 'Converted', 'score': '95', 'last': '1 week ago', 'next': '-', 'dnc': 'No'},
    {'name': 'Eve Martin', 'phone': '+1 (555) 555-6677', 'company': 'StartupXYZ', 'status': 'DNC', 'score': '0', 'last': '3 days ago', 'next': '-', 'dnc': 'Yes'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Leads', style: AppTypography.displayMedium),
                const Spacer(),
                AppButton(label: 'Import CSV', icon: Icons.upload_file, onPressed: () {}),
                const SizedBox(width: 12),
                AppButton(label: 'Add Lead', icon: Icons.add, onPressed: () => _showAddLeadDialog()),
              ],
            ),
            const SizedBox(height: 16),
            FilterBar(
              searchHint: 'Search leads...',
              onSearch: (v) {},
              chips: [
                FilterChipOption(label: 'All', selected: true, onSelected: (_) {}),
                FilterChipOption(label: 'New', selected: false, onSelected: (_) {}),
                FilterChipOption(label: 'Contacted', selected: false, onSelected: (_) {}),
                FilterChipOption(label: 'Qualified', selected: false, onSelected: (_) {}),
                FilterChipOption(label: 'Converted', selected: false, onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 16),
            _buildLeadsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 48,
          dataRowMinHeight: 52, dataRowMaxHeight: 52,
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
          columns: const [
            DataColumn(label: Text('Name', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Phone', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Company', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Status', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Score', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Last Called', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Next Call', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('DNC', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
          ],
          rows: _mockLeads.asMap().entries.map((entry) {
            final l = entry.value;
            final idx = entry.key;
            return DataRow(
              selected: _expandedIndex == idx,
              onSelectChanged: (_) => setState(() => _expandedIndex = _expandedIndex == idx ? null : idx),
              cells: [
                DataCell(Text(l['name']!, style: AppTypography.bodyMedium)),
                DataCell(Text(l['phone']!, style: AppTypography.bodyMedium)),
                DataCell(Text(l['company']!, style: AppTypography.bodyMedium)),
                DataCell(_buildStatusBadge(l['status']!)),
                DataCell(_buildScoreBadge(l['score']!)),
                DataCell(Text(l['last']!, style: AppTypography.bodySmall)),
                DataCell(Text(l['next']!, style: AppTypography.bodySmall)),
                DataCell(Text(l['dnc']!, style: TextStyle(color: l['dnc'] == 'Yes' ? AppColors.error : AppColors.success, fontSize: 12))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'New':
        color = AppColors.info;
        break;
      case 'Contacted':
        color = AppColors.warning;
        break;
      case 'Qualified':
        color = AppColors.primary;
        break;
      case 'Converted':
        color = AppColors.success;
        break;
      default:
        color = AppColors.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildScoreBadge(String score) {
    final s = int.parse(score);
    Color color;
    if (s >= 80) color = AppColors.success;
    else if (s >= 60) color = AppColors.warning;
    else color = AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
      child: Text(score, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  void _showAddLeadDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Lead', style: AppTypography.headlineLarge),
              const SizedBox(height: 20),
              const AppTextField(label: 'Name', hint: 'Full name'),
              const SizedBox(height: 12),
              const AppTextField(label: 'Phone', hint: '+1 (555) 000-0000'),
              const SizedBox(height: 12),
              const AppTextField(label: 'Email', hint: 'email@example.com'),
              const SizedBox(height: 12),
              const AppTextField(label: 'Company', hint: 'Company name'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  AppButton(label: 'Add Lead', onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
