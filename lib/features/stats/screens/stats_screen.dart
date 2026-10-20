import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/stats/providers/stats_providers.dart';
import 'package:verso/features/stats/tabs/monthly_tab.dart';
import 'package:verso/features/stats/tabs/overview_tab.dart';
import 'package:verso/features/stats/tabs/weekly_tab.dart';
import 'package:verso/features/stats/tabs/yearly_tab.dart';
import 'package:verso/features/stats/widgets/shimmer_skeletons.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void didUpdateWidget(StatsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _tabController.animateTo(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(detailedStatsProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

    // Reset to Overview tab whenever the user re-enters the Stats branch.
    ref.listen<int>(statsTabResetTriggerProvider, (_, __) {
      if (_tabController.index != 0) {
        _tabController.animateTo(0);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HABITS & INSIGHTS',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.primary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                  fontSize: 10,
                ),
              ),
              const Gap(4),
              Text(
                'Reading Analytics',
                style: textTheme.headlineLarge?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isAmoled
                ? scheme.surfaceContainerHighest
                : scheme.surfaceContainerHighest
                    .withValues(alpha: isLight ? 0.65 : 0.45),
            borderRadius: AppRadii.borderRadiusLG,
            border: Border.all(
              color: scheme.outline.withValues(alpha: isLight ? 0.4 : 0.15),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: scheme.primary,
            unselectedLabelColor: scheme.onSurfaceVariant,
            labelStyle:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            indicator: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: scheme.outline.withValues(alpha: isLight ? 0.5 : 0.25),
              ),
              boxShadow: isLight ? AppShadows.sm : null,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            tabs: const [
              Tab(height: 36, text: 'Overview'),
              Tab(height: 36, text: 'Weekly'),
              Tab(height: 36, text: 'Monthly'),
              Tab(height: 36, text: 'Yearly'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: statsAsync.when(
            loading: () => _ShimmerTabView(tabController: _tabController),
            error: (err, stack) => ErrorStateWidget(
              error: err,
              onRetry: () => ref.invalidate(detailedStatsProvider),
            ),
            data: (stats) => TabBarView(
              controller: _tabController,
              children: [
                OverviewTab(stats: stats),
                const WeeklyTab(),
                const MonthlyTab(),
                const YearlyTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows shimmer skeletons while data is loading — one per tab
class _ShimmerTabView extends StatelessWidget {
  const _ShimmerTabView({required this.tabController});
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: const [
        OverviewShimmer(),
        WeeklyShimmer(),
        MonthlyShimmer(),
        YearlyShimmer(),
      ],
    );
  }
}
