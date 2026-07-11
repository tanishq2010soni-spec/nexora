import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/stat_card.dart';
import 'widgets/campaign_card.dart';
import 'widgets/campaign_form.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  int? _selectedIndex;

  final _mockCampaigns = [
    {'name': 'Q3 Outreach', 'type': 'Outbound', 'status': 'Active', 'total': '500', 'answered': '342', 'converted': '85', 'cost': '450.00'},
    {'name': 'Customer Support', 'type': 'Inbound', 'status': 'Active', 'total': '1200', 'answered': '980', 'converted': '620', 'cost': '1200.00'},
    {'name': 'Follow-up Q2', 'type': 'Follow-up', 'status': 'Paused', 'total': '300', 'answered': '210', 'converted': '95', 'cost': '320.00'},
    {'name': 'Satisfaction Survey', 'type': 'Survey', 'status': 'Completed', 'total': '800', 'answered': '650', 'converted': '0', 'cost': '280.00'},
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
              Text('Campaigns', style: AppTypography.displayMedium),
              const Spacer(),
              AppButton(
                label: 'Create Campaign',
                icon: Icons.add,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => CampaignForm(onSave: (data) {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              StatCard(label: 'Active', value: '2', icon: Icons.play_circle, iconColor: AppColors.success),
              StatCard(label: 'Total Leads', value: '2,800', icon: Icons.people, iconColor: AppColors.info),
              StatCard(label: 'Avg Conv Rate', value: '18.5%', icon: Icons.trending_up, iconColor: AppColors.warning),
              StatCard(label: 'Total Cost', value: '\$2,250', icon: Icons.attach_money, iconColor: AppColors.error),
            ],
          ),
          const SizedBox(height: 16),
          ..._mockCampaigns.asMap().entries.map((entry) {
            final c = entry.value;
            final idx = entry.key;
            return CampaignCard(
              name: c['name']!,
              type: c['type']!,
              status: c['status']!,
              total: int.parse(c['total']!),
              answered: int.parse(c['answered']!),
              converted: int.parse(c['converted']!),
              cost: double.parse(c['cost']!),
              onTap: () => setState(() => _selectedIndex = idx),
              onActivate: () {},
              onPause: () {},
              onDelete: () {},
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    final c = _mockCampaigns[_selectedIndex!];
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name']!, style: AppTypography.headlineLarge),
                    Text('${c['type']} Campaign', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              AppButton(label: 'Edit', icon: Icons.edit, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildPerfStat('Total Leads', c['total']!, Icons.people, AppColors.info),
              _buildPerfStat('Answered', c['answered']!, Icons.call_received, AppColors.success),
              _buildPerfStat('Converted', c['converted']!, Icons.check_circle, AppColors.accent),
              _buildPerfStat('Cost', '\$${c['cost']}', Icons.attach_money, AppColors.warning),
            ],
          ),
          const SizedBox(height: 24),
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
                    Text('Lead List', style: AppTypography.titleMedium),
                    const Spacer(),
                    AppButton(label: 'Add Leads', icon: Icons.add, onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('No leads assigned yet.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(label, style: AppTypography.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTypography.displayMedium),
          ],
        ),
      ),
    );
  }
}
