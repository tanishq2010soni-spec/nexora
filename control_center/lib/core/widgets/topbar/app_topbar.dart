import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../search/command_palette.dart';
import 'notification_bell.dart';

class AppTopBar extends StatelessWidget {
  final String title;

  const AppTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 800;

    return Container(
      height: AppSpacing.topbarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : AppSpacing.pageHorizontal,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isCompact ? 16 : 20,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (!isCompact) ...[
            _buildSearchTrigger(context),
            const SizedBox(width: 16),
          ] else
            IconButton(
              icon: const Icon(
                Icons.search,
                size: 20,
                color: AppColors.textTertiary,
              ),
              onPressed: () => CommandPalette.show(context, []),
            ),
          const NotificationBell(),
        ],
      ),
    );
  }

  Widget _buildSearchTrigger(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () => CommandPalette.show(context, []),
          child: Container(
            width: constraints.maxWidth > 600 ? 280 : 200,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Search...',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHover,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.surfaceBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'Ctrl+K',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
