import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/core/models/app_error.dart';

/// Shows a styled snackbar for AppError errors.
void showErrorSnackBar(BuildContext context, dynamic error) {
  final appError = error is AppError
      ? error
      : AppError.from(error);

  final String displayMessage;
  final IconData icon;
  final Color backgroundColor;

  switch (appError.code) {
    case 'network_error':
    case 'socket_error':
    case 'timeout':
      displayMessage = 'Check your internet connection';
      icon = Icons.wifi_off_rounded;
      backgroundColor = Colors.orange.shade700;
      break;
    case 'not_found':
      displayMessage = 'Item not found';
      icon = Icons.search_off_rounded;
      backgroundColor = Colors.red.shade600;
      break;
    case 'auth_error':
    case 'invalid_credentials':
      displayMessage = appError.message;
      icon = Icons.lock_outline_rounded;
      backgroundColor = Colors.red.shade600;
      break;
    default:
      displayMessage = appError.message;
      icon = Icons.error_outline_rounded;
      backgroundColor = Colors.red.shade600;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayMessage,
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
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
