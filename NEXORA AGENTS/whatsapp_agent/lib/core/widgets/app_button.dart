import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final double? minWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 40.0;
    final style = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
        elevation: 0,
      ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.4),
        elevation: 0,
      ),
      AppButtonVariant.outline => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        disabledForegroundColor: AppColors.primary.withValues(alpha: 0.4),
      ),
      AppButtonVariant.text => TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.primary.withValues(alpha: 0.4),
      ),
      AppButtonVariant.danger => ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.error.withValues(alpha: 0.4),
        elevation: 0,
      ),
      AppButtonVariant.ghost => TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        disabledForegroundColor: AppColors.textMuted,
      ),
    };

    final child = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.outline ||
                        variant == AppButtonVariant.text ||
                        variant == AppButtonVariant.ghost
                    ? AppColors.primary
                    : AppColors.textOnPrimary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTypography.button),
            ],
          );

    final button = SizedBox(
      height: effectiveHeight,
      child: child is Row ? child : Center(child: child),
    );

    if (variant == AppButtonVariant.outline) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style.copyWith(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          ),
        ),
        child: button,
      );
    }

    if (variant == AppButtonVariant.text || variant == AppButtonVariant.ghost) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: style.copyWith(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(horizontal: icon != null ? 16 : 12, vertical: 0),
          ),
        ),
        child: button,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style.copyWith(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        ),
        minimumSize: WidgetStateProperty.all(
          isFullWidth ? Size(double.infinity, effectiveHeight) : Size(minWidth ?? 0, effectiveHeight),
        ),
      ),
      child: button,
    );
  }
}
