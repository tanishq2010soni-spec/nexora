import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Health', style: AppTypography.displayMedium),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildHealthCard('Phone Providers', 'Connected', Icons.phone, AppColors.success, '2 providers online'),
                _buildHealthCard('Voice Pipeline', 'Operational', Icons.mic, AppColors.success, 'STT/TTS/VAD ready'),
                _buildHealthCard('Database', 'Connected', Icons.storage, AppColors.success, 'PostgreSQL 15'),
                _buildHealthCard('API Server', 'Online', Icons.cloud, AppColors.success, 'localhost:8200'),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Metrics', style: AppTypography.titleMedium),
                  const SizedBox(height: 16),
                  _buildMetricRow('Active Calls', '12', AppColors.activeCall),
                  _buildMetricRow('Queue Depth', '4', AppColors.warning),
                  _buildMetricRow('Uptime', '14d 7h 32m', AppColors.success),
                  _buildMetricRow('Memory Usage', '1.2 GB / 4 GB', AppColors.info),
                  _buildMetricRow('CPU Load', '34%', AppColors.success),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(String title, String status, IconData icon, Color statusColor, String subtitle) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(20),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: statusColor, size: 20),
                ),
                const Spacer(),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(status, style: AppTypography.headlineMedium),
            const SizedBox(height: 4),
            Text(title, style: AppTypography.bodySmall),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          Text(value, style: AppTypography.titleMedium),
        ],
      ),
    );
  }
}
