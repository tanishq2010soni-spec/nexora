import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: AppTypography.displayMedium),
            const SizedBox(height: 24),
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildChartsRow(context),
            const SizedBox(height: 24),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        StatCard(
          label: 'Active Calls',
          value: '12',
          icon: Icons.phone_in_talk,
          iconColor: AppColors.activeCall,
          change: '3',
        ),
        const SizedBox(width: 12),
        StatCard(
          label: 'Calls Today',
          value: '156',
          icon: Icons.call_made,
          iconColor: AppColors.info,
          change: '12%',
        ),
        const SizedBox(width: 12),
        StatCard(
          label: 'Avg Duration',
          value: '4:32',
          icon: Icons.timer_outlined,
          iconColor: AppColors.warning,
        ),
        const SizedBox(width: 12),
        StatCard(
          label: 'Conversion Rate',
          value: '23.5%',
          icon: Icons.trending_up,
          iconColor: AppColors.success,
          change: '2.1%',
        ),
        const SizedBox(width: 12),
        StatCard(
          label: 'Answered %',
          value: '68%',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.secondary,
          change: '5%',
        ),
      ],
    );
  }

  Widget _buildChartsRow(BuildContext context) {
    return Row(
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
                Text('Calls Over Time', style: AppTypography.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.border.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: AppTypography.caption,
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Text(days[value.toInt()], style: AppTypography.caption);
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 45),
                            const FlSpot(1, 52),
                            const FlSpot(2, 38),
                            const FlSpot(3, 65),
                            const FlSpot(4, 58),
                            const FlSpot(5, 72),
                            const FlSpot(6, 68),
                          ],
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
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
                Text('Campaign Performance', style: AppTypography.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.border.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: AppTypography.caption,
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = ['Outbound', 'Inbound', 'Follow-up', 'Survey'];
                              if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(labels[value.toInt()], style: AppTypography.caption),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _buildBarGroup(0, 85, AppColors.primary),
                        _buildBarGroup(1, 55, AppColors.secondary),
                        _buildBarGroup(2, 42, AppColors.warning),
                        _buildBarGroup(3, 30, AppColors.accent),
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
                Text('Call Dispositions', style: AppTypography.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(value: 40, color: AppColors.success, title: 'Answered', radius: 50),
                        PieChartSectionData(value: 20, color: AppColors.warning, title: 'Voicemail', radius: 50),
                        PieChartSectionData(value: 15, color: AppColors.error, title: 'Busy', radius: 50),
                        PieChartSectionData(value: 15, color: AppColors.info, title: 'No Answer', radius: 50),
                        PieChartSectionData(value: 10, color: AppColors.textMuted, title: 'Other', radius: 50),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 28,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
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
                Text('Active Calls', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                _buildActiveCallItem('John Smith', '+1 (555) 123-4567', 'Inbound', '3:24', AppColors.activeCall),
                const Divider(height: 1),
                _buildActiveCallItem('Sarah Johnson', '+1 (555) 987-6543', 'Follow-up', '1:52', AppColors.ringing),
                const Divider(height: 1),
                _buildActiveCallItem('Mike Brown', '+1 (555) 456-7890', 'Support', '5:10', AppColors.activeCall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
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
                Text('Upcoming Scheduled Calls', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                _buildScheduleItem('10:00 AM', 'Alice Williams', 'Follow-up'),
                _buildScheduleItem('11:30 AM', 'Bob Davis', 'Demo'),
                _buildScheduleItem('1:00 PM', 'Carol White', 'Intro Call'),
                _buildScheduleItem('2:30 PM', 'Dan Miller', 'Support'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
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
                Text('Recent Activity', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                _buildActivityItem('Call completed', 'John Smith - 4:23 min', AppColors.success),
                _buildActivityItem('Lead created', 'Sarah Johnson added', AppColors.info),
                _buildActivityItem('Campaign started', 'Q3 Outreach', AppColors.primary),
                _buildActivityItem('Voicemail left', 'Mike Brown', AppColors.warning),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCallItem(String name, String number, String type, String duration, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleMedium),
                Text(number, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(type, style: AppTypography.labelSmall),
              Text(duration, style: AppTypography.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String time, String name, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(time, style: AppTypography.labelSmall),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.bodyMedium),
                Text(type, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
