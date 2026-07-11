import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/stat_card.dart';
import '../../providers/campaign_provider.dart';
import '../../models/campaign.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CampaignProvider>().loadCampaigns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CampaignProvider>();
    final campaigns = provider.campaigns;

    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        children: [
          _buildHeader(provider, campaigns),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : campaigns.isEmpty
                    ? const EmptyState(icon: Icons.campaign_rounded, title: 'No campaigns yet', subtitle: 'Create your first broadcast campaign', actionLabel: 'Create Campaign')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: campaigns.length,
                        itemBuilder: (context, index) => _buildCampaignCard(context, provider, campaigns[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(CampaignProvider provider, List campaigns) {
    final totalSent = campaigns.fold<int>(0, (s, c) => s + (c.sentCount as int));
    final totalDelivered = campaigns.fold<int>(0, (s, c) => s + (c.deliveredCount as int));

    return Container(
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
                    Text('Campaigns', style: AppTypography.displaySmall),
                    const SizedBox(height: 4),
                    Text('Manage broadcast and drip campaigns', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              AppButton(
                label: 'Create Campaign',
                icon: Icons.add,
                onPressed: () => _showCampaignDialog(context, provider, null),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatCard(icon: Icons.campaign_rounded, label: 'Total Campaigns', value: '${campaigns.length}', iconColor: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.send_rounded, label: 'Total Sent', value: '$totalSent', iconColor: AppColors.info)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.done_all_rounded, label: 'Delivered', value: '$totalDelivered', iconColor: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.visibility_rounded, label: 'Read Rate', value: totalDelivered > 0 ? '${(campaigns.fold<int>(0, (s, c) => s + (c.readCount as int)) / totalDelivered * 100).toStringAsFixed(1)}%' : '0%', iconColor: AppColors.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, CampaignProvider provider, Campaign campaign) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Icon(Icons.campaign_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campaign.name, style: AppTypography.headlineSmall),
                    if (campaign.message != null)
                      Text(campaign.message!, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              _badge(campaign.typeLabel, AppColors.info),
              const SizedBox(width: 8),
              _badge(campaign.statusLabel, campaign.status == 'completed' || campaign.status == 'sent' ? AppColors.success : campaign.status == 'failed' ? AppColors.error : campaign.status == 'scheduled' ? AppColors.warning : AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _progressStat('Sent', campaign.sentCount, campaign.totalRecipients),
              const SizedBox(width: 24),
              _progressStat('Delivered', campaign.deliveredCount, campaign.totalRecipients),
              const SizedBox(width: 24),
              _progressStat('Read', campaign.readCount, campaign.totalRecipients),
              const SizedBox(width: 24),
              _progressStat('Failed', campaign.failedCount, campaign.totalRecipients),
              const Spacer(),
              if (campaign.scheduledAt != null)
                Text('Scheduled: ${campaign.scheduledAt!.toString().split('.')[0]}', style: AppTypography.bodySmall),
              if (campaign.status == 'draft' || campaign.status == 'paused') ...[
                const SizedBox(width: 12),
                AppButton(
                  label: 'Send',
                  icon: Icons.send_rounded,
                  onPressed: () => provider.sendCampaign(campaign.id),
                ),
              ],
              if (campaign.status == 'sending' || campaign.status == 'scheduled') ...[
                const SizedBox(width: 12),
                AppButton(
                  label: 'Pause',
                  variant: AppButtonVariant.outline,
                  onPressed: () => provider.pauseCampaign(campaign.id),
                ),
              ],
              if (campaign.status != 'completed' && campaign.status != 'failed') ...[
                const SizedBox(width: 8),
                AppButton(
                  label: 'Edit',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => _showCampaignDialog(context, provider, campaign),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressStat(String label, int count, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$count', style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  void _showCampaignDialog(BuildContext context, CampaignProvider provider, Campaign? campaign) {
    final nameCtrl = TextEditingController(text: campaign?.name ?? '');
    final msgCtrl = TextEditingController(text: campaign?.message ?? '');
    String type = campaign?.type ?? 'broadcast';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(campaign != null ? 'Edit Campaign' : 'Create Campaign', style: AppTypography.displaySmall),
              const SizedBox(height: 20),
              AppTextField(label: 'Name *', hint: 'Campaign name', controller: nameCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Message *', hint: 'WhatsApp message content', controller: msgCtrl, maxLines: 4),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Type', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.inputBorder)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: type,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceCard,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: ['broadcast', 'drip', 'triggered'].map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
                        onChanged: (v) => setState(() => type = v!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(label: 'Cancel', variant: AppButtonVariant.ghost, onPressed: () => Navigator.pop(ctx)),
                  const SizedBox(width: 12),
                  AppButton(label: campaign != null ? 'Update' : 'Create', onPressed: () {
                    if (nameCtrl.text.isNotEmpty && msgCtrl.text.isNotEmpty) {
                      final data = <String, dynamic>{
                        'name': nameCtrl.text,
                        'message': msgCtrl.text,
                        'type': type,
                      };
                      if (campaign != null) {
                        provider.updateCampaign(campaign.id, data);
                      } else {
                        provider.createCampaign(data);
                      }
                      Navigator.pop(ctx);
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
