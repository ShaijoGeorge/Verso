import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/components/verso_bottom_sheet.dart';
import 'package:verso/core/design/components/verso_button.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/services/update_service.dart';

/// Modal bottom sheet prompting the user about a newly published Verso update.
class VersoUpdateSheet extends StatelessWidget {
  const VersoUpdateSheet({
    required this.info,
    super.key,
  });

  final AppUpdateInfo info;

  /// Shows the update bottom sheet modally.
  static Future<void> show(BuildContext context, AppUpdateInfo info) {
    HapticFeedback.mediumImpact();
    return VersoBottomSheet.show<void>(
      context: context,
      contentPadding: EdgeInsets.zero,
      child: VersoUpdateSheet(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark
        ? const Color(0xFF16181A)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.45);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing update icon
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: Color(0xFF10B981),
                size: 28,
              ),
            ),
            const Gap(16),

            // Headline
            Text(
              'New Update Available',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: scheme.onSurface,
              ),
            ),
            const Gap(8),

            // Version comparison pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadii.borderRadiusFull,
                border: Border.all(
                  color: scheme.outlineVariant
                      .withValues(alpha: isDark ? 0.2 : 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'v${info.currentVersion}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: scheme.primary,
                  ),
                  const Gap(8),
                  Text(
                    'v${info.latestVersion}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),

            // Release notes (if provided)
            if (info.releaseNotes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppRadii.borderRadiusMD,
                  border: Border.all(
                    color: scheme.outlineVariant
                        .withValues(alpha: isDark ? 0.2 : 0.5),
                  ),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Text(
                      info.releaseNotes,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.45,
                        color: scheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(20),
            ] else ...[
              Text(
                'A new version of Verso is ready for download with new features and improvements.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  height: 1.4,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Gap(24),
            ],

            // Action Buttons
            VersoButton(
              label: 'Download & Update',
              expand: true,
              icon: Icons.download_rounded,
              onPressed: () {
                Navigator.of(context).pop();
                UpdateService.launchDownload(info.downloadUrl);
              },
            ),
            const Gap(8),

            VersoButton.ghost(
              label: 'Later',
              expand: true,
              onPressed: () {
                Navigator.of(context).pop();
                UpdateService().recordPromptDismissed(info.latestVersion);
              },
            ),
          ],
        ),
      ),
    );
  }
}
