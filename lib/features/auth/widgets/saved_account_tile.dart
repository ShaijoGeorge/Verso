import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/components/verso_card.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/features/auth/models/saved_account.dart';

class SavedAccountTile extends StatelessWidget {
  const SavedAccountTile({
    required this.account,
    super.key,
    this.isCurrent = false,
    this.isLoading = false,
    this.onTap,
    this.onRemove,
  });

  final SavedAccount account;
  final bool isCurrent;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = account.displayName.isNotEmpty
        ? account.displayName[0].toUpperCase()
        : '?';

    final activeColor = scheme.primary;

    return VersoCard(
      padding: EdgeInsets.zero,
      color: isCurrent
          ? activeColor.withValues(alpha: 0.08)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      border: Border.all(
        color: isCurrent
            ? activeColor.withValues(alpha: 0.4)
            : scheme.outlineVariant.withValues(alpha: 0.2),
        width: isCurrent ? 1.5 : 1,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCurrent
                        ? [activeColor, activeColor.withValues(alpha: 0.7)]
                        : [
                            scheme.onSurfaceVariant.withValues(alpha: 0.2),
                            scheme.onSurfaceVariant.withValues(alpha: 0.35),
                          ],
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isCurrent ? Colors.white : scheme.onSurface,
                  ),
                ),
              ),

              const Gap(14),

              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        if (isCurrent) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: activeColor,
                                ),
                                const Gap(4),
                                Text(
                                  'Active',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: activeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(2),
                    Text(
                      account.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing action
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (!isCurrent) ...[
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  tooltip: 'Remove from device',
                  onPressed: isLoading ? null : onRemove,
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
