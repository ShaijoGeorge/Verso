import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:verso/core/design/components/verso_card.dart';
import 'package:verso/core/design/components/verso_circular_progress.dart';
import 'package:verso/core/design/components/verso_progress_bar.dart';
import 'package:verso/core/design/components/verso_section_header.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/colors.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
import 'package:verso/core/design/tokens/spacing.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
import 'package:verso/data/bible_book_names.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/home/data/daily_verse.dart';
import 'package:verso/features/home/providers/home_providers.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/stats/providers/activity_providers.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final detailedAsync = ref.watch(detailedStatsProvider);
    final continueAsync = ref.watch(continueReadingProvider);
    final activityAsync = ref.watch(activityLogProvider);
    final todayAsync = ref.watch(todayChaptersProvider);
    final userName = ref.watch(userNameProvider);
    final verseAsync = ref.watch(dailyVerseProvider);

    final isLight = Theme.of(context).brightness == Brightness.light;
    final baseColor = isLight ? Colors.grey[300]! : Colors.grey[800]!;
    final highlightColor = isLight ? Colors.grey[100]! : Colors.grey[700]!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GREETING
              statsAsync.when(
                loading: () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        width: 110,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        width: 200,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        width: 260,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                error: (err, stack) => ErrorStateWidget(
                  error: err,
                  onRetry: () => ref.invalidate(userStatsProvider),
                ),
                data: (stats) {
                  final todayCount = todayAsync.whenData((v) => v).value ?? 0;
                  return _GreetingSection(
                    userName: userName,
                    streak: stats.streak,
                    progress: stats.totalProgress,
                    todayCount: todayCount,
                  );
                },
              ),
              const Gap(Spacing.lg),

              // DAILY VERSE
              _DailyVerseCard(verseAsync: verseAsync),
              const Gap(Spacing.lg),

              // HERO PROGRESS CARD
              statsAsync.when(
                loading: () => const _HeroProgressCardSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) {
                  final todayCount = todayAsync.whenData((v) => v).value ?? 0;
                  return _HeroProgressCard(
                    stats: stats,
                    todayCount: todayCount,
                  );
                },
              ),
              const Gap(Spacing.md),

              // QUICK STATS
              statsAsync.when(
                loading: () => const _QuickStatsRowSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => _QuickStatsRow(stats: stats),
              ),
              const Gap(Spacing.xl),

              // THIS WEEK
              detailedAsync.when(
                data: (detailed) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VersoSectionHeader(
                      title: 'This Week',
                      action: 'Details',
                      onAction: () => context.go('/stats?tab=weekly'),
                    ),
                    const Gap(Spacing.md),
                    _WeeklyChart(
                      counts: detailed.last7DaysCounts,
                      dates: detailed.last7DaysDates,
                    ),
                    const Gap(Spacing.xl),
                  ],
                ),
                error: (err, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VersoSectionHeader(title: 'This Week'),
                    const Gap(Spacing.md),
                    _InlineErrorCard(
                      title: 'weekly stats',
                      onRetry: () => ref.invalidate(detailedStatsProvider),
                    ),
                    const Gap(Spacing.xl),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
              ),

              // CONTINUE READING
              continueAsync.when(
                data: (info) => info != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const VersoSectionHeader(title: 'Continue Reading'),
                          const Gap(Spacing.md),
                          _ContinueReadingCard(info: info),
                          const Gap(Spacing.xl),
                        ],
                      )
                    : const SizedBox.shrink(),
                error: (err, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VersoSectionHeader(title: 'Continue Reading'),
                    const Gap(Spacing.md),
                    _InlineErrorCard(
                      title: 'reading progress',
                      onRetry: () => ref.invalidate(continueReadingProvider),
                    ),
                    const Gap(Spacing.xl),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
              ),

              // RECENT ACTIVITY
              activityAsync.when(
                data: (groups) => groups.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VersoSectionHeader(
                            title: 'Recent Activity',
                            action: 'See All',
                            onAction: () => context.go('/history'),
                          ),
                          const Gap(Spacing.md),
                          _RecentActivityList(
                            groups:
                                groups.values.expand((g) => g).take(3).toList(),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                error: (err, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VersoSectionHeader(title: 'Recent Activity'),
                    const Gap(Spacing.md),
                    _InlineErrorCard(
                      title: 'activity log',
                      onRetry: () => ref.invalidate(activityLogProvider),
                    ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
              ),

              // Extra space so content isn't hidden behind the floating nav bar
              const Gap(110),
            ],
          ),
        ),
      ),
    );
  }
}

// GREETING SECTION

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({
    required this.userName,
    required this.streak,
    required this.progress,
    required this.todayCount,
  });
  final String userName;
  final int streak;
  final double progress;
  final int todayCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat('EEEE, MMM d').format(DateTime.now());
    final streakColor = context.appColors.streak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top date eyebrow + live streak badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: scheme.primary.withValues(alpha: 0.75),
                ),
                const Gap(6),
                Text(
                  dateStr.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.primary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
            if (streak > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: streakColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.borderRadiusFull,
                  border: Border.all(
                    color: streakColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: streakColor,
                    ),
                    const Gap(4),
                    Text(
                      '$streak Day Streak',
                      style: textTheme.labelSmall?.copyWith(
                        color: streakColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const Gap(8),
        Text(
          '${getGreeting()}, $userName',
          style: textTheme.displaySmall?.copyWith(
            color: scheme.onSurface,
            height: 1.15,
          ),
        ),
        const Gap(6),
        Text(
          getMotivationalMessage(streak, progress, todayCount),
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// HERO PROGRESS CARD

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({required this.stats, required this.todayCount});
  final UserStats stats;
  final int todayCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final circleSize = isNarrow ? 104.0 : 124.0;
        final strokeWidth = isNarrow ? 8.5 : 10.0;

        return Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLight
                  ? [
                      palette.primary,
                      palette.primaryHover,
                    ]
                  : [
                      palette.accentSoft,
                      scheme.surface,
                    ],
            ),
            borderRadius: AppRadii.borderRadiusXL,
            border: Border.all(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.14)
                  : palette.primary.withValues(alpha: 0.25),
            ),
            boxShadow: isLight
                ? AppShadows.glow(palette.primary, opacity: 0.22)
                : AppShadows.md,
          ),
          child: Stack(
            children: [
              // Decorative architectural light rings
              Positioned(
                right: -45,
                top: -45,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isLight ? Colors.white : palette.primary)
                          .withValues(alpha: 0.08),
                      width: 24,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -50,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        palette.secondary.withValues(alpha: 0.16),
                        palette.secondary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(isNarrow ? Spacing.md : Spacing.lg),
                child: Row(
                  children: [
                    // Progress circle
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: stats.totalProgress),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedProgress, _) {
                        return VersoCircularProgress(
                          progress: animatedProgress,
                          size: circleSize,
                          strokeWidth: strokeWidth,
                          color: isLight ? Colors.white : scheme.primary,
                          trackColor: isLight
                              ? Colors.white.withValues(alpha: 0.18)
                              : scheme.primary.withValues(alpha: 0.18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${animatedProgress.toStringAsFixed(1)}%',
                                  style: (isNarrow
                                          ? textTheme.titleMedium
                                          : textTheme.titleLarge)
                                      ?.copyWith(
                                    color: isLight
                                        ? Colors.white
                                        : scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              Text(
                                'COMPLETE',
                                style: textTheme.labelSmall?.copyWith(
                                  color: isLight
                                      ? Colors.white.withValues(alpha: 0.75)
                                      : scheme.onPrimaryContainer
                                          .withValues(alpha: 0.65),
                                  fontSize: isNarrow ? 8.5 : 9.5,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Gap(isNarrow ? Spacing.md : Spacing.lg),

                    // Right side info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : scheme.primary.withValues(alpha: 0.15),
                              borderRadius: AppRadii.borderRadiusFull,
                            ),
                            child: Text(
                              'OVERALL PROGRESS',
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 9.5,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w700,
                                color: isLight
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : scheme.primary,
                              ),
                            ),
                          ),
                          const Gap(6),
                          Text(
                            'Bible Journey',
                            style: (isNarrow
                                    ? textTheme.titleMedium
                                    : textTheme.headlineSmall)
                                ?.copyWith(
                              color: isLight
                                  ? Colors.white
                                  : scheme.onPrimaryContainer,
                            ),
                          ),
                          const Gap(Spacing.sm),
                          _HeroStatRow(
                            icon: Icons.emoji_events_rounded,
                            text:
                                '${stats.booksCompleted} / ${stats.totalBooksInCanon} Books',
                            isLight: isLight,
                            scheme: scheme,
                          ),
                          const Gap(6),
                          _HeroStatRow(
                            icon: Icons.menu_book_rounded,
                            text:
                                '${stats.totalChaptersRead} / ${stats.totalChaptersInCanon} Chapters',
                            isLight: isLight,
                            scheme: scheme,
                          ),
                          if (todayCount > 0) ...[
                            const Gap(6),
                            _HeroStatRow(
                              icon: Icons.bolt_rounded,
                              text:
                                  '+$todayCount Chapter${todayCount == 1 ? '' : 's'} Today',
                              isLight: isLight,
                              scheme: scheme,
                              isHighlight: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroStatRow extends StatelessWidget {
  const _HeroStatRow({
    required this.icon,
    required this.text,
    required this.isLight,
    required this.scheme,
    this.isHighlight = false,
  });
  final IconData icon;
  final String text;
  final bool isLight;
  final ColorScheme scheme;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final color = isLight
        ? Colors.white.withValues(alpha: isHighlight ? 1.0 : 0.9)
        : (isHighlight
            ? scheme.primary
            : scheme.onPrimaryContainer.withValues(alpha: 0.85));

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white.withValues(alpha: 0.14)
                : scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const Gap(8),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

// QUICK STATS ROW

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.stats});
  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.local_fire_department_rounded,
            value: '${stats.streak}',
            label: 'Day Streak',
            iconColor: isLight ? AppColors.streakLight : AppColors.streakDark,
          ),
        ),
        const Gap(Spacing.sm),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.auto_stories_rounded,
            value: '${stats.totalChaptersRead}',
            label: 'Chapters',
            iconColor:
                isLight ? AppColors.chaptersLight : AppColors.chaptersDark,
          ),
        ),
        const Gap(Spacing.sm),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.emoji_events_rounded,
            value: '${stats.booksCompleted}',
            label: 'Books Done',
            iconColor: isLight ? AppColors.booksLight : AppColors.booksDark,
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
          // Top-right ambient color glow
          Positioned(
            top: -18,
            right: -18,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    iconColor.withValues(alpha: isLight ? 0.16 : 0.22),
                    iconColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 10,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isLight ? 0.1 : 0.16),
                      borderRadius: AppRadii.borderRadiusSM,
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(icon, size: 19, color: iconColor),
                  ),
                  const Gap(10),
                  TweenAnimationBuilder<int>(
                    key: ValueKey('stat_$label'),
                    tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedVal, _) {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$animatedVal',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      );
                    },
                  ),
                  const Gap(2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
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
}

// WEEKLY CHART (mini bar chart)

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.counts, required this.dates});
  final List<int> counts;
  final List<DateTime> dates;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final total = counts.reduce((a, b) => a + b);
    final activeDays = counts.where((c) => c > 0).length;

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return VersoCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        children: [
          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total ${total == 1 ? 'Chapter' : 'Chapters'}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    'Last 7 days · $activeDays/7 days active',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadii.borderRadiusFull,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 14,
                      color: scheme.primary,
                    ),
                    const Gap(4),
                    Text(
                      '7-Day Rhythm',
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(Spacing.lg),

          // Bar chart
          SizedBox(
            height: 112,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final isToday = dates[i].year == today.year &&
                    dates[i].month == today.month &&
                    dates[i].day == today.day;
                final fraction = maxCount > 0 ? counts[i] / maxCount : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (counts[i] > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              '${counts[i]}',
                              style: textTheme.labelSmall?.copyWith(
                                color: isToday
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: fraction),
                          duration: const Duration(milliseconds: 850),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) {
                            return Container(
                              height: (val * 64).clamp(6.0, 64.0),
                              decoration: BoxDecoration(
                                gradient: isToday
                                    ? LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          scheme.primary,
                                          context.palette.primaryHover,
                                        ],
                                      )
                                    : (counts[i] > 0
                                        ? LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              scheme.primary
                                                  .withValues(alpha: 0.45),
                                              scheme.primary
                                                  .withValues(alpha: 0.28),
                                            ],
                                          )
                                        : null),
                                color: !isToday && counts[i] == 0
                                    ? scheme.surfaceContainerHighest
                                        .withValues(alpha: 0.7)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isToday && counts[i] > 0
                                    ? [
                                        BoxShadow(
                                          color: scheme.primary
                                              .withValues(alpha: 0.28),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          },
                        ),
                        const Gap(6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isToday
                                ? scheme.primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: AppRadii.borderRadiusFull,
                          ),
                          child: Text(
                            dayLabels[dates[i].weekday - 1],
                            style: textTheme.labelSmall?.copyWith(
                              color: isToday
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              fontWeight:
                                  isToday ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// CONTINUE READING CARD

class _ContinueReadingCard extends ConsumerWidget {
  const _ContinueReadingCard({required this.info});
  final ContinueReadingInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isOT = info.book.testament.name == 'old';
    final testamentColor = isOT
        ? (isLight ? AppColors.otColorLight : AppColors.otColorDark)
        : (isLight ? AppColors.ntColorLight : AppColors.ntColorDark);

    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;
    final pct = (info.progress * 100).toInt();

    return VersoCard(
      onTap: () => context.push('/book/${info.book.id}'),
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          // Book icon with testament color
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  testamentColor.withValues(alpha: 0.18),
                  testamentColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: AppRadii.borderRadiusMD,
              border: Border.all(
                color: testamentColor.withValues(alpha: 0.28),
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: testamentColor,
              size: 26,
            ),
          ),
          const Gap(Spacing.md),

          // Book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        info.book.getLocalizedName(bibleLanguage, canon),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: testamentColor.withValues(alpha: 0.12),
                        borderRadius: AppRadii.borderRadiusFull,
                      ),
                      child: Text(
                        '$pct%',
                        style: textTheme.labelSmall?.copyWith(
                          color: testamentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(3),
                Text(
                  '${info.chaptersRead} of ${info.book.chapters} chapters completed',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Gap(10),
                VersoProgressBar(
                  value: info.progress,
                  height: 6,
                  color: testamentColor,
                ),
              ],
            ),
          ),
          const Gap(Spacing.md),

          // Arrow
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
            ),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECENT ACTIVITY LIST
// ─────────────────────────────────────────────────────────────────────────────

class _RecentActivityList extends ConsumerWidget {
  const _RecentActivityList({required this.groups});
  final List<ActivityGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;

    return Column(
      children: groups.map((group) {
        final isFinish = group.isFinish;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: VersoCard(
            onTap: () => context.push('/book/${group.book.id}'),
            border: isFinish
                ? Border.all(
                    color: scheme.secondary.withValues(alpha: 0.45),
                    width: 1.5,
                  )
                : null,
            child: Row(
              children: [
                // Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isFinish
                        ? scheme.secondaryContainer
                        : scheme.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: AppRadii.borderRadiusSM,
                    border: Border.all(
                      color: (isFinish ? scheme.secondary : scheme.primary)
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    isFinish
                        ? Icons.emoji_events_rounded
                        : Icons.auto_stories_rounded,
                    size: 19,
                    color: isFinish ? scheme.secondary : scheme.primary,
                  ),
                ),
                const Gap(Spacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              group.book.getLocalizedName(bibleLanguage, canon),
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isFinish) ...[
                            const Gap(Spacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: AppRadii.borderRadiusFull,
                              ),
                              child: Text(
                                'Completed',
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.secondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Gap(2),
                      Text(
                        group.description,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const Gap(8),
                // Time
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: AppRadii.borderRadiusXS,
                  ),
                  child: Text(
                    _formatTime(group.timestamp),
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dt.year, dt.month, dt.day);

    if (dateOnly == today) {
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (dateOnly == yesterday) return 'Yesterday';

    final diff = today.difference(dateOnly).inDays;
    if (diff < 7) return '${diff}d ago';

    return '${dt.month}/${dt.day}';
  }
}

// DAILY VERSE CARD

class _DailyVerseCard extends ConsumerWidget {
  const _DailyVerseCard({required this.verseAsync});
  final AsyncValue<DailyVerse> verseAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

    final settings = ref.watch(currentSettingsProvider).value;
    final lang = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;
    final isMalayalam = lang == 'ml';

    return verseAsync.when(
      loading: () => _buildShell(
        scheme: scheme,
        isLight: isLight,
        isAmoled: isAmoled,
        child: Shimmer.fromColors(
          baseColor: isLight ? Colors.grey[300]! : Colors.grey[800]!,
          highlightColor: isLight ? Colors.grey[100]! : Colors.grey[700]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.borderRadiusFull,
                ),
              ),
              const Gap(Spacing.md),
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              const Gap(8),
              Container(width: 220, height: 16, color: Colors.white),
              const Gap(Spacing.lg),
              Container(width: 90, height: 12, color: Colors.white),
            ],
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (verse) {
        final verseText = verse.getText(lang, canon);
        final verseRef = verse.getReference(lang, canon);

        return _buildShell(
          scheme: scheme,
          isLight: isLight,
          isAmoled: isAmoled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.14),
                  borderRadius: AppRadii.borderRadiusFull,
                  border: Border.all(
                    color: scheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 12,
                      color: scheme.secondary,
                    ),
                    const Gap(6),
                    Text(
                      isMalayalam ? 'ഇന്നത്തെ വചനം' : 'VERSE OF THE DAY',
                      style: isMalayalam
                          ? GoogleFonts.anekMalayalam(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: scheme.secondary,
                            )
                          : textTheme.labelSmall?.copyWith(
                              color: scheme.secondary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                            ),
                    ),
                  ],
                ),
              ),
              const Gap(Spacing.md),
              // Verse text
              Text(
                verseText,
                style: isMalayalam
                    ? GoogleFonts.anekMalayalam(
                        fontSize: 18.5,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: isLight
                            ? scheme.onSurface.withValues(alpha: 0.94)
                            : const Color(0xFFF8F4EC).withValues(alpha: 0.96),
                      )
                    : textTheme.headlineMedium?.copyWith(
                        fontSize: 20.5,
                        height: 1.45,
                        color: isLight
                            ? scheme.onSurface.withValues(alpha: 0.94)
                            : const Color(0xFFF8F4EC).withValues(alpha: 0.96),
                      ),
              ),
              const Gap(Spacing.md),
              // Reference
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: scheme.secondary.withValues(alpha: 0.8),
                      borderRadius: AppRadii.borderRadiusFull,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    isMalayalam ? verseRef : verseRef.toUpperCase(),
                    style: isMalayalam
                        ? GoogleFonts.anekMalayalam(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: scheme.secondary,
                            letterSpacing: 0.6,
                          )
                        : textTheme.labelSmall?.copyWith(
                            color: scheme.secondary,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShell({
    required ColorScheme scheme,
    required bool isLight,
    required bool isAmoled,
    required Widget child,
  }) {
    // Theme-adaptive gradient stops
    final gradientColors = isAmoled
        ? [const Color(0xFF0B0D14), Colors.black]
        : isLight
            ? [
                scheme.surface,
                scheme.primaryContainer.withValues(alpha: 0.45),
              ]
            : [
                scheme.surface,
                scheme.primaryContainer.withValues(alpha: 0.5),
              ];

    // Multi-layer shadow: elevation drop + warm gold ambient
    final shadows = isAmoled
        ? [
            BoxShadow(
              color: scheme.secondary.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 4),
            ),
          ]
        : [
            ...AppShadows.md,
            BoxShadow(
              color: scheme.secondary.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, 4),
            ),
          ];

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppRadii.borderRadiusXL,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(
          color: scheme.secondary.withValues(alpha: isLight ? 0.35 : 0.28),
        ),
        boxShadow: shadows,
      ),
      child: Stack(
        children: [
          // Soft gold radial glow at top-right
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.secondary.withValues(alpha: 0.18),
                    scheme.secondary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Oversized decorative serif quotation watermark
          Positioned(
            right: 16,
            bottom: -36,
            child: IgnorePointer(
              child: Text(
                '“',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 130,
                  height: 1,
                  color: scheme.secondary.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }
}

// SPECIFIC CARD SKELETONS (True Backgrounds, Shimmering Values)

class _HeroProgressCardSkeleton extends StatelessWidget {
  const _HeroProgressCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Use specific highlight/base colors that look good over the primary gradient
    final baseColor = isLight
        ? Colors.white.withValues(alpha: 0.28)
        : scheme.onPrimaryContainer.withValues(alpha: 0.18);
    final highlightColor = isLight
        ? Colors.white.withValues(alpha: 0.55)
        : scheme.onPrimaryContainer.withValues(alpha: 0.35);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [palette.primary, palette.primaryHover]
              : [palette.accentSoft, scheme.surface],
        ),
        borderRadius: AppRadii.borderRadiusXL,
        boxShadow: AppShadows.md,
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Row(
          children: [
            // Shimmering circle outline
            Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 10),
              ),
            ),
            const Gap(Spacing.lg),
            // Shimmering text lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 110,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Gap(10),
                  Container(
                    width: 130,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Gap(14),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Gap(8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
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

class _QuickStatsRowSkeleton extends StatelessWidget {
  const _QuickStatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _QuickStatCardSkeleton()),
        Gap(Spacing.sm),
        Expanded(child: _QuickStatCardSkeleton()),
        Gap(Spacing.sm),
        Expanded(child: _QuickStatCardSkeleton()),
      ],
    );
  }
}

class _QuickStatCardSkeleton extends StatelessWidget {
  const _QuickStatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

    final baseColor = isLight ? Colors.grey[300]! : Colors.grey[800]!;
    final highlightColor = isLight ? Colors.grey[100]! : Colors.grey[700]!;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.md,
        horizontal: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.borderRadiusLG,
        border: Border.all(
          color: isAmoled
              ? scheme.outline
              : scheme.outline.withValues(alpha: isLight ? 0.65 : 0.25),
        ),
        boxShadow: isLight ? AppShadows.sm : AppShadows.none,
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.borderRadiusSM,
              ),
            ),
            const Gap(Spacing.sm),
            Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Gap(4),
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INLINE ERROR CARD
// ─────────────────────────────────────────────────────────────────────────────

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.title, required this.onRetry});
  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return VersoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.error, size: 20),
          const Gap(12),
          Expanded(
            child: Text(
              'Could not load $title',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
