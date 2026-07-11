import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CallControls extends StatelessWidget {
  final String callId;
  final bool isOnHold;
  final bool isMuted;
  final VoidCallback? onHoldToggle;
  final VoidCallback? onTransfer;
  final VoidCallback? onConference;
  final VoidCallback? onEndCall;
  final VoidCallback? onMuteToggle;

  const CallControls({
    super.key,
    this.callId = '',
    this.isOnHold = false,
    this.isMuted = false,
    this.onHoldToggle,
    this.onTransfer,
    this.onConference,
    this.onEndCall,
    this.onMuteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            icon: isOnHold ? Icons.play_circle_outline : Icons.pause_circle_outline,
            label: isOnHold ? 'Resume' : 'Hold',
            color: isOnHold ? AppColors.success : AppColors.holding,
            onTap: onHoldToggle,
          ),
          const SizedBox(width: 16),
          _ControlButton(
            icon: Icons.swap_horiz,
            label: 'Transfer',
            color: AppColors.info,
            onTap: onTransfer,
          ),
          const SizedBox(width: 16),
          _ControlButton(
            icon: Icons.group_add,
            label: 'Conference',
            color: AppColors.warning,
            onTap: onConference,
          ),
          const SizedBox(width: 16),
          _ControlButton(
            icon: Icons.call_end,
            label: 'End',
            color: AppColors.error,
            onTap: onEndCall,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
