import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class LeadSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final String? hintText;

  const LeadSearchBar({super.key, required this.onSearch, this.hintText});

  @override
  State<LeadSearchBar> createState() => _LeadSearchBarState();
}

class _LeadSearchBarState extends State<LeadSearchBar> {
  late final TextEditingController _controller;
  String _debounceKey = '';
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _hasText = value.isNotEmpty);
    if (value == _debounceKey) return;
    _debounceKey = value;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_debounceKey == value && mounted) {
        widget.onSearch(value);
      }
    });
  }

  void _clear() {
    _controller.clear();
    setState(() => _hasText = false);
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search leads...',
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 18,
          color: AppColors.textTertiary,
        ),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                onPressed: _clear,
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}
