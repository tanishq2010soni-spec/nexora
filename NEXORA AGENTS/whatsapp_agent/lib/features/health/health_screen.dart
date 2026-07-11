import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/health_provider.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().startPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthProvider>();

    return Container(
      color: AppColors.scaffoldBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('System Health', style: AppTypography.displaySmall),
                          const SizedBox(width: 12),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: provider.isHealthy ? AppColors.success : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            provider.isHealthy ? 'All Systems Operational' : 'Issues Detected',
                            style: AppTypography.bodyMedium.copyWith(
                              color: provider.isHealthy ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => provider.loadHealth(),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('WhatsApp Accounts'),
                        const SizedBox(height: 12),
                        if (provider.accounts.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorder)),
                            child: Text('No WhatsApp accounts configured', style: AppTypography.bodyMedium),
                          )
                        else
                          ...provider.accounts.map((acc) => _buildAccountCard(acc)),
                        const SizedBox(height: 24),
                        _buildSectionTitle('System Components'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildComponentCard('Database', provider.databaseStatus ?? 'unknown', Icons.storage_rounded)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildComponentCard('AI Runtime', provider.aiRuntimeStatus ?? 'unknown', Icons.memory_rounded)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildComponentCard('Uptime', provider.uptimeHours != null ? '${provider.uptimeHours!.toStringAsFixed(1)}h' : 'N/A', Icons.timer_rounded)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Recent Errors'),
                        const SizedBox(height: 12),
                        if (provider.recentErrors.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorder)),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                                const SizedBox(width: 12),
                                Text('No recent errors', style: AppTypography.bodyMedium),
                              ],
                            ),
                          )
                        else
                          ...provider.recentErrors.map((err) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                                const SizedBox(width: 12),
                                Expanded(child: Text('${err['message'] ?? 'Unknown error'}', style: AppTypography.bodyMedium)),
                                Text('${err['timestamp'] ?? ''}', style: AppTypography.bodySmall),
                              ],
                            ),
                          )),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.headlineMedium);
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final status = (account['status'] as String?) ?? 'disconnected';
    final isConnected = status == 'connected';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isConnected ? AppColors.success : AppColors.textMuted).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.phone_android_rounded,
              size: 20,
              color: isConnected ? AppColors.success : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account['phone_number'] as String? ?? 'Unknown', style: AppTypography.titleMedium),
                Text(account['name'] as String? ?? '', style: AppTypography.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isConnected ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(
                color: isConnected ? AppColors.success : AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentCard(String label, String status, IconData icon) {
    final isOk = status == 'healthy' || status == 'ok' || status == 'connected';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: isOk ? AppColors.success : AppColors.error),
          const SizedBox(height: 12),
          Text(label, style: AppTypography.titleMedium),
          const SizedBox(height: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: AppTypography.bodyMedium.copyWith(
              color: isOk ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
