import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class CallQueueScreen extends StatefulWidget {
  const CallQueueScreen({super.key});

  @override
  State<CallQueueScreen> createState() => _CallQueueScreenState();
}

class _CallQueueScreenState extends State<CallQueueScreen> {
  final _mockQueue = [
    {'pos': '1', 'caller': 'Tom Wilson', 'number': '+1 (555) 111-2233', 'campaign': 'Q3 Outreach', 'wait': '2:15', 'priority': 'High'},
    {'pos': '2', 'caller': 'Lisa Anderson', 'number': '+1 (555) 222-3344', 'campaign': 'Support', 'wait': '1:45', 'priority': 'Medium'},
    {'pos': '3', 'caller': 'James Taylor', 'number': '+1 (555) 333-4455', 'campaign': 'Follow-up', 'wait': '0:55', 'priority': 'Low'},
    {'pos': '4', 'caller': 'Nancy White', 'number': '+1 (555) 444-5566', 'campaign': 'Survey', 'wait': '0:30', 'priority': 'Medium'},
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
                Text('Call Queue', style: AppTypography.displayMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Est. Wait: 4:30', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                AppButton(label: 'Bulk Actions', icon: Icons.checklist),
              ],
            ),
            const SizedBox(height: 24),
            _buildQueueTable(),
            const SizedBox(height: 24),
            _buildQueueStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTable() {
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
          dataRowMinHeight: 56, dataRowMaxHeight: 56,
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
          columns: const [
            DataColumn(label: Text('Pos', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Caller', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Number', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Campaign', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Wait Time', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Priority', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
            DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
          ],
          rows: _mockQueue.map((item) => DataRow(
            cells: [
              DataCell(Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(item['pos']!, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13))),
              )),
              DataCell(Text(item['caller']!, style: AppTypography.bodyMedium)),
              DataCell(Text(item['number']!, style: AppTypography.bodyMedium)),
              DataCell(Text(item['campaign']!, style: AppTypography.bodyMedium)),
              DataCell(Text(item['wait']!, style: AppTypography.bodyMedium)),
              DataCell(_buildPriorityBadge(item['priority']!)),
              DataCell(Row(
                children: [
                  _buildActionChip(Icons.person_add, 'Assign'),
                  const SizedBox(width: 4),
                  _buildActionChip(Icons.phone_in_talk, 'Answer'),
                ],
              )),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = AppColors.error;
        break;
      case 'medium':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.success;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(priority, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueStats() {
    return Row(
      children: [
        _buildStatBox('Calls Waiting', '4'),
        const SizedBox(width: 16),
        _buildStatBox('Avg Wait Time', '1:36'),
        const SizedBox(width: 16),
        _buildStatBox('Longest Wait', '2:15'),
        const SizedBox(width: 16),
        _buildStatBox('Agents Available', '3'),
      ],
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.headlineLarge),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }
}
