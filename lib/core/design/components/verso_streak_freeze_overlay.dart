import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/features/settings/data/settings_repository.dart';

enum FreezeOverlayMode { streakSaved, freezeEarned, welcomeGift }

/// High-impact, informative celebratory overlay for Streak Freeze events.
/// Displays an interactive modal card with backdrop blur, particle effects,
/// clear "why & how" explanations, and visual inventory status.
class VersoStreakFreezeOverlay {
  VersoStreakFreezeOverlay._();

  static OverlayEntry? _activeEntry;

  /// Closes any currently displayed freeze overlay.
  static void dismissActive() {
    _activeEntry?.remove();
    _activeEntry = null;
  }

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
      subValue: SettingsRepository.maxStreakFreezes,
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

    // Remove any previously active overlay cleanly
    _activeEntry?.remove();
    _activeEntry = null;

    HapticFeedback.heavyImpact();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _StreakFreezeOverlayWidget(
        mode: mode,
        value: value,
        subValue: subValue,
        onComplete: () {
          if (_activeEntry == entry) {
            _activeEntry = null;
          }
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    _activeEntry = entry;
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
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _particleCtrl;
  late final List<_IceParticle> _particles;
  final _random = Random();
  bool _isDismissing = false;

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
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _particles = List.generate(55, (_) => _generateIceParticle());
    _entranceCtrl.forward();
  }

  _IceParticle _generateIceParticle() {
    final shape = _IceShape.values[_random.nextInt(_IceShape.values.length)];
    final color = _icePalette[_random.nextInt(_icePalette.length)];
    final size = _random.nextDouble() * 8 + 5;

    final startXPercent = _random.nextDouble();
    final initialVx = (_random.nextDouble() - 0.5) * 160;
    final initialVy = _random.nextDouble() * 80 + 40;
    final gravity = _random.nextDouble() * 80 + 120;

    return _IceParticle(
      startXPercent: startXPercent,
      color: color,
      shape: shape,
      size: size,
      vx: initialVx,
      vy: initialVy,
      gravity: gravity,
      rotationSpeed: (_random.nextDouble() - 0.5) * 4,
      swayFreq: _random.nextDouble() * 2.5 + 1.2,
      swayAmp: _random.nextDouble() * 24 + 10,
      delayMs: _random.nextInt(1200),
    );
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    HapticFeedback.lightImpact();
    _entranceCtrl.reverse().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Blurred Dimmed Backdrop with tap-to-dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismiss,
              child: AnimatedBuilder(
                animation: _entranceCtrl,
                builder: (context, child) {
                  return Opacity(
                    opacity: _entranceCtrl.value,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.65 : 0.45,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Continuous Floating Ice Storm Particles
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _particleCtrl,
                builder: (ctx, _) {
                  return CustomPaint(
                    painter: _IceStormPainter(
                      particles: _particles,
                      progress: _particleCtrl.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Central Expanded Celebration Card
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _entranceCtrl,
                builder: (context, child) {
                  final t = _entranceCtrl.value;
                  final scale = 0.85 + (0.15 * Curves.easeOutBack.transform(t));
                  return Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: _CelebrationCard(
                  mode: widget.mode,
                  value: widget.value,
                  subValue: widget.subValue,
                  pulseCtrl: _pulseCtrl,
                  onDismiss: _dismiss,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({
    required this.mode,
    required this.value,
    required this.subValue,
    required this.pulseCtrl,
    required this.onDismiss,
  });

  final FreezeOverlayMode mode;
  final int value;
  final int subValue;
  final AnimationController pulseCtrl;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    const freezeColor = Color(0xFF0284C7);
    const cyanGlow = Color(0xFF38BDF8);

    // Dynamic strings based on mode
    final String eyebrow;
    final String title;
    final String whyText;
    final String point1Title;
    final String point1Desc;
    final IconData point1Icon;
    final Color point1Color;
    final String point2Title;
    final String point2Desc;
    final IconData point2Icon;
    final Color point2Color;
    final String ctaText;

    switch (mode) {
      case FreezeOverlayMode.welcomeGift:
        eyebrow = 'SPECIAL WELCOME GIFT 🎁';
        title = 'Streak Freeze Equipped!';
        whyText =
            'We gave you 1 free Streak Freeze shield! If life gets busy and you miss a day, this shield automatically activates at midnight to keep your active reading streak alive.';
        point1Title = 'Automatic Missed-Day Protection';
        point1Desc =
            'No manual setup needed. When you miss a calendar day, the shield freezes your streak so your days never reset to zero.';
        point1Icon = Icons.bolt_rounded;
        point1Color = cyanGlow;
        point2Title = 'Earn More on Milestones';
        point2Desc =
            'Maintain daily reading to earn +1 extra freeze on every 30-day streak milestone (holds up to 2 maximum).';
        point2Icon = Icons.auto_awesome_rounded;
        point2Color = freezeColor;
        ctaText = 'Equip Freeze & Continue';

      case FreezeOverlayMode.streakSaved:
        eyebrow = 'STREAK SAVED BY FREEZE ❄️';
        title = '$value-Day Streak Rescued!';
        whyText =
            'You missed reading yesterday, but your equipped Streak Freeze automatically stepped in at midnight to save your $value-day streak from breaking!';
        point1Title = 'Streak Flame Is Currently Frozen';
        point1Desc =
            'Your streak flame is resting in ice ❄️. Read at least 1 chapter today to relight your streak fire 🔥!';
        point1Icon = Icons.ac_unit_rounded;
        point1Color = cyanGlow;
        point2Title = subValue > 0
            ? '$subValue Shield Remaining in Vault'
            : '0 Streak Freezes Remaining!';
        point2Desc = subValue > 0
            ? 'You have $subValue shield left for future emergencies. Read daily to keep your habit safe.'
            : 'You used your last shield! Be sure to read daily to prevent losing your streak tomorrow.';
        point2Icon =
            subValue > 0 ? Icons.shield_rounded : Icons.warning_amber_rounded;
        point2Color = subValue > 0 ? freezeColor : Colors.amber[700]!;
        ctaText = 'Relight My Flame 🔥';

      case FreezeOverlayMode.freezeEarned:
        eyebrow = '30-DAY MILESTONE REWARD 🏆';
        title = '+1 Streak Freeze Earned!';
        whyText =
            'Incredible dedication! By hitting another 30-day streak milestone, you’ve earned an extra Streak Freeze shield to safeguard your journey.';
        point1Title = 'Shield Vault Refilled';
        point1Desc =
            'You now have $value of ${SettingsRepository.maxStreakFreezes} maximum Streak Freezes equipped and standing guard.';
        point1Icon = Icons.verified_user_rounded;
        point1Color = const Color(0xFF10B981);
        point2Title = 'Worry-Free Bible Habit';
        point2Desc =
            'Life can get unpredictable. Your hard-earned streak is shielded against accidental missed days.';
        point2Icon = Icons.auto_stories_rounded;
        point2Color = cyanGlow;
        ctaText = 'Claim Shield & Continue';
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 390),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: AppRadii.borderRadiusXXL,
        border: Border.all(
          color: cyanGlow.withValues(alpha: isDark ? 0.45 : 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cyanGlow.withValues(alpha: isDark ? 0.35 : 0.22),
            blurRadius: 36,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Radial Light
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      cyanGlow.withValues(alpha: isDark ? 0.22 : 0.16),
                      cyanGlow.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top bar with close X
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onDismiss,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  // Hero Pulsing Ice Shield Icon
                  AnimatedBuilder(
                    animation: pulseCtrl,
                    builder: (context, child) {
                      final val = pulseCtrl.value;
                      final scale = 1.0 + (0.06 * val);
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 74,
                      height: 74,
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
                            color: cyanGlow.withValues(alpha: 0.55),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                          Icon(
                            Icons.ac_unit_rounded,
                            size: 19,
                            color: freezeColor.withValues(alpha: 0.95),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(14),

                  // Eyebrow Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: freezeColor.withValues(alpha: 0.12),
                      borderRadius: AppRadii.borderRadiusFull,
                      border: Border.all(
                        color: freezeColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      eyebrow,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: freezeColor,
                      ),
                    ),
                  ),
                  const Gap(8),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: scheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Gap(10),

                  // Why & How explanation paragraph
                  Text(
                    whyText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(16),

                  // Feature Info Points Box
                  Container(
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: isDark ? 0.35 : 0.55,
                      ),
                      borderRadius: AppRadii.borderRadiusLG,
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailPointRow(
                          icon: point1Icon,
                          iconColor: point1Color,
                          title: point1Title,
                          desc: point1Desc,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color: scheme.outline.withValues(alpha: 0.12),
                          ),
                        ),
                        _DetailPointRow(
                          icon: point2Icon,
                          iconColor: point2Color,
                          title: point2Title,
                          desc: point2Desc,
                        ),
                      ],
                    ),
                  ),
                  const Gap(14),

                  // Visual 2-Slot Inventory Status
                  _buildInventoryRow(context, isDark, scheme, cyanGlow),
                  const Gap(18),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onDismiss,
                      style: FilledButton.styleFrom(
                        backgroundColor: freezeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.borderRadiusMD,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        ctaText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(
    BuildContext context,
    bool isDark,
    ColorScheme scheme,
    Color cyanGlow,
  ) {
    const maxFreezes = SettingsRepository.maxStreakFreezes;
    final int equippedSlots;
    if (mode == FreezeOverlayMode.welcomeGift) {
      equippedSlots = 1;
    } else if (mode == FreezeOverlayMode.streakSaved) {
      equippedSlots = subValue;
    } else {
      equippedSlots = value;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INVENTORY SLOTS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
            Text(
              '$equippedSlots / $maxFreezes Equipped',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cyanGlow,
              ),
            ),
          ],
        ),
        const Gap(6),
        Row(
          children: List.generate(maxFreezes, (index) {
            final isEquipped = index < equippedSlots;
            final isSavedUsedSlot =
                mode == FreezeOverlayMode.streakSaved && index == 0;

            final borderColor = isEquipped
                ? cyanGlow.withValues(alpha: 0.6)
                : scheme.outline.withValues(alpha: 0.2);
            final bgColor = isEquipped
                ? cyanGlow.withValues(alpha: isDark ? 0.15 : 0.1)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.35);

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < maxFreezes - 1 ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: AppRadii.borderRadiusMD,
                  border: Border.all(
                    color: borderColor,
                    width: isEquipped ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEquipped
                          ? Icons.shield_rounded
                          : (isSavedUsedSlot
                              ? Icons.ac_unit_rounded
                              : Icons.shield_outlined),
                      size: 16,
                      color: isEquipped
                          ? cyanGlow
                          : scheme.onSurfaceVariant.withValues(alpha: 0.45),
                    ),
                    const Gap(6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Slot ${index + 1}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isEquipped
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            isEquipped
                                ? 'Equipped'
                                : (isSavedUsedSlot
                                    ? 'Used Yesterday'
                                    : '30-Day Milestone'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isEquipped
                                  ? cyanGlow
                                  : scheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DetailPointRow extends StatelessWidget {
  const _DetailPointRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const Gap(2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
  });

  final List<_IceParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final currentMs = progress * 4000.0;

    for (final p in particles) {
      final t = ((currentMs - p.delayMs) % 4000) / 1000.0;
      if (t < 0) continue;

      final y = (p.vy * t + 0.5 * p.gravity * t * t) % (size.height + 40);
      final startX = size.width * p.startXPercent;
      final x =
          (startX + p.vx * t + sin(p.swayFreq * t) * p.swayAmp) % size.width;

      final paint = Paint()
        ..color = p.color.withValues(alpha: 0.65)
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
            ..color = p.color.withValues(alpha: 0.65)
            ..strokeWidth = 1.4
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
