import 'package:flutter/material.dart';
import 'package:verso/core/design/tokens/radii.dart';

/// A themed linear progress bar with animated fill and optional label.
///
/// ```dart
/// VersoProgressBar(value: 0.65, label: '65%')
/// ```
class VersoProgressBar extends StatelessWidget {
  const VersoProgressBar({
    required this.value,
    super.key,
    this.label,
    this.height = 8,
    this.color,
    this.trackColor,
    this.duration = const Duration(milliseconds: 600),
  });

  /// Progress value from 0.0 to 1.0.
  final double value;

  /// Optional label displayed to the right of the bar.
  final String? label;

  /// Bar height. Defaults to 8.
  final double height;

  /// Override the fill color. Defaults to [ColorScheme.primary].
  final Color? color;

  /// Override the track color. Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? trackColor;

  /// Animation duration. Set to [Duration.zero] to disable.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fillColor = color ?? scheme.primary;
    final bgColor = trackColor ?? scheme.surfaceContainerHighest;

    final bar = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadii.borderRadiusFull,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: animatedValue,
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: AppRadii.borderRadiusFull,
              ),
            ),
          ),
        );
      },
    );

    if (label == null) return bar;

    return Row(
      children: [
        Expanded(child: bar),
        const SizedBox(width: 8),
        Text(
          label!,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
