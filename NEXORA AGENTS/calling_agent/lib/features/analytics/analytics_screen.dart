import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/stat_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTimeRange? _dateRange;

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
                Text('Analytics', style: AppTypography.displayMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2026, 1, 1),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange ?? DateTimeRange(
                          start: DateTime.now().subtract(const Duration(days: 30)),
                          end: DateTime.now(),
                        ),
                      );
                      if (range != null) setState(() => _dateRange = range);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.date_range, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          _dateRange != null
                              ? '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
                              : 'Last 30 days',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                StatCard(label: 'Total Calls', value: '1,245', icon: Icons.phone, iconColor: AppColors.primary, change: '8%'),
                StatCard(label: 'Answer Rate', value: '68.2%', icon: Icons.call_received, iconColor: AppColors.success, change: '3%'),
                StatCard(label: 'Avg Duration', value: '3:48', icon: Icons.timer, iconColor: AppColors.info),
                StatCard(label: 'Conversion', value: '23.5%', icon: Icons.trending_up, iconColor: AppColors.warning, change: '2.1%'),
                StatCard(label: 'Revenue', value: '\$48,250', icon: Icons.attach_money, iconColor: AppColors.accent, change: '12%'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Call Trends', style: AppTypography.titleMedium),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border.withValues(alpha: 0.3), strokeWidth: 1)),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: AppTypography.caption))),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(DateFormat('M/d').format(DateTime(2026, 6, v.toInt() + 1)), style: AppTypography.caption))),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              minY: 0,
                              lineBarsData: [
                                LineChartBarData(spots: List.generate(14, (i) => FlSpot(i.toDouble(), 30 + (i * 3.5) + (i % 3 == 0 ? 10 : 0))), isCurved: true, color: AppColors.primary, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1))),
                                LineChartBarData(spots: List.generate(14, (i) => FlSpot(i.toDouble(), 20 + (i * 2.0) + (i % 4 == 0 ? 8 : 0))), isCurved: true, color: AppColors.success, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: AppColors.success.withValues(alpha: 0.1))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _legendDot(AppColors.primary, 'Calls'),
                            const SizedBox(width: 24),
                            _legendDot(AppColors.success, 'Duration (min)'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Campaign Comparison', style: AppTypography.titleMedium),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border.withValues(alpha: 0.3), strokeWidth: 1)),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: AppTypography.caption))),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Padding(padding: const EdgeInsets.only(top: 4), child: Text(['Q3', 'Support', 'Follow-up', 'Survey'][v.toInt()], style: AppTypography.caption)))),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 85, color: AppColors.primary, width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
                                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 62, color: AppColors.secondary, width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
                                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 45, color: AppColors.warning, width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
                                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 38, color: AppColors.accent, width: 20, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dispositions', style: AppTypography.titleMedium),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: PieChart(PieChartData(
                            sections: [
                              PieChartSectionData(value: 40, color: AppColors.success, title: 'Answered', radius: 55),
                              PieChartSectionData(value: 22, color: AppColors.warning, title: 'Voicemail', radius: 55),
                              PieChartSectionData(value: 15, color: AppColors.error, title: 'Busy', radius: 55),
                              PieChartSectionData(value: 13, color: AppColors.info, title: 'No Answer', radius: 55),
                              PieChartSectionData(value: 10, color: AppColors.textMuted, title: 'Other', radius: 55),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Agent Performance', style: AppTypography.titleMedium),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 44,
                      dataRowMinHeight: 48, dataRowMaxHeight: 48,
                      headingRowColor: WidgetStateProperty.all(AppColors.surfaceLight),
                      columns: const [
                        DataColumn(label: Text('Agent', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                        DataColumn(label: Text('Calls', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                        DataColumn(label: Text('Answered', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                        DataColumn(label: Text('Avg Duration', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                        DataColumn(label: Text('Conversion', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                        DataColumn(label: Text('Score', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                      ],
                      rows: [
                        ['AI Agent', '342', '287', '3:52', '28.5%', '94'],
                        ['Alice (Human)', '156', '112', '4:15', '22.3%', '87'],
                        ['Bob (Human)', '98', '71', '5:02', '18.9%', '82'],
                      ].map((r) => DataRow(cells: r.map((c) => DataCell(Text(c, style: AppTypography.bodyMedium))).toList())).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
