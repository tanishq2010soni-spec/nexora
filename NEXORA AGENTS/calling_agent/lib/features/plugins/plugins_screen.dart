import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class PluginsScreen extends StatelessWidget {
  const PluginsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plugins = [
      {'name': 'CRM Sync', 'desc': 'Sync contacts with external CRM', 'version': '1.2.0', 'enabled': true, 'author': 'Nexora'},
      {'name': 'Webhook Notifier', 'desc': 'Send call events via webhooks', 'version': '2.0.1', 'enabled': true, 'author': 'Nexora'},
      {'name': 'Calendar Integration', 'desc': 'Connect to Google/Outlook Calendar', 'version': '1.0.0', 'enabled': false, 'author': 'Community'},
      {'name': 'SMS Gateway', 'desc': 'Send SMS notifications', 'version': '0.9.0', 'enabled': false, 'author': 'Community'},
      {'name': 'Sentiment Analysis', 'desc': 'Enhanced emotion detection', 'version': '3.1.0', 'enabled': true, 'author': 'Nexora'},
    ];

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plugins', style: AppTypography.displayMedium),
            const SizedBox(height: 24),
            ...plugins.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (p['enabled'] as bool ? AppColors.primary : AppColors.textMuted).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.extension, color: p['enabled'] as bool ? AppColors.primary : AppColors.textMuted, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(p['name'] as String, style: AppTypography.titleMedium),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('v${p['version']}', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            ),
                          ],
                        ),
                        Text(p['desc'] as String, style: AppTypography.bodySmall),
                        Text('by ${p['author']}', style: AppTypography.caption),
                      ],
                    ),
                  ),
                  Switch(
                    value: p['enabled'] as bool,
                    onChanged: (_) {},
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
