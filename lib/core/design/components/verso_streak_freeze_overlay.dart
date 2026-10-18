import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';

enum FreezeOverlayMode { streakSaved, freezeEarned, welcomeGift }

/// Celebratory ice crystal & shield animation overlay for Streak Freeze events.
class VersoStreakFreezeOverlay {
  VersoStreakFreezeOverlay._();

  /// Shows the "Streak Frozen / Saved!" animation when a missed day is covered.
  static void showSaved(
    BuildContext context, {
    required int streak,
    required int remainingFreezes,
  }) {
    _insertOverlay(
      context,
      mode: FreezeOverlayMode.streakSaved,
      value: streak,
      subValue: remainingFreezes,
    );
  }

  /// Shows the "+1 Streak Freeze Earned!" animation on a 30-day streak milestone.
  static void showEarned(
    BuildContext context, {
    required int freezesCount,
  }) {
    _insertOverlay(
      context,
      mode: FreezeOverlayMode.freezeEarned,
      value: freezesCount,
      subValue: 2,
    );
  }

  /// Shows the "Welcome Gift: Streak Freeze Equipped!" celebration overlay.
  /// Works for both new readers and existing users with an active streak.
  static void showWelcome(
    BuildContext context, {
    int streak = 0,
    int freezesCount = 1,
  }) {
    _insertOverlay(
      context,
      mode: FreezeOverlayMode.welcomeGift,
      value: streak,
      subValue: freezesCount,
    );
  }

  static void _insertOverlay(
    BuildContext context, {
    required FreezeOverlayMode mode,
    required int value,
    required int subValue,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    HapticFeedback.heavyImpact();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _StreakFreezeOverlayWidget(
        mode: mode,
        value: value,
        subValue: subValue,
        onComplete: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _StreakFreezeOverlayWidget extends StatefulWidget {
  const _StreakFreezeOverlayWidget({
    required this.mode,
    required this.value,
    required this.subValue,
    required this.onComplete,
  });

  final FreezeOverlayMode mode;
  final int value;
  final int subValue;
  final VoidCallback onComplete;

  @override
  State<_StreakFreezeOverlayWidget> createState() =>
      _StreakFreezeOverlayWidgetState();
}

class _StreakFreezeOverlayWidgetState extends State<_StreakFreezeOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_IceParticle> _particles;
  final _random = Random();

  static const _duration = Duration(milliseconds: 3200);

  static const _icePalette = [
    Color(0xFF0284C7), // Deep Ice Blue
    Color(0xFF38BDF8), // Sky Cyan
    Color(0xFF7DD3FC), // Glacial Light
    Color(0xFFE0F2FE), // Frost White-Blue
    Color(0xFF22D3EE), // Electric Cyan
    Color(0xFFBAE6FD), // Powder Ice
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });

    _particles = List.generate(65, (_) => _generateIceParticle());
    _controller.forward();
  }

  _IceParticle _generateIceParticle() {
    final shape = _IceShape.values[_random.nextInt(_IceShape.values.length)];
    final color = _icePalette[_random.nextInt(_icePalette.length)];
    final size = _random.nextDouble() * 8 + 5;

    final startXPercent = 0.5 + (_random.nextDouble() - 0.5) * 0.75;
    final initialVx = (_random.nextDouble() - 0.5) * 320;
    final initialVy = _random.nextDouble() * 200 + 80;
    final gravity = _random.nextDouble() * 160 + 280; // Floatier than confetti

    return _IceParticle(
      startXPercent: startXPercent,
      color: color,
      shape: shape,
      size: size,
      vx: initialVx,
      vy: initialVy,
      gravity: gravity,
      rotationSpeed: (_random.nextDouble() - 0.5) * 8,
      swayFreq: _random.nextDouble() * 3 + 1.5,
      swayAmp: _random.nextDouble() * 30 + 12,
      delayMs: _random.nextInt(400),
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
          // 1. Frosty Vignette & Ice Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (ctx, _) {
                return CustomPaint(
                  painter: _IceStormPainter(
                    particles: _particles,
                    progress: _controller.value,
                    totalDurationMs: _duration.inMilliseconds.toDouble(),
                  ),
                );
              },
            ),
          ),

          // 2. Floating Animated Ice Shield Pill
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: _IceShieldCelebrationBadge(
                  controller: _controller,
                  mode: widget.mode,
                  value: widget.value,
                  subValue: widget.subValue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IceShieldCelebrationBadge extends StatelessWidget {
  const _IceShieldCelebrationBadge({
    required this.controller,
    required this.mode,
    required this.value,
    required this.subValue,
  });

  final AnimationController controller;
  final FreezeOverlayMode mode;
  final int value;
  final int subValue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;

        // Entrance (0.0 -> 0.16), Hold (0.16 -> 0.78), Exit (0.78 -> 1.0)
        var opacity = 1.0;
        var translateY = 0.0;
        var scale = 1.0;

        if (t < 0.16) {
          final e = Curves.easeOutBack.transform(t / 0.16);
          opacity = (t / 0.12).clamp(0.0, 1.0);
          translateY = (1 - e) * -36;
          scale = 0.8 + 0.2 * e;
        } else if (t > 0.78) {
          final x = Curves.easeInCubic.transform((t - 0.78) / 0.22);
          opacity = (1 - x).clamp(0.0, 1.0);
          translateY = -20 * x;
          scale = 1.0 - 0.08 * x;
        }

        // Shield lock-in shiver & pulse between t = 0.22 and 0.42
        var rotateZ = 0.0;
        if (t >= 0.22 && t <= 0.42) {
          final pulseT = (t - 0.22) / 0.20;
          scale *= 1.0 + 0.14 * sin(pulseT * pi);
          rotateZ = sin(pulseT * pi * 4) * 0.035 * (1 - pulseT);
        }

        if (opacity <= 0) return const SizedBox.shrink();

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.rotate(
              angle: rotateZ,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF082F49).withValues(alpha: 0.96),
                        const Color(0xFF0F172A).withValues(alpha: 0.96),
                      ]
                    : [
                        const Color(0xFFF0F9FF).withValues(alpha: 0.98),
                        Colors.white.withValues(alpha: 0.98),
                      ],
              ),
              borderRadius: AppRadii.borderRadiusFull,
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.65),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                  blurRadius: 28,
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
                // Animated Glowing Ice Shield Icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0284C7),
                        Color(0xFF38BDF8),
                        Color(0xFFBAE6FD),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.55),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shield_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.ac_unit_rounded,
                        size: 13,
                        color: const Color(0xFF0284C7).withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
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
                          mode == FreezeOverlayMode.streakSaved
                              ? '$value DAY STREAK'
                              : (mode == FreezeOverlayMode.welcomeGift
                                  ? (value > 0
                                      ? 'STREAK SHIELD GIFT!'
                                      : 'WELCOME GIFT!')
                                  : '+1 STREAK FREEZE'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color:
                                isDark ? Colors.white : const Color(0xFF0C4A6E),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mode == FreezeOverlayMode.streakSaved
                          ? 'FROZEN & PROTECTED · $subValue LEFT'
                          : (mode == FreezeOverlayMode.welcomeGift
                              ? (value > 0
                                  ? '1 FREEZE EQUIPPED · $value-DAY HABIT SAFE'
                                  : '1 FREEZE EQUIPPED · STREAK SHIELD')
                              : 'EQUIPPED ($value/$subValue SHIELDS)'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _IceShape { snowflake, crystalDiamond, hexShard }

class _IceParticle {
  _IceParticle({
    required this.startXPercent,
    required this.color,
    required this.shape,
    required this.size,
    required this.vx,
    required this.vy,
    required this.gravity,
    required this.rotationSpeed,
    required this.swayFreq,
    required this.swayAmp,
    required this.delayMs,
  });

  final double startXPercent;
  final Color color;
  final _IceShape shape;
  final double size;
  final double vx;
  final double vy;
  final double gravity;
  final double rotationSpeed;
  final double swayFreq;
  final double swayAmp;
  final int delayMs;
}

class _IceStormPainter extends CustomPainter {
  _IceStormPainter({
    required this.particles,
    required this.progress,
    required this.totalDurationMs,
  });

  final List<_IceParticle> particles;
  final double progress;
  final double totalDurationMs;

  @override
  void paint(Canvas canvas, Size size) {
    final currentMs = progress * totalDurationMs;

    // Subtle top frost radial glow during first half of animation
    if (progress < 0.65) {
      final glowAlpha = (1.0 - (progress / 0.65)) * 0.22;
      final frostPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.85),
          radius: 0.9,
          colors: [
            const Color(0xFF38BDF8).withValues(alpha: glowAlpha),
            const Color(0xFF38BDF8).withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, frostPaint);
    }

    for (final p in particles) {
      if (currentMs < p.delayMs) continue;
      final t = (currentMs - p.delayMs) / 1000.0;
      if (t < 0) continue;

      final y = p.vy * t + 0.5 * p.gravity * t * t;
      final startX = size.width * p.startXPercent;
      final x = startX + p.vx * t + sin(p.swayFreq * t) * p.swayAmp;

      if (y > size.height + 40) continue;

      var alpha = 1.0;
      if (progress > 0.72) {
        alpha = ((1.0 - progress) / 0.28).clamp(0.0, 1.0);
      }

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotationSpeed * t);

      switch (p.shape) {
        case _IceShape.crystalDiamond:
          final path = Path()
            ..moveTo(0, -p.size * 0.75)
            ..lineTo(p.size * 0.42, 0)
            ..lineTo(0, p.size * 0.75)
            ..lineTo(-p.size * 0.42, 0)
            ..close();
          canvas.drawPath(path, paint);

        case _IceShape.hexShard:
          final path = Path();
          for (var i = 0; i < 6; i++) {
            final angle = (i * 60) * pi / 180;
            final r = p.size * 0.55;
            if (i == 0) {
              path.moveTo(cos(angle) * r, sin(angle) * r);
            } else {
              path.lineTo(cos(angle) * r, sin(angle) * r);
            }
          }
          path.close();
          canvas.drawPath(path, paint);

        case _IceShape.snowflake:
          final strokePaint = Paint()
            ..color = p.color.withValues(alpha: alpha)
            ..strokeWidth = 1.6
            ..strokeCap = StrokeCap.round;
          final r = p.size * 0.65;
          for (var i = 0; i < 3; i++) {
            final angle = i * pi / 3;
            canvas.drawLine(
              Offset(cos(angle) * -r, sin(angle) * -r),
              Offset(cos(angle) * r, sin(angle) * r),
              strokePaint,
            );
          }
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _IceStormPainter oldDelegate) => true;
}
