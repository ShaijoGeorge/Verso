import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
    super.key,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.borderRadiusLG,
        border: Border.all(
          color: isAmoled
              ? scheme.outline.withValues(alpha: 0.85)
              : scheme.outline.withValues(alpha: isLight ? 0.65 : 0.25),
        ),
        boxShadow: isLight ? AppShadows.sm : AppShadows.none,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    iconColor.withValues(alpha: isLight ? 0.15 : 0.22),
                    iconColor.withValues(alpha: 0),
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
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: AppRadii.borderRadiusSM,
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(icon, size: 19, color: iconColor),
                ),
                const Gap(14),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: scheme.onSurface,
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
