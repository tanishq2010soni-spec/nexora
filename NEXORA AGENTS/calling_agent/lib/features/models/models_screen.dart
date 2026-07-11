import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Models', style: AppTypography.displayMedium),
            const SizedBox(height: 24),
            ..._buildModelCards(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildModelCards() {
    final models = [
      {'name': 'GPT-4', 'provider': 'OpenAI', 'type': 'LLM', 'status': 'Active', 'latency': '1.2s', 'cost': '\$0.03/call'},
      {'name': 'Claude 3', 'provider': 'Anthropic', 'type': 'LLM', 'status': 'Active', 'latency': '0.9s', 'cost': '\$0.025/call'},
      {'name': 'Whisper', 'provider': 'OpenAI', 'type': 'STT', 'status': 'Active', 'latency': '0.5s', 'cost': '\$0.006/min'},
      {'name': 'ElevenLabs', 'provider': 'ElevenLabs', 'type': 'TTS', 'status': 'Active', 'latency': '0.3s', 'cost': '\$0.001/char'},
      {'name': 'NeMo', 'provider': 'NVIDIA', 'type': 'VAD', 'status': 'Inactive', 'latency': '0.1s', 'cost': 'Free'},
    ];

    return models.map((m) => Container(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(m['name']!, style: AppTypography.titleMedium),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: m['status'] == 'Active' ? AppColors.success.withValues(alpha: 0.15) : AppColors.textMuted.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(m['status']!, style: TextStyle(fontSize: 10, color: m['status'] == 'Active' ? AppColors.success : AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Text('${m['provider']} | ${m['type']}', style: AppTypography.bodySmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Latency: ${m['latency']}', style: AppTypography.caption),
                    const SizedBox(width: 16),
                    Text('Cost: ${m['cost']}', style: AppTypography.caption),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: m['status'] == 'Active',
            onChanged: (_) {},
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    )).toList();
  }
}
