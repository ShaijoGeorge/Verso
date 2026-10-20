import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/features/settings/data/settings_repository.dart';

/// Animated top-right Streak & Freeze status pill for the Home Screen.
class AnimatedStreakBadge extends StatefulWidget {
  const AnimatedStreakBadge({
    required this.streak,
    required this.availableFreezes,
    required this.isFrozen,
    required this.onTap,
    super.key,
  });

  final int streak;
  final int availableFreezes;
  final bool isFrozen;
  final VoidCallback onTap;

  @override
  State<AnimatedStreakBadge> createState() => _AnimatedStreakBadgeState();
}

class _AnimatedStreakBadgeState extends State<AnimatedStreakBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeColor = widget.isFrozen
        ? context.appColors.streakFreeze
        : context.appColors.streak;
    final freezeColor = context.appColors.streakFreeze;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          final glowAlpha = 0.12 + (_pulseCtrl.value * 0.10);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  activeColor.withValues(alpha: glowAlpha),
                  activeColor.withValues(alpha: glowAlpha * 0.5),
                ],
              ),
              borderRadius: AppRadii.borderRadiusFull,
              border: Border.all(
                color: activeColor.withValues(alpha: 0.35),
              ),
              boxShadow: [
                if (widget.isFrozen)
                  BoxShadow(
                    color: freezeColor.withValues(
                      alpha: 0.18 * _pulseCtrl.value,
                    ),
                    blurRadius: 12,
                  ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Morphing Flame <-> Ice Icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Icon(
                widget.isFrozen
                    ? Icons.ac_unit_rounded
                    : Icons.local_fire_department_rounded,
                key: ValueKey<bool>(widget.isFrozen),
                size: 15,
                color: activeColor,
              ),
            ),
            const Gap(5),
            Text(
              widget.isFrozen
                  ? '${widget.streak} Day Streak (Frozen)'
                  : '${widget.streak} Day Streak',
              style: textTheme.labelSmall?.copyWith(
                color: activeColor,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            if (widget.availableFreezes > 0) ...[
              const Gap(7),
              Container(
                width: 1,
                height: 11,
                color: activeColor.withValues(alpha: 0.25),
              ),
              const Gap(6),
              Icon(
                Icons.shield_rounded,
                size: 12.5,
                color: freezeColor,
              ),
              const Gap(2),
              Text(
                '${widget.availableFreezes}',
                style: textTheme.labelSmall?.copyWith(
                  color: freezeColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Interactive Bottom Sheet displaying Streak Freeze inventory, status, and rules.
class StreakFreezeBottomSheet extends StatefulWidget {
  const StreakFreezeBottomSheet({
    required this.streak,
    required this.availableFreezes,
    required this.isFrozen,
    required this.todayCount,
    super.key,
  });

  final int streak;
  final int availableFreezes;
  final bool isFrozen;
  final int todayCount;

  static Future<void> show(
    BuildContext context, {
    required int streak,
    required int availableFreezes,
    required bool isFrozen,
    required int todayCount,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StreakFreezeBottomSheet(
        streak: streak,
        availableFreezes: availableFreezes,
        isFrozen: isFrozen,
        todayCount: todayCount,
      ),
    );
  }

  @override
  State<StreakFreezeBottomSheet> createState() =>
      _StreakFreezeBottomSheetState();
}

class _StreakFreezeBottomSheetState extends State<StreakFreezeBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final freezeColor = context.appColors.streakFreeze;
    final streakColor = context.appColors.streak;

    const maxFreezes = SettingsRepository.maxStreakFreezes;
    final daysUntilNextFreeze = 30 - (widget.streak % 30);
    final milestoneProgress = (widget.streak % 30) / 30.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.borderRadiusXXL,
        border: Border.all(
          color: freezeColor.withValues(alpha: isLight ? 0.3 : 0.45),
        ),
        boxShadow: AppShadows.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.25),
              borderRadius: AppRadii.borderRadiusFull,
            ),
          ),
          const Gap(24),

          // Floating 3D-style Ice Shield + Flame Hero
          AnimatedBuilder(
            animation: _floatCtrl,
            builder: (context, child) {
              final dy = sin(_floatCtrl.value * pi) * -6;
              return Transform.translate(
                offset: Offset(0, dy),
                child: child,
              );
            },
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    freezeColor.withValues(alpha: 0.28),
                    freezeColor.withValues(alpha: 0.04),
                  ],
                ),
                border: Border.all(
                  color: freezeColor.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: freezeColor.withValues(alpha: 0.25),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: 52,
                    color: freezeColor,
                  ),
                  const Icon(
                    Icons.ac_unit_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                  if (widget.streak > 0)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: streakColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: streakColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Gap(18),

          // Title & Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: freezeColor.withValues(alpha: 0.12),
              borderRadius: AppRadii.borderRadiusFull,
            ),
            child: Text(
              widget.isFrozen
                  ? 'STREAK SAVED YESTERDAY'
                  : (widget.availableFreezes > 0
                      ? 'STREAK PROTECTION ACTIVE'
                      : 'NO FREEZES EQUIPPED'),
              style: textTheme.labelSmall?.copyWith(
                color: freezeColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
          ),
          const Gap(10),
          Text(
            'Streak Freeze',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const Gap(6),
          Text(
            widget.isFrozen
                ? 'Your Streak Freeze automatically activated yesterday to protect your ${widget.streak}-day Bible reading habit. Read a chapter today to relight your flame!'
                : 'Streak Freeze protects your reading streak for one missed day automatically so a busy day never resets your progress.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const Gap(24),

          // 2 Inventory Slots
          Row(
            children: List.generate(maxFreezes, (index) {
              final isEquipped = index < widget.availableFreezes;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 6,
                    right: index == maxFreezes - 1 ? 0 : 6,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: isEquipped ? 1.0 : 0.0),
                    duration: Duration(milliseconds: 500 + (index * 150)),
                    curve: Curves.easeOutBack,
                    builder: (context, val, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: isEquipped
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    freezeColor.withValues(alpha: 0.16),
                                    freezeColor.withValues(alpha: 0.06),
                                  ],
                                )
                              : null,
                          color: isEquipped
                              ? null
                              : scheme.surfaceContainerHighest
                                  .withValues(alpha: 0.45),
                          borderRadius: AppRadii.borderRadiusLG,
                          border: Border.all(
                            color: isEquipped
                                ? freezeColor.withValues(alpha: 0.45)
                                : scheme.outline.withValues(alpha: 0.2),
                            width: isEquipped ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Transform.scale(
                              scale: 0.85 + (0.15 * val),
                              child: Icon(
                                isEquipped
                                    ? Icons.shield_rounded
                                    : Icons.shield_outlined,
                                color: isEquipped
                                    ? freezeColor
                                    : scheme.onSurfaceVariant
                                        .withValues(alpha: 0.4),
                                size: 28,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              isEquipped ? 'Equipped' : 'Empty Slot',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isEquipped
                                    ? freezeColor
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              'Slot ${index + 1} of $maxFreezes',
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                color: scheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
          const Gap(18),

          // Progress to Next Freeze Milestone Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: AppRadii.borderRadiusLG,
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 15,
                          color: freezeColor,
                        ),
                        const Gap(6),
                        Text(
                          widget.availableFreezes >= maxFreezes
                              ? 'Max Freezes Equipped'
                              : 'Next Freeze Reward',
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.availableFreezes >= maxFreezes
                          ? '2 / 2 Full'
                          : '$daysUntilNextFreeze day${daysUntilNextFreeze == 1 ? '' : 's'} left',
                      style: textTheme.labelSmall?.copyWith(
                        color: freezeColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                ClipRRect(
                  borderRadius: AppRadii.borderRadiusFull,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: widget.availableFreezes >= maxFreezes
                          ? 1.0
                          : milestoneProgress.clamp(0.08, 1.0),
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 7,
                        backgroundColor: scheme.outline.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(freezeColor),
                      );
                    },
                  ),
                ),
                const Gap(8),
                Text(
                  'Awarded 1 Streak Freeze as a welcome gift. Earn +1 Streak Freeze on every 30-day streak milestone (up to 2 equipped).',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Gap(20),

          // Done button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: freezeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.borderRadiusMD,
                ),
              ),
              child: const Text(
                'Got It',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
