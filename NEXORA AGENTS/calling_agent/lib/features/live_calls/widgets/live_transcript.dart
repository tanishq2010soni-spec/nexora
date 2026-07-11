import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class LiveTranscript extends StatelessWidget {
  final List<TranscriptLine> lines;
  const LiveTranscript({super.key, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.activeCall,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Live Transcript', style: AppTypography.titleMedium),
              const Spacer(),
              Text('Streaming...', style: AppTypography.caption),
            ],
          ),
          const Divider(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final line = lines[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: line.isAi ? AppColors.primary.withValues(alpha: 0.2) : AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          line.isAi ? 'AI' : 'Human',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: line.isAi ? AppColors.primary : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          line.text,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TranscriptLine {
  final String text;
  final bool isAi;
  final DateTime timestamp;

  const TranscriptLine({
    required this.text,
    required this.isAi,
    required this.timestamp,
  });
}
