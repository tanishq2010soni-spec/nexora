import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/filter_bar.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final _mockLogs = [
    {'user': 'Admin', 'action': 'Login', 'resource': 'Session', 'details': 'Admin logged in', 'time': '10:23:45', 'date': 'Today'},
    {'user': 'AI Agent', 'action': 'Call Started', 'resource': 'Call', 'details': 'Call with +1 (555) 123-4567', 'time': '10:15:22', 'date': 'Today'},
    {'user': 'Alice', 'action': 'Campaign Activated', 'resource': 'Campaign', 'details': 'Q3 Outreach activated', 'time': '09:45:10', 'date': 'Today'},
    {'user': 'System', 'action': 'Provider Status', 'resource': 'Provider', 'details': 'Twilio connected', 'time': '09:00:00', 'date': 'Today'},
    {'user': 'Bob', 'action': 'Lead Created', 'resource': 'Lead', 'details': 'New lead: Sarah Johnson', 'time': 'Yesterday', 'date': 'Yesterday'},
    {'user': 'Admin', 'action': 'Settings Updated', 'resource': 'Settings', 'details': 'Voice settings changed', 'time': 'Yesterday', 'date': 'Yesterday'},
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
            Text('Audit Logs', style: AppTypography.displayMedium),
            const SizedBox(height: 16),
            FilterBar(
              searchHint: 'Search logs...',
              onSearch: (v) {},
              chips: [
                FilterChipOption(label: 'All', selected: true, onSelected: (_) {}),
                FilterChipOption(label: 'Today', selected: false, onSelected: (_) {}),
                FilterChipOption(label: 'System', selected: false, onSelected: (_) {}),
                FilterChipOption(label: 'User', selected: false, onSelected: (_) {}),
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
                  dataRowMinHeight: 48, dataRowMaxHeight: 48,
                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
                  columns: const [
                    DataColumn(label: Text('Time', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('User', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('Action', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('Resource', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('Details', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  ],
                  rows: _mockLogs.map((l) => DataRow(
                    cells: [
                      DataCell(Text(l['time']!, style: AppTypography.bodySmall)),
                      DataCell(_buildUserChip(l['user']!)),
                      DataCell(Text(l['action']!, style: AppTypography.bodyMedium)),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(l['resource']!, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      )),
                      DataCell(Text(l['details']!, style: AppTypography.bodyMedium)),
                    ],
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserChip(String user) {
    Color color;
    switch (user) {
      case 'Admin':
        color = AppColors.error;
        break;
      case 'System':
        color = AppColors.info;
        break;
      case 'AI Agent':
        color = AppColors.primary;
        break;
      default:
        color = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(user, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
