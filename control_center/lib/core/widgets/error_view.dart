import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';
import 'app_motion.dart';

class ErrorView extends StatelessWidget {
  final Object exception;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.exception, this.onRetry});

  String _resolveMessage() {
    if (exception is AppException) return (exception as AppException).message;
    if (exception is DioException) {
      return ErrorHandler.fromDio(exception as DioException).message;
    }
    final msg = exception.toString();
    if (msg.contains('Exception: ')) {
      return msg.split('Exception: ').last;
    }
    if (msg.length > 120) {
      return 'An unexpected error occurred. Please try again.';
    }
    return msg;
  }

  IconData _resolveIcon() {
    if (exception is NetworkException || exception is TimeoutException) {
      return Icons.wifi_off_outlined;
    }
    if (exception is AuthException) return Icons.lock_outlined;
    if (exception is ServerException) return Icons.cloud_off_outlined;
    return Icons.error_outline;
  }

  bool get _isNotFound {
    if (exception is ServerException) {
      return (exception as ServerException).statusCode == 404;
    }
    if (exception is DioException) {
      return (exception as DioException).response?.statusCode == 404;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final message = _resolveMessage();
    final icon = _resolveIcon();

    return Center(
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                _isNotFound ? 'Not Found' : 'Something went wrong',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                AppButton(label: 'Retry', onPressed: onRetry),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
