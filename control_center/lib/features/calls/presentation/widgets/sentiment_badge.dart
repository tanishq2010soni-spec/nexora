import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/call.dart';

class SentimentBadge extends StatelessWidget {
  final CallSentiment? sentiment;
  final bool compact;

  const SentimentBadge({
    super.key,
    required this.sentiment,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = _getSentimentData();

    if (compact) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 12, color: color),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }

  (Color, String, IconData) _getSentimentData() {
    return switch (sentiment) {
      CallSentiment.positive => (
        AppColors.success,
        'Positive',
        Icons.sentiment_satisfied_alt,
      ),
      CallSentiment.neutral => (
        AppColors.info,
        'Neutral',
        Icons.sentiment_neutral,
      ),
      CallSentiment.negative => (
        AppColors.error,
        'Negative',
        Icons.sentiment_dissatisfied,
      ),
      null => (AppColors.textTertiary, 'Unknown', Icons.help_outline),
    };
  }
}
