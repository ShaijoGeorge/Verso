import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/widgets/verso_share_sheet.dart';
import 'package:verso/features/auth/providers/auth_providers.dart';

/// "Our Mission" screen featuring developer story, values, and transparency.
class OurMissionScreen extends ConsumerWidget {
  const OurMissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserProvider);
    final palette = context.palette;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0C0D0E) : palette.bg;
    final cardBg = isDark ? const Color(0xFF16181A) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : palette.border;

    final fullName = userAsync.value?.userMetadata?['full_name'] as String?;
    final firstName = fullName != null && fullName.trim().isNotEmpty
        ? fullName.trim().split(' ').first
        : null;

    final greeting = firstName != null
        ? 'Hi $firstName, thanks for being a part of Verso!'
        : 'Hi, thanks for being a part of Verso!';

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Mission Header (No developer image)
          SliverToBoxAdapter(
            child: _MissionHeader(
              bg: bg,
              isDark: isDark,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),

          // Main Story & Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(16),

                  // Greeting
                  Text(
                    greeting,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: isDark ? Colors.white : palette.text,
                    ),
                  ),

                  const Gap(16),

                  // Intro
                  Text(
                    "I'm Shaijo George, the developer behind the app.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: palette.primary,
                    ),
                  ),

                  const Gap(12),

                  // Problem & Motivation Story
                  Text(
                    'We all know how challenging it can be to stick to a consistent '
                    'Bible reading plan. It’s easy to lose your place, forget to read '
                    'on a busy day. I personally struggled with maintaining a daily '
                    'reading habit and wanted a clean, dedicated tool just to track '
                    'my progress. That’s why I built Verso: to provide a simple, '
                    'focused way to log your reading, hold yourself accountable, '
                    'and build a lasting habit.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.65,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.85)
                          : palette.text,
                    ),
                  ),

                  const Gap(28),

                  // OUR MOTTO Card
                  _MottoCard(isDark: isDark, borderColor: borderColor),

                  const Gap(28),

                  // SECTION: Do you sell user data?
                  _SectionTitle(
                    title: 'Do you sell user data?',
                    isDark: isDark,
                    paletteText: palette.text,
                  ),
                  const Gap(10),
                  Text(
                    'Never. We do not sell, rent, or trade your personal data. '
                    'Your reading progress, streaks, habits, and profile are completely private '
                    'and securely protected. Your spiritual journey is yours alone.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      height: 1.65,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : palette.textMuted,
                    ),
                  ),

                  const Gap(28),

                  // SECTION: Is Verso free to use?
                  _SectionTitle(
                    title: 'Is Verso free to use?',
                    isDark: isDark,
                    paletteText: palette.text,
                  ),
                  const Gap(10),
                  Text(
                    'Yes! As of now, everything in Verso is completely free with zero ads and no paywalls. '
                    'All features—including multi-canon tracking, bilingual support, offline SQLite sync, '
                    'multi-account switching, AMOLED themes, and detailed analytics—are freely accessible '
                    'to every user.\n\n'
                    'As the app grows and cloud infrastructure costs expand, our model may evolve '
                    'in the future:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      height: 1.65,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : palette.textMuted,
                    ),
                  ),
                  const Gap(14),

                  // Pricing Model Points
                  _PricingModelCard(
                    isDark: isDark,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),

                  const Gap(28),

                  // SECTION: Permissions
                  _SectionTitle(
                    title: 'Why does Verso require permissions?',
                    isDark: isDark,
                    paletteText: palette.text,
                  ),
                  const Gap(10),
                  Text(
                    'Because this app is designed strictly for tracking (and does not '
                    'contain actual reading material), it is very lightweight. We only '
                    'request essential permissions required to run the core features. '
                    'Below is a breakdown of why we need them:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      height: 1.65,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : palette.textMuted,
                    ),
                  ),

                  const Gap(16),

                  // Permissions Accordions
                  _PermissionAccordion(
                    title: 'Notifications Permission',
                    subtitle: 'Custom daily reminders',
                    content:
                        'Allows us to send you custom daily reminders so you never '
                        'forget to log your reading. You control exactly when these '
                        'reminders are triggered.',
                    icon: Icons.notifications_active_outlined,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),

                  const Gap(10),

                  _PermissionAccordion(
                    title: 'Network Access',
                    subtitle: 'Cloud sync & multi-device backup',
                    content:
                        'Used exclusively to sync your reading progress, streaks, and account '
                        'settings with your secure cloud backup, ensuring your data is always safe.',
                    icon: Icons.wifi_rounded,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),

                  const Gap(16),

                  Text(
                    'Beyond these specified scenarios, the app does not access your personal '
                    'files, messages, or other device data.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : palette.textMuted.withValues(alpha: 0.8),
                    ),
                  ),

                  const Gap(32),

                  // Spread the Word Card
                  _SpreadTheWordCard(isDark: isDark, borderColor: borderColor),

                  const Gap(32),

                  // Contact Us Footer
                  _ContactFooter(isDark: isDark, paletteText: palette.text),

                  const Gap(48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mission Header (Clean navigation bar and creator credit - No photo)
// ---------------------------------------------------------------------------

class _MissionHeader extends StatelessWidget {
  const _MissionHeader({
    required this.bg,
    required this.isDark,
    required this.onClose,
  });

  final Color bg;
  final bool isDark;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 16),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : palette.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar: Mission Badge + Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 14,
                      color: palette.primary,
                    ),
                    const Gap(6),
                    Text(
                      'OUR MISSION',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: palette.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onClose();
                  },
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? Colors.white70 : palette.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          // Creator Attribution Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131518) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : palette.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.code_rounded,
                      color: palette.primary,
                      size: 20,
                    ),
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Shaijo George',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Developer of Verso',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.65)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Social Badges (LinkedIn, Portfolio, Website)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LinkedInButton(
                      onTap: () =>
                          _openUrl('https://linkedin.com/in/shaijogeorge'),
                    ),
                    const Gap(8),
                    _SocialIconButton(
                      icon: Icons.language_rounded,
                      tooltip: 'Portfolio',
                      isDark: isDark,
                      onTap: () => _openUrl('https://shaijogeorge.vercel.app/'),
                    ),
                    const Gap(8),
                    _SocialIconButton(
                      icon: Icons.public_rounded,
                      tooltip: 'Official Website',
                      isDark: isDark,
                      onTap: () =>
                          _openUrl('https://versobibletracker.netlify.app/'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      await launchUrl(uri);
    }
  } catch (_) {
    try {
      await launchUrl(uri);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// LinkedIn Official Rounded Badge
// ---------------------------------------------------------------------------

class _LinkedInButton extends StatelessWidget {
  const _LinkedInButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'LinkedIn',
      child: Material(
        color: const Color(0xFF0A66C2), // Official LinkedIn Blue
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(
                  painter: _LinkedInInPainter(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkedInInPainter extends CustomPainter {
  const _LinkedInInPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final scale = size.width / 100;
    canvas.save();
    canvas.scale(scale, scale);

    // 'i' dot
    canvas.drawCircle(const Offset(18.5, 17), 9.5, paint);

    // 'i' stem
    canvas.drawRect(const Rect.fromLTWH(9, 36, 19, 64), paint);

    // 'n' path
    final nPath = Path()
      ..moveTo(40.5, 36)
      ..lineTo(59.5, 36)
      ..lineTo(59.5, 46)
      ..cubicTo(65, 38.5, 74, 34, 84.5, 34)
      ..cubicTo(99, 34, 105.5, 44, 105.5, 60)
      ..lineTo(105.5, 100)
      ..lineTo(86.5, 100)
      ..lineTo(86.5, 64.5)
      ..cubicTo(86.5, 55, 83, 49.5, 74, 49.5)
      ..cubicTo(64.5, 49.5, 59.5, 56.5, 59.5, 66)
      ..lineTo(59.5, 100)
      ..lineTo(40.5, 100)
      ..close();

    canvas.drawPath(nPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Social Icon Button
// ---------------------------------------------------------------------------

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isDark = true,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.isDark,
    required this.paletteText,
  });

  final String title;
  final bool isDark;
  final Color paletteText;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: isDark ? Colors.white : paletteText,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OUR MOTTO Card
// ---------------------------------------------------------------------------

class _MottoCard extends StatelessWidget {
  const _MottoCard({required this.isDark, required this.borderColor});

  final bool isDark;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF131518) : const Color(0xFFF1F5F9);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'OUR MOTTO',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ),
          const Gap(14),
          Text(
            'Help people build a consistent Bible reading habit and track their progress',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 21,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pricing & Sustainability Model Card
// ---------------------------------------------------------------------------

class _PricingModelCard extends StatelessWidget {
  const _PricingModelCard({
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
  });

  final bool isDark;
  final Color cardBg;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _PricingItem(
            number: '1',
            title: '100% Free Today',
            description:
                'Every feature, canon, theme, and streak tool is fully accessible '
                'with zero paywalls and zero advertisements.',
            icon: Icons.lock_open_rounded,
            iconColor: const Color(0xFF10B981),
            isDark: isDark,
          ),
          Divider(
            height: 1,
            indent: 56,
            color: borderColor,
          ),
          _PricingItem(
            number: '2',
            title: 'Future Subscriptions & Sustainability',
            description:
                'As server costs and features expand, we may introduce optional '
                'premium subscriptions, supporter perks, or voluntary support to keep '
                'development sustainable. The core tracking experience will always remain accessible.',
            icon: Icons.stars_rounded,
            iconColor: const Color(0xFFF59E0B),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _PricingItem extends StatelessWidget {
  const _PricingItem({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  final String number;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const Gap(4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : const Color(0xFF475569),
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

// ---------------------------------------------------------------------------
// Interactive Permission Accordion
// ---------------------------------------------------------------------------

class _PermissionAccordion extends StatefulWidget {
  const _PermissionAccordion({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
  });

  final String title;
  final String subtitle;
  final String content;
  final IconData icon;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;

  @override
  State<_PermissionAccordion> createState() => _PermissionAccordionState();
}

class _PermissionAccordionState extends State<_PermissionAccordion>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: widget.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 16,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            widget.subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: widget.isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12, left: 44, right: 4),
                    child: Text(
                      widget.content,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.75)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spread the Word Card
// ---------------------------------------------------------------------------

class _SpreadTheWordCard extends StatelessWidget {
  const _SpreadTheWordCard({
    required this.isDark,
    required this.borderColor,
  });

  final bool isDark;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cardBg = isDark ? const Color(0xFF131518) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: palette.primary,
                  size: 19,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spread the Word',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : palette.text,
                      ),
                    ),
                    Text(
                      'Help a friend build a daily Scripture habit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: isDark ? Colors.white60 : palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(14),
          Text(
            'Since Verso is 100% free with zero ads, the best way to support '
            'the project is by sharing it with a friend, family member, or '
            'study group.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.55,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.78)
                  : palette.textMuted,
            ),
          ),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                VersoShareSheet.show(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(
                'Invite a Friend to Verso',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contact Us Footer
// ---------------------------------------------------------------------------

class _ContactFooter extends StatelessWidget {
  const _ContactFooter({required this.isDark, required this.paletteText});

  final bool isDark;
  final Color paletteText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'If you have further questions, you can ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.65)
                      : const Color(0xFF64748B),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final uri = Uri.parse(
                    'mailto:versoappsupport@gmail.com?subject=Verso%20Support%20%26%20Feedback',
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
                },
                child: Text(
                  'contact us',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    color: isDark ? Colors.white : paletteText,
                  ),
                ),
              ),
              Text(
                ' or visit our ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.65)
                      : const Color(0xFF64748B),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openUrl('https://versobibletracker.netlify.app/');
                },
                child: Text(
                  'website',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    color: isDark ? Colors.white : paletteText,
                  ),
                ),
              ),
              Text(
                '.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.65)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const Gap(14),
          Text(
            "Let's build a consistent Bible reading habit together.",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 16.5,
              fontStyle: FontStyle.italic,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
