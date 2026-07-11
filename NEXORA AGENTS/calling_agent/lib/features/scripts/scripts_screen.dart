import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class ScriptsScreen extends StatefulWidget {
  const ScriptsScreen({super.key});

  @override
  State<ScriptsScreen> createState() => _ScriptsScreenState();
}

class _ScriptsScreenState extends State<ScriptsScreen> {
  int? _selectedIndex;

  final _mockScripts = [
    {'name': 'Sales Intro', 'type': 'Outbound', 'version': '2.1', 'active': true, 'updated': '2 days ago'},
    {'name': 'Support Greeting', 'type': 'Inbound', 'version': '1.0', 'active': true, 'updated': '1 week ago'},
    {'name': 'Objection Handling', 'type': 'Training', 'version': '3.0', 'active': false, 'updated': '3 days ago'},
    {'name': 'Follow-up Script', 'type': 'Outbound', 'version': '1.2', 'active': true, 'updated': 'Yesterday'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: _selectedIndex != null ? _buildDetailView() : _buildListView(),
    );
  }

  Widget _buildListView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Scripts', style: AppTypography.displayMedium),
              const Spacer(),
              AppButton(label: 'Create Script', icon: Icons.add, onPressed: () => _showCreateDialog()),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 52, dataRowMaxHeight: 52,
                headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
                columns: const [
                  DataColumn(label: Text('Name', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  DataColumn(label: Text('Type', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  DataColumn(label: Text('Version', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  DataColumn(label: Text('Active', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  DataColumn(label: Text('Updated', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                ],
                rows: _mockScripts.asMap().entries.map((entry) {
                  final s = entry.value;
                  final idx = entry.key;
                  return DataRow(
                    onSelectChanged: (_) => setState(() => _selectedIndex = idx),
                    cells: [
                      DataCell(Text(s['name'] as String, style: AppTypography.bodyMedium)),
                      DataCell(Text(s['type'] as String, style: AppTypography.bodyMedium)),
                      DataCell(Text('v${s['version']}', style: AppTypography.bodyMedium)),
                      DataCell(Icon(s['active'] as bool ? Icons.check_circle : Icons.circle_outlined, color: s['active'] as bool ? AppColors.success : AppColors.textMuted, size: 18)),
                      DataCell(Text(s['updated'] as String, style: AppTypography.bodySmall)),
                      DataCell(Row(
                        children: [
                          _actionChip('Preview'),
                          const SizedBox(width: 4),
                          _actionChip('Duplicate'),
                          _actionChip('Delete'),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    final s = _mockScripts[_selectedIndex!];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                onPressed: () => setState(() => _selectedIndex = null),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(s['name'] as String, style: AppTypography.headlineLarge)),
              AppButton(label: 'Edit', icon: Icons.edit, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Script Preview', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                Text('Type: ${s['type']} | Version: ${s['version']}', style: AppTypography.bodySmall),
                const Divider(height: 24),
                Text(
                  'Hello [lead_name], this is [agent_name] calling from [company_name].\n\n'
                  'I\'m reaching out because [reason_for_call].\n\n'
                  'How are you doing today?\n\n'
                  '[Listen to response]\n\n'
                  'Great! The reason I\'m calling is [pitch].',
                  style: AppTypography.bodyMedium,
                ),
                const Divider(height: 24),
                Text('Variables', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['[lead_name]', '[agent_name]', '[company_name]', '[reason_for_call]', '[pitch]'].map((v) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(v, style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  )).toList(),
                ),
                const Divider(height: 24),
                Text('Sections', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                _buildSectionItem('Opening', 'Introduction and greeting'),
                _buildSectionItem('Discovery', 'Questions to understand needs'),
                _buildSectionItem('Presentation', 'Present solution'),
                _buildSectionItem('Objections', 'Common objections and responses'),
                _buildSectionItem('Closing', 'Call to action'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionItem(String name, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(name, style: AppTypography.bodyMedium),
          const SizedBox(width: 8),
          Text(desc, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _actionChip(String label) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Script', style: AppTypography.headlineLarge),
              const SizedBox(height: 20),
              const AppTextField(label: 'Script Name', hint: 'Enter script name'),
              const SizedBox(height: 16),
              Text('Type', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: 'Outbound',
                items: ['Outbound', 'Inbound', 'Training', 'Support'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (_) {},
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 16),
              const AppTextField(label: 'Content', hint: 'Script content...', maxLines: 8),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  AppButton(label: 'Create', onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
