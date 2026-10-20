import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:verso/core/design/extensions.dart';

/// Wraps any widget with an animated icy shimmer sweep, pulsing frost glow,
/// and optional corner crystal accents when [isFrozen] is true.
class VersoFrostEffect extends StatefulWidget {
  const VersoFrostEffect({
    required this.child,
    this.isFrozen = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.showSnowflakeWatermark = false,
    this.intensity = 1.0,
    super.key,
  });

  final Widget child;
  final bool isFrozen;
  final BorderRadius borderRadius;
  final bool showSnowflakeWatermark;
  final double intensity;

  @override
  State<VersoFrostEffect> createState() => _VersoFrostEffectState();
}

class _VersoFrostEffectState extends State<VersoFrostEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (widget.isFrozen) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VersoFrostEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFrozen && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isFrozen && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFrozen) return widget.child;

    final freezeColor = context.appColors.streakFreeze;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Smooth sine pulse for outer rim glow and crystal breathing (0.0 -> 1.0 -> 0.0)
        final pulse = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;

        // Continuous seamless diagonal ice sweep without pauses or stalls.
        // By shifting exactly one period (spanX, spanY) with TileMode.repeated,
        // the transition at the loop boundary (1.0 -> 0.0) is mathematically
        // identical, eliminating any stuck or dead time.
        final sweepValue = _controller.value;
        const spanX = 2.6;
        const spanY = 2.0;
        final beginAlignment = Alignment(
          (-spanX / 2) - (sweepValue * spanX),
          (-spanY / 2) - (sweepValue * spanY),
        );
        final endAlignment = Alignment(
          (spanX / 2) - (sweepValue * spanX),
          (spanY / 2) - (sweepValue * spanY),
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: freezeColor.withValues(
                  alpha: (0.14 + (pulse * 0.18)) * widget.intensity,
                ),
                blurRadius: 8 + (pulse * 6),
                spreadRadius: pulse * 1.2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                child!,

                // Optional rotating / breathing snowflake watermark
                if (widget.showSnowflakeWatermark)
                  Positioned(
                    right: -12,
                    bottom: -12,
                    child: Transform.rotate(
                      angle: _controller.value * 2 * math.pi * 0.25,
                      child: Icon(
                        Icons.ac_unit_rounded,
                        size: 68,
                        color: freezeColor.withValues(
                          alpha: (0.08 + (pulse * 0.08)) * widget.intensity,
                        ),
                      ),
                    ),
                  ),

                // Diagonal Ice Glint Sweep (Continuous, non-stuck loop)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: beginAlignment,
                          end: endAlignment,
                          tileMode: TileMode.repeated,
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            freezeColor.withValues(
                              alpha: 0.16 * widget.intensity,
                            ),
                            Colors.white.withValues(
                              alpha: 0.38 * widget.intensity,
                            ),
                            freezeColor.withValues(
                              alpha: 0.16 * widget.intensity,
                            ),
                            Colors.white.withValues(alpha: 0),
                          ],
                          stops: const [0.0, 0.38, 0.5, 0.62, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Pulsing Frosted Rim Border
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: widget.borderRadius,
                        border: Border.all(
                          color: Color.lerp(
                            freezeColor.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.85),
                            pulse * 0.5,
                          )!,
                          width: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
