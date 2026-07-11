import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, text, danger }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final bool disabled;
  final bool fullWidth;
  final AppButtonSize size;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.disabled = false,
    this.fullWidth = false,
    this.size = AppButtonSize.md,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(_spinController);
    if (widget.loading) _spinController.repeat();
  }

  @override
  void didUpdateWidget(AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading && !oldWidget.loading) {
      _spinController.repeat();
    } else if (!widget.loading && oldWidget.loading) {
      _spinController.stop();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null && !widget.loading && !widget.disabled;

  double get _height {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 32;
      case AppButtonSize.md:
        return 40;
      case AppButtonSize.lg:
        return 48;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 20);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _buildChild();
    final width = widget.fullWidth ? double.infinity : null;

    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: SizedBox(
        height: _height,
        width: width,
        child: switch (widget.variant) {
          AppButtonVariant.primary => _buildPrimary(child),
          AppButtonVariant.secondary => _buildSecondary(child),
          AppButtonVariant.text => _buildText(child),
          AppButtonVariant.danger => _buildDanger(child),
        },
      ),
    );
  }

  Widget _buildPrimary(Widget child) {
    return ElevatedButton(
      onPressed: _enabled ? widget.onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isHovered ? AppColors.primaryVariant : AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: _isHovered ? 2 : 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: _padding,
      ),
      child: child,
    );
  }

  Widget _buildSecondary(Widget child) {
    return OutlinedButton(
      onPressed: _enabled ? widget.onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: _isHovered ? AppColors.primary : AppColors.surfaceBorder,
          width: 1.5,
        ),
        backgroundColor: _isHovered ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: _padding,
      ),
      child: child,
    );
  }

  Widget _buildText(Widget child) {
    return TextButton(
      onPressed: _enabled ? widget.onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: _isHovered ? AppColors.textPrimary : AppColors.textSecondary,
        backgroundColor: _isHovered ? AppColors.surfaceBorder.withValues(alpha: 0.3) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: _padding,
      ),
      child: child,
    );
  }

  Widget _buildDanger(Widget child) {
    return ElevatedButton(
      onPressed: _enabled ? widget.onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isHovered ? AppColors.error.withValues(alpha: 0.85) : AppColors.error,
        foregroundColor: Colors.white,
        elevation: _isHovered ? 2 : 0,
        shadowColor: AppColors.error.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: _padding,
      ),
      child: child,
    );
  }

  Widget _buildChild() {
    if (widget.loading) {
      return RotationTransition(
        turns: _spinAnimation,
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: widget.variant == AppButtonVariant.danger
                ? Colors.white
                : widget.variant == AppButtonVariant.secondary
                    ? AppColors.primary
                    : AppColors.textPrimary,
          ),
        ),
      );
    }
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Text(widget.label, style: AppTypography.label),
        ],
      );
    }
    return Text(widget.label, style: AppTypography.label);
  }
}
