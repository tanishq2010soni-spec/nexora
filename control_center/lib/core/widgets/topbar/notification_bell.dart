import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../../features/notifications/providers/notifications_provider.dart';

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return unreadCountAsync.when(
      loading: () => const SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          icon: Icon(Icons.notifications_outlined, size: 20),
          onPressed: null,
          color: AppColors.textSecondary,
        ),
      ),
      error: (_, _) => const SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          icon: Icon(Icons.notifications_outlined, size: 20),
          onPressed: null,
          color: AppColors.textSecondary,
        ),
      ),
      data: (count) => Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () {},
            color: AppColors.textSecondary,
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
