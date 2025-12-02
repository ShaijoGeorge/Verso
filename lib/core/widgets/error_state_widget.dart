import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utils/app_error_handler.dart';

class ErrorStateWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key, 
    required this.error, 
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final message = AppErrorHandler.getMessage(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const Gap(16),
            Text(
              "Oops!",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(24),
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
              ),
          ],
        ),
      ),
    );
  }
}