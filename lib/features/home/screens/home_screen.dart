import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
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
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/home/providers/home_providers.dart';
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
                        width: 150,
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
                        width: 240,
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
              const Gap(Spacing.md),

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
              const Gap(Spacing.lg),

              // QUICK STATS
              statsAsync.when(
                loading: () => const _QuickStatsRowSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => _QuickStatsRow(stats: stats),
              ),
              const Gap(Spacing.xl),

              // THIS WEEK
              if (detailedAsync.hasValue) ...[
                VersoSectionHeader(
                  title: 'This week',
                  action: 'Details',
                  onAction: () => context.go('/stats?tab=weekly'),
                ),
                const Gap(Spacing.md),
                _WeeklyChart(
                  counts: detailedAsync.value!.last7DaysCounts,
                  dates: detailedAsync.value!.last7DaysDates,
                ),
                const Gap(Spacing.xl),
              ],

              // CONTINUE READING
              if (continueAsync.hasValue && continueAsync.value != null) ...[
                const VersoSectionHeader(title: 'Continue reading'),
                const Gap(Spacing.md),
                _ContinueReadingCard(info: continueAsync.value!),
                const Gap(Spacing.xl),
              ],

              // RECENT ACTIVITY
              if (activityAsync.hasValue &&
                  activityAsync.value!.isNotEmpty) ...[
                VersoSectionHeader(
                  title: 'Recent activity',
                  action: 'See all',
                  onAction: () => context.go('/history'),
                ),
                const Gap(Spacing.md),
                _RecentActivityList(
                  groups: activityAsync.value!.values
                      .expand((g) => g)
                      .take(3)
                      .toList(),
                ),
              ],

              // Extra space so content isn't hidden behind the floating nav bar
              const Gap(100),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${getGreeting()}, $userName',
          style: textTheme.headlineLarge,
        ),
        const Gap(Spacing.xs),
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
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final circleSize = isNarrow ? 102.0 : 124.0;
        final strokeWidth = isNarrow ? 8.0 : 10.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isNarrow ? Spacing.md : Spacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLight
                  ? [
                      scheme.primary,
                      scheme.primary.withValues(alpha: 0.85),
                    ]
                  : [
                      scheme.primaryContainer,
                      scheme.primaryContainer.withValues(alpha: 0.7),
                    ],
            ),
            borderRadius: AppRadii.borderRadiusXL,
            boxShadow: AppShadows.lg,
          ),
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
                        ? Colors.white.withValues(alpha: 0.2)
                        : scheme.primary.withValues(alpha: 0.2),
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'complete',
                          style: textTheme.labelSmall?.copyWith(
                            color: isLight
                                ? Colors.white.withValues(alpha: 0.8)
                                : scheme.onPrimaryContainer
                                    .withValues(alpha: 0.7),
                            fontSize: isNarrow ? 10 : null,
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
                    Text(
                      'Bible journey',
                      style: (isNarrow
                              ? textTheme.titleSmall
                              : textTheme.titleMedium)
                          ?.copyWith(
                        color:
                            isLight ? Colors.white : scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(Spacing.sm),
                    _HeroStatRow(
                      icon: Icons.emoji_events_rounded,
                      text:
                          '${stats.booksCompleted}/${stats.totalBooksInCanon} Books',
                      isLight: isLight,
                      scheme: scheme,
                    ),
                    const Gap(Spacing.xs),
                    _HeroStatRow(
                      icon: Icons.menu_book_rounded,
                      text:
                          '${stats.totalChaptersRead}/${stats.totalChaptersInCanon} Chapters',
                      isLight: isLight,
                      scheme: scheme,
                    ),
                    if (todayCount > 0) ...[
                      const Gap(Spacing.xs),
                      _HeroStatRow(
                        icon: Icons.today_rounded,
                        text:
                            '$todayCount Chapter${todayCount == 1 ? '' : 's'} Today',
                        isLight: isLight,
                        scheme: scheme,
                      ),
                    ],
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
  });
  final IconData icon;
  final String text;
  final bool isLight;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final color = isLight
        ? Colors.white.withValues(alpha: 0.9)
        : scheme.onPrimaryContainer.withValues(alpha: 0.8);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const Gap(Spacing.sm),
        Flexible(
          child: Text(
            text,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
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
            label: 'Day streak',
            iconColor: isLight ? AppColors.streakLight : AppColors.streakDark,
            bgColor: isLight
                ? AppColors.streakLight.withValues(alpha: 0.1)
                : AppColors.streakDark.withValues(alpha: 0.15),
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
            bgColor: isLight
                ? AppColors.chaptersLight.withValues(alpha: 0.1)
                : AppColors.chaptersDark.withValues(alpha: 0.15),
          ),
        ),
        const Gap(Spacing.sm),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.emoji_events_rounded,
            value: '${stats.booksCompleted}',
            label: 'Books',
            iconColor: isLight ? AppColors.booksLight : AppColors.booksDark,
            bgColor: isLight
                ? AppColors.booksLight.withValues(alpha: 0.1)
                : AppColors.booksDark.withValues(alpha: 0.15),
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
    required this.bgColor,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.md,
        horizontal: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.borderRadiusLG,
        border: Border.all(
          color: isAmoled
              ? scheme.outline
              : scheme.outline.withValues(alpha: isLight ? 0.5 : 0.15),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadii.borderRadiusSM,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const Gap(Spacing.sm),
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
                    fontWeight: FontWeight.bold,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WEEKLY CHART (mini bar chart)
// ─────────────────────────────────────────────────────────────────────────────

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

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return VersoCard(
      child: Column(
        children: [
          // Summary row
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$total chapters',
              style: textTheme.titleSmall,
            ),
          ),
          const Gap(Spacing.md),

          // Bar chart
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final isToday = dates[i].year == today.year &&
                    dates[i].month == today.month &&
                    dates[i].day == today.day;
                final fraction = maxCount > 0 ? counts[i] / maxCount : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (counts[i] > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${counts[i]}',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: fraction),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) {
                            return Container(
                              height: (val * 60).clamp(4.0, 60.0),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? scheme.primary
                                    : (counts[i] > 0
                                        ? scheme.primary.withValues(alpha: 0.4)
                                        : scheme.surfaceContainerHighest),
                                borderRadius: AppRadii.borderRadiusXS,
                              ),
                            );
                          },
                        ),
                        const Gap(Spacing.xs),
                        Text(
                          dayLabels[dates[i].weekday - 1],
                          style: textTheme.labelSmall?.copyWith(
                            color: isToday
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                            fontWeight: isToday ? FontWeight.bold : null,
                            fontSize: 11,
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

// ─────────────────────────────────────────────────────────────────────────────
// CONTINUE READING CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.info});
  final ContinueReadingInfo info;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isOT = info.book.testament.name == 'old';

    return VersoCard(
      onTap: () => context.push('/book/${info.book.id}'),
      child: Row(
        children: [
          // Book icon with testament color
          Builder(
            builder: (context) {
              final isLight = Theme.of(context).brightness == Brightness.light;
              final testamentColor = isOT
                  ? (isLight ? AppColors.otColorLight : AppColors.otColorDark)
                  : (isLight ? AppColors.ntColorLight : AppColors.ntColorDark);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: testamentColor.withValues(alpha: 0.1),
                  borderRadius: AppRadii.borderRadiusMD,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: testamentColor,
                  size: 28,
                ),
              );
            },
          ),
          const Gap(Spacing.md),

          // Book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.book.name,
                  style: textTheme.titleSmall,
                ),
                const Gap(2),
                Text(
                  '${info.chaptersRead} of ${info.book.chapters} chapters',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Gap(Spacing.sm),
                VersoProgressBar(
                  value: info.progress,
                  height: 6,
                  color: isOT
                      ? (Theme.of(context).brightness == Brightness.light
                          ? AppColors.otColorLight
                          : AppColors.otColorDark)
                      : (Theme.of(context).brightness == Brightness.light
                          ? AppColors.ntColorLight
                          : AppColors.ntColorDark),
                ),
              ],
            ),
          ),
          const Gap(Spacing.sm),

          // Arrow
          Icon(
            Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECENT ACTIVITY LIST
// ─────────────────────────────────────────────────────────────────────────────

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.groups});
  final List<ActivityGroup> groups;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: groups.map((group) {
        final isFinish = group.isFinish;

        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: VersoCard(
            border: isFinish
                ? Border.all(
                    color: scheme.secondary.withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFinish
                        ? scheme.secondaryContainer
                        : scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFinish
                        ? Icons.emoji_events_rounded
                        : Icons.auto_stories_rounded,
                    size: 18,
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
                          Text(
                            group.book.name,
                            style: textTheme.titleSmall,
                          ),
                          if (isFinish) ...[
                            const Gap(Spacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: AppRadii.borderRadiusXS,
                              ),
                              child: Text(
                                'Completed',
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.secondary,
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

                // Time
                Text(
                  _formatTime(group.timestamp),
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
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

class _DailyVerseCard extends StatelessWidget {
  const _DailyVerseCard({required this.verseAsync});
  final AsyncValue<Map<String, dynamic>> verseAsync;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

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
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(Spacing.sm),
                  Container(width: 100, height: 10, color: Colors.white),
                ],
              ),
              const Gap(Spacing.md),
              Container(
                width: double.infinity,
                height: 14,
                color: Colors.white,
              ),
              const Gap(6),
              Container(width: 200, height: 14, color: Colors.white),
              const Gap(Spacing.lg),
              Container(width: 80, height: 10, color: Colors.white),
            ],
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (verse) {
        return _buildShell(
          scheme: scheme,
          isLight: isLight,
          isAmoled: isAmoled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow label
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(Spacing.sm),
                  Text(
                    'VERSE OF THE DAY',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const Gap(Spacing.md),
              // Verse text - DM Serif Display
              Text(
                verse['text'] as String,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                  height: 1.45,
                  color: isLight
                      ? scheme.onSurface.withValues(alpha: 0.92)
                      : const Color(0xFFF5EFE3).withValues(alpha: 0.95),
                ),
              ),
              const Gap(Spacing.md),
              // Gold hairline rule
              Container(
                width: 32,
                height: 1,
                color: scheme.secondary.withValues(alpha: 0.7),
              ),
              const Gap(Spacing.sm),
              // Reference
              Text(
                (verse['ref'] as String).toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.secondary,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
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
        ? [const Color(0xFF0A0A0E), Colors.black]
        : isLight
            ? [
                scheme.primaryContainer.withValues(alpha: 0.6),
                scheme.surface,
              ]
            : [
                scheme.primaryContainer.withValues(alpha: 0.55),
                scheme.surface,
              ];

    // Multi-layer shadow: elevation drop + warm gold ambient
    final shadows = isAmoled
        ? [
            BoxShadow(
              color: scheme.secondary.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 4),
            ),
          ]
        : [
            const BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: scheme.secondary.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 4),
            ),
          ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadii.borderRadiusXL,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(
          color: scheme.secondary.withValues(alpha: 0.28),
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
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.secondary.withValues(alpha: 0.16),
                    scheme.secondary.withValues(alpha: 0),
                  ],
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

// ─────────────────────────────────────────────────────────────────────────────
// SPECIFIC CARD SKELETONS (True Backgrounds, Shimmering Values)
// ─────────────────────────────────────────────────────────────────────────────

class _HeroProgressCardSkeleton extends StatelessWidget {
  const _HeroProgressCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Use specific highlight/base colors that look good over the primary gradient
    final baseColor = isLight
        ? Colors.white.withValues(alpha: 0.3)
        : scheme.onPrimaryContainer.withValues(alpha: 0.2);
    final highlightColor = isLight
        ? Colors.white.withValues(alpha: 0.6)
        : scheme.onPrimaryContainer.withValues(alpha: 0.4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [scheme.primary, scheme.primary.withValues(alpha: 0.85)]
              : [
                  scheme.primaryContainer,
                  scheme.primaryContainer.withValues(alpha: 0.7),
                ],
        ),
        borderRadius: AppRadii.borderRadiusXL,
        boxShadow: AppShadows.lg,
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Row(
          children: [
            // Shimmering circle outline
            Container(
              width: 130,
              height: 130,
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
                    width: 120,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Gap(16),
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
                  const Gap(8),
                  Container(
                    width: 100,
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
              : scheme.outline.withValues(alpha: isLight ? 0.5 : 0.15),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.borderRadiusSM,
              ),
            ),
            const Gap(Spacing.sm),
            Container(
              width: 40,
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
