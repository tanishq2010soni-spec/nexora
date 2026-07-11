import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/stat_card.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/lead_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationProvider>().loadConversations();
      context.read<LeadProvider>().loadLeads();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationProvider = context.watch<ConversationProvider>();
    final leadProvider = context.watch<LeadProvider>();

    final activeConversations = conversationProvider.conversations
        .where((c) => c.status == 'active')
        .length;
    final newLeadsToday = leadProvider.leads.length;
    final unreadCount = conversationProvider.unreadCount;

    return Container(
      color: AppColors.scaffoldBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Overview of your WhatsApp AI Agent activity',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildStatCards(activeConversations, newLeadsToday, unreadCount),
            const SizedBox(height: 24),
            _buildCharts(context),
            const SizedBox(height: 24),
            _buildRecentConversations(context, conversationProvider),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(int activeConversations, int newLeadsToday, int unreadCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 48) / 4;
        return Row(
          children: [
            SizedBox(
              width: width,
              child: StatCard(
                icon: Icons.chat_rounded,
                label: 'Active Conversations',
                value: '$activeConversations',
                trend: 12.5,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: width,
              child: StatCard(
                icon: Icons.person_add_rounded,
                label: 'New Leads Today',
                value: '$newLeadsToday',
                trend: 8.3,
                iconColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: width,
              child: StatCard(
                icon: Icons.timer_rounded,
                label: 'Avg Response Time',
                value: '1.2m',
                trend: -5.1,
                iconColor: AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: width,
              child: StatCard(
                icon: Icons.sentiment_satisfied_rounded,
                label: 'Customer Satisfaction',
                value: '94%',
                trend: 2.1,
                iconColor: AppColors.info,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCharts(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conversation Trends', style: AppTypography.headlineMedium),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _ConversationTrendChart(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lead Sources', style: AppTypography.headlineMedium),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _LeadSourceChart(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentConversations(BuildContext context, ConversationProvider provider) {
    final recent = provider.conversations.take(5).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Recent Conversations', style: AppTypography.headlineMedium),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/inbox'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No conversations yet',
                  style: AppTypography.bodyMedium,
                ),
              ),
            )
          else
            ...recent.map((conv) => _buildConversationRow(conv)),
        ],
      ),
    );
  }

  Widget _buildConversationRow(dynamic conv) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              conv.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conv.displayName,
                  style: AppTypography.titleMedium,
                ),
                if (conv.lastMessage != null)
                  Text(
                    conv.lastMessage,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            conv.lastMessageTime,
            style: AppTypography.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTypography.headlineMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              _QuickActionButton(
                icon: Icons.campaign_rounded,
                label: 'New Broadcast',
                color: AppColors.primary,
                onTap: () => context.go('/campaigns'),
              ),
              const SizedBox(width: 12),
              _QuickActionButton(
                icon: Icons.forum_rounded,
                label: 'View Inbox',
                color: AppColors.secondary,
                onTap: () => context.go('/inbox'),
              ),
              const SizedBox(width: 12),
              _QuickActionButton(
                icon: Icons.person_add_rounded,
                label: 'Create Lead',
                color: AppColors.success,
                onTap: () => context.go('/crm'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConversationTrendChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [5, 8, 12, 7, 15, 10, 18];
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.dividerColor,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 25,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].toDouble())),
            isCurved: true,
            color: AppColors.chartLine1,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.chartLine1,
                strokeWidth: 2,
                strokeColor: AppColors.surfaceCard,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.chartFill1,
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) =>
              LineTooltipItem(
                '${spot.y.toInt()} convos',
                const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ).toList(),
          ),
        ),
      ),
    );
  }
}

class _LeadSourceChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [
      PieChartSectionData(value: 40, color: AppColors.chartLine1, title: 'WhatsApp', radius: 35, titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
      PieChartSectionData(value: 25, color: AppColors.chartLine2, title: 'Website', radius: 35, titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
      PieChartSectionData(value: 20, color: AppColors.chartLine3, title: 'Referral', radius: 35, titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
      PieChartSectionData(value: 15, color: AppColors.warning, title: 'Other', radius: 35, titleStyle: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
    ];
    return PieChart(
      PieChartData(
        sections: data,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(enabled: false),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 8),
                Text(label, style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
