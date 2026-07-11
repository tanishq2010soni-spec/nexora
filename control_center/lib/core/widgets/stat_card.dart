import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_motion.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? trendColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.trendColor,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.surfaceHover : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? AppColors.surfaceBorderLight
                : AppColors.surfaceBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.title,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (widget.icon != null)
                  Icon(widget.icon, size: 16, color: AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.value,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  widget.subtitle!,
                  style: AppTypography.labelSmall.copyWith(
                    color: widget.trendColor ?? AppColors.textTertiary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AnimatedStatCard extends StatelessWidget {
  final String title;
  final int value;
  final String? subtitle;
  final IconData? icon;
  final Color? trendColor;

  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return SlideFadeIn(
      child: StatCard(
        title: title,
        value: value.toString(),
        subtitle: subtitle,
        icon: icon,
        trendColor: trendColor,
      ),
    );
  }
}
