import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isCompact;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isCompact = false,
    this.icon,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final child = _buildChild();
    final enabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: SizedBox(
        height: widget.isCompact ? 32 : 36,
        child: switch (widget.variant) {
          AppButtonVariant.primary => ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isHovered
                  ? AppColors.accentHover
                  : AppColors.accent,
              foregroundColor: AppColors.textInverse,
              elevation: _isHovered ? 2 : 0,
              shadowColor: AppColors.accent.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: child,
          ),
          AppButtonVariant.secondary => OutlinedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(
                color: _isHovered
                    ? AppColors.surfaceBorderLight
                    : AppColors.surfaceBorder,
              ),
              backgroundColor: _isHovered
                  ? AppColors.surfaceHover
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: child,
          ),
          AppButtonVariant.ghost => TextButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: TextButton.styleFrom(
              foregroundColor: _isHovered
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              backgroundColor: _isHovered
                  ? AppColors.surfaceHover
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: child,
          ),
          AppButtonVariant.danger => ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isLoading
                  ? AppColors.error.withValues(alpha: 0.7)
                  : _isHovered
                  ? AppColors.error.withValues(alpha: 0.85)
                  : AppColors.error,
              foregroundColor: AppColors.textInverse,
              elevation: _isHovered ? 2 : 0,
              shadowColor: AppColors.error.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: child,
          ),
        },
      ),
    );
  }

  Widget _buildChild() {
    if (widget.isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 16),
          const SizedBox(width: 6),
          Text(widget.label),
        ],
      );
    }
    return Text(widget.label);
  }
}
