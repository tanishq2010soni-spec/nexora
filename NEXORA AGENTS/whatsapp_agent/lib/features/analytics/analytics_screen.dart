import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/stat_card.dart';
import '../../providers/analytics_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    return Container(
      color: AppColors.scaffoldBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analytics', style: AppTypography.displaySmall),
                      const SizedBox(height: 4),
                      Text('Performance metrics and insights', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                _buildDateRangePicker(provider),
              ],
            ),
            const SizedBox(height: 24),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildStatCards(provider),
              const SizedBox(height: 24),
              _buildCharts(provider),
              const SizedBox(height: 24),
              _buildRevenueTable(provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(AnalyticsProvider provider) {
    return GestureDetector(
      onTap: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2024),
          lastDate: DateTime.now(),
          initialDateRange: provider.startDate != null && provider.endDate != null
              ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
              : null,
        );
        if (range != null) {
          provider.setDateRange(range.start, range.end);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              provider.startDate != null
                  ? '${provider.startDate!.month}/${provider.startDate!.day} - ${provider.endDate!.month}/${provider.endDate!.day}'
                  : 'Last 30 days',
              style: AppTypography.bodyMedium,
            ),
            if (provider.startDate != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => provider.clearDateRange(),
                child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(AnalyticsProvider provider) {
    final overview = provider.overview;
    if (overview == null) return const SizedBox();

    return Row(
      children: [
        Expanded(child: StatCard(icon: Icons.chat_rounded, label: 'Active Conversations', value: '${overview.activeConversations}', trend: 12.5, iconColor: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: StatCard(icon: Icons.person_add_rounded, label: 'New Leads', value: '${overview.newLeadsToday}', trend: 8.3, iconColor: AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: StatCard(icon: Icons.timer_rounded, label: 'Avg Response', value: '${overview.averageResponseTime.toStringAsFixed(1)}s', trend: -5.1, iconColor: AppColors.warning)),
        const SizedBox(width: 12),
        Expanded(child: StatCard(icon: Icons.sentiment_satisfied_rounded, label: 'Satisfaction', value: '${overview.customerSatisfaction.toStringAsFixed(0)}%', trend: 2.1, iconColor: AppColors.info)),
      ],
    );
  }

  Widget _buildCharts(AnalyticsProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Conversation Trend', style: AppTypography.headlineMedium),
                    const SizedBox(height: 20),
                    SizedBox(height: 250, child: _ConversationTrendChart(provider)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lead Funnel', style: AppTypography.headlineMedium),
                    const SizedBox(height: 20),
                    SizedBox(height: 250, child: _LeadFunnelChart(provider)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Response Time Distribution', style: AppTypography.headlineMedium),
                    const SizedBox(height: 20),
                    SizedBox(height: 200, child: _ResponseTimeChart(provider)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorder)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Model Usage', style: AppTypography.headlineMedium),
                    const SizedBox(height: 20),
                    SizedBox(height: 200, child: _ModelUsageChart(provider)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueTable(AnalyticsProvider provider) {
    final metrics = provider.metrics;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue Attribution', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),
          if (metrics == null)
            Text('No data available', style: AppTypography.bodyMedium)
          else
            Table(
              columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2)},
              children: [
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.dividerColor))),
                  children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text('Source', style: AppTypography.labelLarge)),
                    Padding(padding: const EdgeInsets.all(8), child: Text('Revenue', style: AppTypography.labelLarge)),
                    Padding(padding: const EdgeInsets.all(8), child: Text('Conversions', style: AppTypography.labelLarge)),
                  ],
                ),
                ...['WhatsApp', 'Website', 'Referral', 'Email'].map((source) => TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.dividerColor.withValues(alpha: 0.5)))),
                  children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text(source, style: AppTypography.bodyMedium)),
                    Padding(padding: const EdgeInsets.all(8), child: Text('\$${(source.length * 1500).toStringAsFixed(2)}', style: AppTypography.bodyMedium.copyWith(color: AppColors.success))),
                    Padding(padding: const EdgeInsets.all(8), child: Text('${source.length * 12}', style: AppTypography.bodyMedium)),
                  ],
                )),
              ],
            ),
        ],
      ),
    );
  }
}

class _ConversationTrendChart extends StatelessWidget {
  final AnalyticsProvider provider;
  const _ConversationTrendChart(this.provider);

  @override
  Widget build(BuildContext context) {
    final points = provider.metrics?.conversationTrend.points ?? [];
    if (points.isEmpty) {
      return Center(child: Text('No trend data', style: AppTypography.bodyMedium));
    }

    final spots = points.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
    final maxY = points.fold<double>(0, (m, p) => p.value > m ? p.value : m);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY > 0 ? maxY / 4 : 1, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.dividerColor, strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
            final idx = v.toInt();
            if (idx >= 0 && idx < points.length) {
              return Text('${points[idx].date.month}/${points[idx].date.day}', style: const TextStyle(color: AppColors.textMuted, fontSize: 9));
            }
            return const SizedBox();
          })),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots, isCurved: true, color: AppColors.chartLine1, barWidth: 2.5, isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 3, color: AppColors.chartLine1, strokeWidth: 2, strokeColor: AppColors.surfaceCard)),
            belowBarData: BarAreaData(show: true, color: AppColors.chartFill1),
          ),
        ],
        lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(getTooltipItems: (spots) => spots.map((s) => LineTooltipItem('${s.y.toInt()}', const TextStyle(color: Colors.white, fontSize: 11))).toList())),
      ),
    );
  }
}

class _LeadFunnelChart extends StatelessWidget {
  final AnalyticsProvider provider;
  const _LeadFunnelChart(this.provider);

  @override
  Widget build(BuildContext context) {
    final stages = provider.metrics?.leadFunnel ?? [];
    if (stages.isEmpty) {
      return Center(child: Text('No funnel data', style: AppTypography.bodyMedium));
    }

    final maxCount = stages.fold<int>(0, (m, s) => s.count > m ? s.count : m);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: stages.map((stage) {
        final ratio = maxCount > 0 ? stage.count / maxCount : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 80, child: Text(stage.label, style: AppTypography.bodySmall)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: ratio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text('${stage.count}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${stage.conversionRate.toStringAsFixed(0)}%', style: AppTypography.bodySmall),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ResponseTimeChart extends StatelessWidget {
  final AnalyticsProvider provider;
  const _ResponseTimeChart(this.provider);

  @override
  Widget build(BuildContext context) {
    final points = provider.metrics?.responseTimeDistribution ?? [];
    if (points.isEmpty) {
      return Center(child: Text('No data', style: AppTypography.bodyMedium));
    }

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.dividerColor, strokeWidth: 1)),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('${v.toInt()}s', style: const TextStyle(color: AppColors.textMuted, fontSize: 9)))),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: points.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value, color: AppColors.chartLine2, width: 12, borderRadius: BorderRadius.circular(4))])).toList(),
      ),
    );
  }
}

class _ModelUsageChart extends StatelessWidget {
  final AnalyticsProvider provider;
  const _ModelUsageChart(this.provider);

  @override
  Widget build(BuildContext context) {
    final usage = provider.metrics?.modelUsage ?? {};
    if (usage.isEmpty) {
      return Center(child: Text('No data', style: AppTypography.bodyMedium));
    }

    final total = usage.values.fold<double>(0, (s, v) => s + v);
    final colors = AppColors.chartColors;

    return PieChart(
      PieChartData(
        sections: usage.entries.toList().asMap().entries.map((e) => PieChartSectionData(
          value: e.value.value,
          color: colors[e.key % colors.length],
          title: '${(e.value.value / total * 100).toStringAsFixed(0)}%',
          radius: 35,
          titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
        )).toList(),
        centerSpaceRadius: 20,
        sectionsSpace: 2,
      ),
    );
  }
}
