import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ChannelIcon extends StatelessWidget {
  final String channel;
  final double size;

  const ChannelIcon({super.key, required this.channel, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 12,
      height: size + 12,
      decoration: BoxDecoration(
        color: _channelColor.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_channelIcon, size: size, color: _channelColor),
    );
  }

  Color get _channelColor {
    return switch (channel) {
      'whatsapp' => const Color(0xFF25D366),
      'instagram' => const Color(0xFFE4405F),
      'facebook' => const Color(0xFF1877F2),
      'website' => AppColors.accent,
      _ => AppColors.textTertiary,
    };
  }

  IconData get _channelIcon {
    return switch (channel) {
      'whatsapp' => Icons.chat_outlined,
      'instagram' => Icons.camera_alt_outlined,
      'facebook' => Icons.facebook_outlined,
      'website' => Icons.language_outlined,
      _ => Icons.chat_bubble_outline,
    };
  }
}
