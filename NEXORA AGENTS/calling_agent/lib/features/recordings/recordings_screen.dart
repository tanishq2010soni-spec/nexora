import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/filter_bar.dart';

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  int? _expandedIndex;

  final _mockRecordings = [
    {'call_id': 'C001', 'contact': 'John Smith', 'duration': '4:23', 'date': '2026-06-30', 'status': 'Completed', 'transcript': 'Ready'},
    {'call_id': 'C002', 'contact': 'Sarah Johnson', 'duration': '2:15', 'date': '2026-06-30', 'status': 'Completed', 'transcript': 'Processing'},
    {'call_id': 'C003', 'contact': 'Mike Brown', 'duration': '6:48', 'date': '2026-06-29', 'status': 'Completed', 'transcript': 'Ready'},
    {'call_id': 'C004', 'contact': 'Emily Davis', 'duration': '1:05', 'date': '2026-06-29', 'status': 'Failed', 'transcript': 'N/A'},
    {'call_id': 'C005', 'contact': 'Tom Wilson', 'duration': '3:32', 'date': '2026-06-28', 'status': 'Completed', 'transcript': 'Ready'},
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
            Text('Recordings', style: AppTypography.displayMedium),
            const SizedBox(height: 16),
            FilterBar(
              searchHint: 'Search recordings...',
              onSearch: (v) {},
              chips: [
                FilterChipOption(label: 'All', selected: true, onSelected: (_) {}),
                FilterChipOption(label: 'Today', selected: false, onSelected: (_) {}),
                FilterChipOption(label: 'This Week', selected: false, onSelected: (_) {}),
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
                    DataColumn(label: Text('Call ID', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('Contact', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('Duration', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('Date', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('Status', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('Transcript', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                    DataColumn(label: Text('Actions', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                  ],
                  rows: _mockRecordings.asMap().entries.map((entry) {
                    final r = entry.value;
                    final idx = entry.key;
                    return DataRow(
                      selected: _expandedIndex == idx,
                      onSelectChanged: (_) => setState(() => _expandedIndex = _expandedIndex == idx ? null : idx),
                      cells: [
                        DataCell(Text(r['call_id']!, style: AppTypography.bodyMedium)),
                        DataCell(Text(r['contact']!, style: AppTypography.bodyMedium)),
                        DataCell(Text(r['duration']!, style: AppTypography.bodyMedium)),
                        DataCell(Text(r['date']!, style: AppTypography.bodySmall)),
                        DataCell(_statusBadge(r['status']!)),
                        DataCell(_transcriptBadge(r['transcript']!)),
                        DataCell(Row(
                          children: [
                            _actionIcon(Icons.play_arrow, AppColors.success),
                            _actionIcon(Icons.download, AppColors.info),
                            _actionIcon(Icons.archive, AppColors.warning),
                            _actionIcon(Icons.delete_outline, AppColors.error),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            if (_expandedIndex != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Transcription View', style: AppTypography.titleMedium),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                          onPressed: () => setState(() => _expandedIndex = null),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(
                      'Sample transcript text for the selected recording. This would contain the full conversation transcript generated by the STT pipeline...',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'Completed' ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _transcriptBadge(String status) {
    Color color;
    switch (status) {
      case 'Ready':
        color = AppColors.success;
        break;
      case 'Processing':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionIcon(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
