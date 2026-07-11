import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class WhisperInput extends StatefulWidget {
  final void Function(String message) onSend;

  const WhisperInput({super.key, required this.onSend});

  @override
  State<WhisperInput> createState() => _WhisperInputState();
}

class _WhisperInputState extends State<WhisperInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.headphones, size: 16, color: AppColors.warning),
              const SizedBox(width: 8),
              Text('Whisper Coaching', style: AppTypography.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Message will be spoken to the agent only (not the caller)',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Type a coaching message...',
                    hintStyle: AppTypography.bodySmall,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    widget.onSend(_controller.text);
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
