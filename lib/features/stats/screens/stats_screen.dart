import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
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

    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: scheme.onPrimary,
            unselectedLabelColor: scheme.onSurfaceVariant,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            indicator: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
              Tab(text: 'Yearly'),
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
