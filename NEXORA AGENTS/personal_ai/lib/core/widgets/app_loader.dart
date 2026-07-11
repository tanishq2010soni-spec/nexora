import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const AppLoader({super.key, this.size = 32, this.color, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: color ?? AppColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _ShimmerPainter extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerPainter({
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  State<_ShimmerPainter> createState() => _ShimmerPainterState();
}

class _ShimmerPainterState extends State<_ShimmerPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                AppColors.surfaceBorder,
                Color(0xFF3a3a50),
                AppColors.surfaceBorder,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return _ShimmerPainter(width: width, height: height, borderRadius: borderRadius);
  }
}

class ListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ListShimmer({super.key, this.itemCount = 5, this.itemHeight = 72});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Container(
            height: itemHeight,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                const ShimmerLoader(width: 40, height: 40, borderRadius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ShimmerLoader(width: 140, height: 14),
                      const SizedBox(height: 8),
                      ShimmerLoader(width: 200 + (index * 15) % 60, height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardShimmer extends StatelessWidget {
  final double width;
  final double height;

  const CardShimmer({super.key, this.width = double.infinity, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoader(width: 160, height: 14),
          SizedBox(height: 12),
          ShimmerLoader(width: double.infinity, height: 10),
          SizedBox(height: 8),
          ShimmerLoader(width: 200, height: 10),
          SizedBox(height: 16),
          Row(
            children: [
              ShimmerLoader(width: 80, height: 10),
              SizedBox(width: 16),
              ShimmerLoader(width: 60, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
