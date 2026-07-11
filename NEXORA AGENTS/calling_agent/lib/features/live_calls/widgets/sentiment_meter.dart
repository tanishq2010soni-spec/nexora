import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SentimentMeter extends StatelessWidget {
  final double sentiment;
  final double size;

  const SentimentMeter({
    super.key,
    required this.sentiment,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _SentimentPainter(sentiment: sentiment),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                sentiment >= 0.6 ? Icons.sentiment_satisfied : sentiment >= 0.3 ? Icons.sentiment_neutral : Icons.sentiment_dissatisfied,
                color: _getColor(),
                size: size * 0.3,
              ),
              Text(
                '${(sentiment * 100).toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.w700,
                  color: _getColor(),
                ),
              ),
              Text(
                'Sentiment',
                style: TextStyle(
                  fontSize: size * 0.08,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    if (sentiment >= 0.6) return AppColors.success;
    if (sentiment >= 0.3) return AppColors.warning;
    return AppColors.error;
  }
}

class _SentimentPainter extends CustomPainter {
  final double sentiment;

  _SentimentPainter({required this.sentiment});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, bgPaint);

    final fillPaint = Paint()
      ..color = sentiment >= 0.6 ? AppColors.success : sentiment >= 0.3 ? AppColors.warning : AppColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.28319 * sentiment,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SentimentPainter oldDelegate) {
    return oldDelegate.sentiment != sentiment;
  }
}
