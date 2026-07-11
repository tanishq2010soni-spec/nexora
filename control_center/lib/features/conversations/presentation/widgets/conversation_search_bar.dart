import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ConversationSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final String? hintText;

  const ConversationSearchBar({
    super.key,
    required this.onSearch,
    this.hintText,
  });

  @override
  State<ConversationSearchBar> createState() => _ConversationSearchBarState();
}

class _ConversationSearchBarState extends State<ConversationSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _hasText = value.isNotEmpty);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        widget.onSearch(value);
      }
    });
  }

  void _clear() {
    _controller.clear();
    setState(() => _hasText = false);
    _debounceTimer?.cancel();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search conversations...',
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
