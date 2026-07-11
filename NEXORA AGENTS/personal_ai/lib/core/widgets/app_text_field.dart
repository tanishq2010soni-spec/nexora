import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  final String? hint;
  final String? label;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscure;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;

  const AppTextField({
    super.key,
    this.hint,
    this.label,
    this.prefix,
    this.suffix,
    this.obscure = false,
    this.maxLines = 1,
    this.onChanged,
    this.controller,
    this.validator,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _isHovered = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (_isFocused) return AppColors.primary;
    if (_isHovered) return AppColors.textTertiary;
    return AppColors.surfaceBorder;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
        ],
        MouseRegion(
          cursor: SystemMouseCursors.text,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            onChanged: widget.onChanged,
            obscureText: _obscured,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surface,
              prefixIcon: widget.prefix,
              suffixIcon: widget.suffix ??
                  (widget.obscure
                      ? IconButton(
                          icon: Icon(
                            _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () => setState(() => _obscured = !_obscured),
                        )
                      : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
