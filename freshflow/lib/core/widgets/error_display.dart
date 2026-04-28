import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/core/utils/app_exception.dart';

/// Shows a styled snackbar for AppException errors.
void showErrorSnackBar(BuildContext context, dynamic error) {
  final appError = error is AppException
      ? error
      : AppException.fromError(error);

  final icon = switch (appError.type) {
    ErrorType.network => Icons.wifi_off_rounded,
    ErrorType.auth => Icons.lock_outline_rounded,
    ErrorType.server => Icons.cloud_off_rounded,
    ErrorType.validation => Icons.warning_amber_rounded,
    ErrorType.notFound => Icons.search_off_rounded,
    ErrorType.unknown => Icons.error_outline_rounded,
  };

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              appError.displayMessage,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: appError.type == ErrorType.network
          ? Colors.orange.shade700
          : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ),
  );
}

/// Inline error widget for empty/error states.
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
