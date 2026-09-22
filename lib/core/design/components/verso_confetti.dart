import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';

/// A rewarding, high-polish confetti celebration overlay.
///
/// Designed to celebrate meaningful milestones (such as the first read of the day)
/// without blocking user interaction (`IgnorePointer` ensures uninterrupted taps/scrolling).
class VersoConfetti {
  VersoConfetti._();

  /// Displays the celebratory confetti overlay and animated streak badge.
  static void show(
    BuildContext context, {
    int streak = 1,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    // Subtle tactile feedback on trigger
    HapticFeedback.mediumImpact();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ConfettiOverlayWidget(
        streak: streak,
        onComplete: () {
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _ConfettiOverlayWidget extends StatefulWidget {
  const _ConfettiOverlayWidget({
    required this.streak,
    required this.onComplete,
  });

  final int streak;
  final VoidCallback onComplete;

  @override
  State<_ConfettiOverlayWidget> createState() => _ConfettiOverlayWidgetState();
}

class _ConfettiOverlayWidgetState extends State<_ConfettiOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final _random = Random();

  static const _duration = Duration(milliseconds: 2800);

  // Curated celebration palette
  static const _palette = [
    Color(0xFFF59E0B), // Radiant Amber
    Color(0xFFFCD34D), // Golden Sparkle
    Color(0xFF10B981), // Emerald
    Color(0xFF34D399), // Mint Green
    Color(0xFF3B82F6), // Electric Blue
    Color(0xFF60A5FA), // Sky Accent
    Color(0xFFF43F5E), // Coral Rose
    Color(0xFF8B5CF6), // Royal Violet
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _particles = List.generate(70, (_) => _generateParticle());
    _controller.forward();
  }

  _Particle _generateParticle() {
    final shape = _ParticleShape.values[_random.nextInt(_ParticleShape.values.length)];
    final color = _palette[_random.nextInt(_palette.length)];
    final size = _random.nextDouble() * 7 + 5; // 5 to 12

    // Launch from top center with horizontal fan-out
    final startXPercent = 0.5 + (_random.nextDouble() - 0.5) * 0.7; // 15% to 85% width
    final initialVx = (_random.nextDouble() - 0.5) * 380; // -190 to +190 px/s
    final initialVy = _random.nextDouble() * 260 + 120; // 120 to 380 px/s downward
    final gravity = _random.nextDouble() * 200 + 450; // 450 to 650 px/s^2

    final rotationSpeed = (_random.nextDouble() - 0.5) * 12; // rad/s
    final flutterFreq = _random.nextDouble() * 4 + 2;
    final flutterAmp = _random.nextDouble() * 25 + 10;

    return _Particle(
      startXPercent: startXPercent,
      color: color,
      shape: shape,
      size: size,
      vx: initialVx,
      vy: initialVy,
      gravity: gravity,
      rotationSpeed: rotationSpeed,
      flutterFreq: flutterFreq,
      flutterAmp: flutterAmp,
      delayMs: _random.nextInt(350), // staggered launch
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // 1. Confetti canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (ctx, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                    totalDurationMs: _duration.inMilliseconds.toDouble(),
                  ),
                );
              },
            ),
          ),

          // 2. Floating Animated Streak Badge
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: _StreakCelebrationBadge(
                  controller: _controller,
                  streak: widget.streak,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCelebrationBadge extends StatelessWidget {
  const _StreakCelebrationBadge({
    required this.controller,
    required this.streak,
  });

  final AnimationController controller;
  final int streak;

  static (double, double, double) _calculateTransform(double t) {
    if (t < 0.15) {
      final entrance = Curves.easeOutBack.transform(t / 0.15);
      return (
        (t / 0.15).clamp(0, 1),
        (1 - entrance) * -30,
        0.85 + 0.15 * entrance,
      );
    } else if (t < 0.75) {
      return (1, 0, 1);
    } else if (t < 0.95) {
      final exit = (t - 0.75) / 0.2;
      return (
        (1 - exit).clamp(0, 1),
        -15 * exit,
        1 - 0.05 * exit,
      );
    }
    return (0, 0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final startVal = streak > 1 ? streak - 1 : 0;

    return AnimatedBuilder(
      animation: controller,
      builder: (ctx, child) {
        final t = controller.value;
        final (opacity, translateY, baseScale) = _calculateTransform(t);
        if (opacity <= 0) return const SizedBox.shrink();

        // Punch scale bounce when counting reaches destination (between 0.35 and 0.50)
        var popScale = 1.0;
        if (t >= 0.35 && t <= 0.50) {
          final popT = (t - 0.35) / 0.15;
          popScale = 1.0 + 0.18 * sin(popT * pi);
        }

        final combinedScale = baseScale * popScale;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              scale: combinedScale,
              child: child,
            ),
          ),
        );
      },
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (ctx, _) {
            final t = controller.value;
            final countT = Curves.easeOutCubic.transform((t / 0.35).clamp(0, 1));
            final currentDisplay =
                (startVal + (streak - startVal) * countT).round();

            return Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.94)
                      : Colors.white.withValues(alpha: 0.96),
                  borderRadius: AppRadii.borderRadiusFull,
                  border: Border.all(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fiery Flame Icon with pulsating glow
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF3D00),
                            Color(0xFFFF9100),
                            Color(0xFFFFC400),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9100).withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          size: 26,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Animated Number and Day Streak Badge
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$currentDisplay',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                decoration: TextDecoration.none,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              streak == 1 ? 'DAY' : 'DAYS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF59E0B),
                                decoration: TextDecoration.none,
                                letterSpacing: 1.2,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'STREAK ACTIVE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            decoration: TextDecoration.none,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _ParticleShape { rectangle, circle, diamond, star }

class _Particle {
  _Particle({
    required this.startXPercent,
    required this.color,
    required this.shape,
    required this.size,
    required this.vx,
    required this.vy,
    required this.gravity,
    required this.rotationSpeed,
    required this.flutterFreq,
    required this.flutterAmp,
    required this.delayMs,
  });

  final double startXPercent;
  final Color color;
  final _ParticleShape shape;
  final double size;
  final double vx;
  final double vy;
  final double gravity;
  final double rotationSpeed;
  final double flutterFreq;
  final double flutterAmp;
  final int delayMs;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.totalDurationMs,
  });

  final List<_Particle> particles;
  final double progress;
  final double totalDurationMs;

  @override
  void paint(Canvas canvas, Size size) {
    final currentMs = progress * totalDurationMs;

    for (final p in particles) {
      if (currentMs < p.delayMs) continue;

      final t = (currentMs - p.delayMs) / 1000.0; // time in seconds
      if (t < 0) continue;

      // Physics equation: y = vy * t + 0.5 * gravity * t^2
      final y = p.vy * t + 0.5 * p.gravity * t * t;
      // Fluttering x: x0 + vx * t + sin(freq * t) * amp
      final startX = size.width * p.startXPercent;
      final x = startX + p.vx * t + sin(p.flutterFreq * t) * p.flutterAmp;

      // Off-screen check
      if (y > size.height + 40) continue;

      // Fade out smoothly in the last 25% of lifetime
      final lifetimeProgress = progress;
      var alpha = 1.0;
      if (lifetimeProgress > 0.75) {
        alpha = ((1.0 - lifetimeProgress) / 0.25).clamp(0.0, 1.0);
      }

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      final angle = p.rotationSpeed * t;
      canvas.rotate(angle);

      switch (p.shape) {
        case _ParticleShape.rectangle:
          // Ribbon flutter effect by scaling X with sin
          final flutterScale = sin(t * p.flutterFreq * 1.5).abs().clamp(0.2, 1.0);
          canvas.scale(flutterScale, 1);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size * 1.5,
                height: p.size * 0.7,
              ),
              const Radius.circular(2),
            ),
            paint,
          );

        case _ParticleShape.circle:
          canvas.drawCircle(Offset.zero, p.size * 0.45, paint);

        case _ParticleShape.diamond:
          final path = Path()
            ..moveTo(0, -p.size * 0.6)
            ..lineTo(p.size * 0.45, 0)
            ..lineTo(0, p.size * 0.6)
            ..lineTo(-p.size * 0.45, 0)
            ..close();
          canvas.drawPath(path, paint);

        case _ParticleShape.star:
          _drawStar(canvas, p.size * 0.6, paint);
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    const points = 5;
    final innerRadius = radius * 0.45;
    const step = pi / points;

    for (var i = 0; i < 2 * points; i++) {
      final r = i.isEven ? radius : innerRadius;
      final a = i * step - pi / 2;
      final x = cos(a) * r;
      final y = sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
