import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';

/// Terms of Use screen.
class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms of Use',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1)
                      .withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF6366F1)
                        .withValues(alpha: isDark ? 0.3 : 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms of Use',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6366F1),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Effective date: October 2025 · By using Verso, you agree to these terms.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              height: 1.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              _LegalSection(
                number: '1',
                title: 'Acceptance of Terms',
                content:
                    'By downloading, installing, or using Verso ("the App"), you agree to be bound by these Terms of Use. If you do not agree to these terms, please do not use the App.',
                scheme: scheme,
                isDark: isDark,
              ),
              _LegalSection(
                number: '2',
                title: 'Use of the App',
                content:
                    'Verso is a personal Bible reading tracker designed to help you build a consistent reading habit. You may use the App for personal, non-commercial purposes only. You agree not to misuse the App, attempt to gain unauthorized access to any part of it, or use it in any way that violates applicable laws.',
                scheme: scheme,
                isDark: isDark,
              ),
              _LegalSection(
                number: '3',
                title: 'User Accounts',
                content:
                    'To access certain features, you must create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account. You agree to notify us immediately of any unauthorized use of your account.',
                scheme: scheme,
                isDark: isDark,
              ),
              _LegalSection(
                number: '4',
                title: 'Bible Content',
                content:
                    'The Bible texts and related content within Verso are provided for personal, devotional use. We respect all copyright licenses of the translations used. Distribution or reproduction of Bible text outside the App may be subject to separate licensing terms.',
                scheme: scheme,
                isDark: isDark,
              ),
              _LegalSection(
                number: '5',
                title: 'Intellectual Property',
                content:
                    'The App, including its design, code, icons, and features, is the intellectual property of the developer. You may not copy, modify, distribute, sell, or lease any part of the App without prior written consent.',
                scheme: scheme,
                isDark: isDark,
              ),
              _LegalSection(
                number: '6',
                title: 'Limitation of Liability',
                content:
                    'Verso is provided "as is" without any warranties, express or implied. The developer shall not be liable for any indirect, incidental, or consequential damages arising from your use of the App, including but not limited to loss of data or reading progress.',
                scheme: scheme,
                isDark: isDark,
              ),
              _LegalSection(
                number: '7',
                title: 'Changes to Terms',
                content:
                    'We reserve the right to modify these Terms at any time. Continued use of the App after changes are posted constitutes your acceptance of the updated Terms.',
                scheme: scheme,
                isDark: isDark,
              ),
              _LegalSection(
                number: '8',
                title: 'Contact',
                contentWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'If you have questions about these Terms of Use, please contact us at:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.6,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(6),
                    GestureDetector(
                      onTap: () => _handleEmailTap(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.mail_outline_rounded,
                              size: 15,
                              color: Color(0xFF6366F1),
                            ),
                            const Gap(6),
                            Text(
                              'versoappsupport@gmail.com',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                scheme: scheme,
                isDark: isDark,
              ),

              const Gap(48),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _handleEmailTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(
      'mailto:versoappsupport@gmail.com?subject=Verso%20Terms%20of%20Use%20Inquiry',
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await Clipboard.setData(
          const ClipboardData(text: 'versoappsupport@gmail.com'),
        );
        if (context.mounted) {
          VersoSnackbar.show(
            context,
            message: 'Email copied: versoappsupport@gmail.com',
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(
        const ClipboardData(text: 'versoappsupport@gmail.com'),
      );
      if (context.mounted) {
        VersoSnackbar.show(
          context,
          message: 'Email copied: versoappsupport@gmail.com',
        );
      }
    }
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.number,
    required this.title,
    required this.scheme,
    required this.isDark,
    this.content,
    this.contentWidget,
  }) : assert(
          content != null || contentWidget != null,
          'Either content or contentWidget must be provided',
        );

  final String number;
  final String title;
  final ColorScheme scheme;
  final bool isDark;
  final String? content;
  final Widget? contentWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF6366F1).withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF6366F1),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const Gap(6),
                if (contentWidget != null)
                  contentWidget!
                else
                  Text(
                    content!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.6,
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
