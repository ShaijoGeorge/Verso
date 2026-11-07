import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/utils/app_error_handler.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    required this.error,
    super.key,
    this.onRetry,
  });
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = AppErrorHandler.getMessage(error);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.error.withValues(alpha: 0.1),
                border: Border.all(
                  color: scheme.error.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: scheme.error,
              ),
            ),
            const Gap(20),
            Text(
              'Something went wrong',
              style: textTheme.headlineSmall?.copyWith(
                color: scheme.onSurface,
              ),
            ),
            const Gap(8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const Gap(24),
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.borderRadiusFull,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
              ),
          ],
        ),
      ),
    );
  }
}
