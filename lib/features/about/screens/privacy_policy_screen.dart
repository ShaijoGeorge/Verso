import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

/// Privacy Policy screen.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
                  color: const Color(0xFF10B981)
                      .withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF10B981)
                        .withValues(alpha: isDark ? 0.3 : 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.privacy_tip_outlined,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Effective date: October 2025 · Your privacy matters to us.',
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

              _PolicySection(
                number: '1',
                title: 'Information We Collect',
                content:
                    "We collect information you provide directly, such as your name, email address, and profile details when you create an account. We also collect reading activity data, including chapters marked as read and reading streaks, to power the App's core features.",
                scheme: scheme,
                isDark: isDark,
              ),
              _PolicySection(
                number: '2',
                title: 'How We Use Your Information',
                content:
                    'Your data is used solely to provide and improve the Verso experience - including syncing your reading progress across devices, generating personal reading statistics, and sending optional reminders. We do not sell, rent, or share your personal data with third parties for marketing purposes.',
                scheme: scheme,
                isDark: isDark,
              ),
              _PolicySection(
                number: '3',
                title: 'Data Storage & Security',
                content:
                    'Your data is stored securely on encrypted cloud servers with strict access controls. Reading progress is also cached locally on your device to enable offline access. All communication between the App and our servers is encrypted in transit using industry-standard protocols (HTTPS/TLS).',
                scheme: scheme,
                isDark: isDark,
              ),
              _PolicySection(
                number: '4',
                title: 'Account & Authentication',
                content:
                    'We support secure email and password sign-in. Your credentials are managed using industry-standard authentication systems with salted cryptographic hashing. We never store or have access to your plain-text password.',
                scheme: scheme,
                isDark: isDark,
              ),
              _PolicySection(
                number: '5',
                title: 'Push Notifications',
                content:
                    'If you enable reminders or daily verse notifications, we use your device token to deliver these. You can disable notifications at any time through the App settings or your device settings.',
                scheme: scheme,
                isDark: isDark,
              ),
              _PolicySection(
                number: '6',
                title: 'Crash Reporting & Diagnostics',
                content:
                    'We may collect anonymized crash reports and diagnostic performance data through trusted service providers. This helps us quickly identify and resolve bugs. No personally identifiable information or reading activity is included in these reports.',
                scheme: scheme,
                isDark: isDark,
              ),
              _PolicySection(
                number: '7',
                title: 'Data Deletion',
                content:
                    'You may delete your account at any time from the Settings screen. Deleting your account permanently removes all your personal data and reading history from our servers.',
                scheme: scheme,
                isDark: isDark,
              ),
              _PolicySection(
                number: '8',
                title: "Children's Privacy",
                content:
                    'Verso is not directed at children under 13. We do not knowingly collect personal information from children under 13. If you believe a child has provided us with personal information, please contact us so we can delete it.',
                scheme: scheme,
                isDark: isDark,
              ),
              _PolicySection(
                number: '9',
                title: 'Changes to This Policy',
                content:
                    'We may update this Privacy Policy from time to time. We will notify you of significant changes through the App. Continued use after changes are posted constitutes acceptance of the updated policy.',
                scheme: scheme,
                isDark: isDark,
              ),
              _PolicySection(
                number: '10',
                title: 'Contact',
                content:
                    'If you have questions or concerns about this Privacy Policy, please contact us at versoappsupport@gmail.com.',
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
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.number,
    required this.title,
    required this.content,
    required this.scheme,
    required this.isDark,
  });

  final String number;
  final String title;
  final String content;
  final ColorScheme scheme;
  final bool isDark;

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
                  const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF10B981),
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
                Text(
                  content,
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
