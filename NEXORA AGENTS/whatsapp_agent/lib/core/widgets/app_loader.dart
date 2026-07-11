import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final String? message;

  const AppLoader({super.key, this.size = 32, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PageLoader extends StatelessWidget {
  final String? message;

  const PageLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AppLoader(message: message),
    );
  }
}

class LoadOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const AppLoader(),
          ),
      ],
    );
  }
}
