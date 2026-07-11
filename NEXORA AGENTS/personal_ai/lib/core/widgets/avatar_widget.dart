import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AvatarWidget extends StatelessWidget {
  final String initials;
  final bool online;
  final double size;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    required this.initials,
    this.online = false,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.primary,
              borderRadius: BorderRadius.circular(size / 2),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.length > 2 ? initials.substring(0, 2).toUpperCase() : initials.toUpperCase(),
              style: AppTypography.label.copyWith(
                color: AppColors.textPrimary,
                fontSize: size * 0.35,
              ),
            ),
          ),
          if (online)
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBackground, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
