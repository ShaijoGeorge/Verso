import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom circular progress indicator - replaces DashedCircularProgressBar dependency.
///
/// ```dart
/// VersoCircularProgress(
///   progress: 65.0,
///   maxProgress: 100.0,
///   size: 220,
///   strokeWidth: 15,
///   child: Text('65%'),
/// )
/// ```
class VersoCircularProgress extends StatelessWidget {
  const VersoCircularProgress({
    required this.progress,
    super.key,
    this.maxProgress = 100,
    this.size = 220,
    this.strokeWidth = 15,
    this.color,
    this.trackColor,
    this.child,
  });

  /// Current progress value.
  final double progress;

  /// Maximum progress value. Defaults to 100.
  final double maxProgress;

  /// Diameter of the circle.
  final double size;

  /// Width of the progress stroke.
  final double strokeWidth;

  /// Override the progress color. Defaults to [ColorScheme.primary].
  final Color? color;

  /// Override the track color. Defaults to [ColorScheme.surfaceContainerHighest].
  final Color? trackColor;

  /// Widget displayed in the center of the circle.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: progress,
          maxProgress: maxProgress,
          strokeWidth: strokeWidth,
          progressColor: color ?? scheme.primary,
          trackColor: trackColor ?? scheme.surfaceContainerHighest,
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.maxProgress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });
  final double progress;
  final double maxProgress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final sweepAngle = (progress / maxProgress) * 2 * math.pi;
    const startAngle = -math.pi / 2; // Start from top

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.maxProgress != maxProgress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
