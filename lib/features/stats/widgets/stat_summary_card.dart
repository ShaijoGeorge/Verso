import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/components/verso_frost_effect.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
import 'package:verso/data/local/entities/user_settings.dart';

class StatSummaryCard extends StatelessWidget {
  const StatSummaryCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
    this.isFrozen = false,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;
  final bool isFrozen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;
    final freezeColor = context.appColors.streakFreeze;

    final effectiveColor = isFrozen ? freezeColor : iconColor;
    final effectiveIcon = isFrozen ? Icons.ac_unit_rounded : icon;

    return VersoFrostEffect(
      isFrozen: isFrozen,
      borderRadius: AppRadii.borderRadiusLG,
      showSnowflakeWatermark: isFrozen,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isFrozen
              ? Color.alphaBlend(
                  freezeColor.withValues(alpha: isLight ? 0.08 : 0.12),
                  scheme.surface,
                )
              : scheme.surface,
          borderRadius: AppRadii.borderRadiusLG,
          border: Border.all(
            color: isFrozen
                ? freezeColor.withValues(alpha: 0.55)
                : (isAmoled
                    ? scheme.outline.withValues(alpha: 0.85)
                    : scheme.outline.withValues(alpha: isLight ? 0.65 : 0.25)),
          ),
          boxShadow: isLight ? AppShadows.sm : AppShadows.none,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      effectiveColor.withValues(alpha: isLight ? 0.22 : 0.30),
                      effectiveColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: effectiveColor.withValues(alpha: 0.14),
                          borderRadius: AppRadii.borderRadiusSM,
                          border: Border.all(
                            color: effectiveColor.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Icon(
                          effectiveIcon,
                          size: 19,
                          color: effectiveColor,
                        ),
                      ),
                      if (isFrozen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: freezeColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: freezeColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                size: 10,
                                color: freezeColor,
                              ),
                              const Gap(3),
                              Text(
                                'FROZEN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: freezeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Gap(14),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isFrozen ? freezeColor : scheme.onSurface,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const Gap(1),
                  Text(
                    isFrozen ? 'Ice shield active ❄️' : subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight:
                          isFrozen ? FontWeight.w700 : FontWeight.normal,
                      color: isFrozen ? freezeColor : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
