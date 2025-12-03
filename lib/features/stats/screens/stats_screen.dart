import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/stats_providers.dart';
import '../../../core/widgets/error_state_widget.dart';
import 'package:go_router/go_router.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    // No Scaffold, no AppBar here either
    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorStateWidget(
        error: err,
        onRetry: () => ref.invalidate(userStatsProvider),
      ),
      data: (stats) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Wrap the Circular Progress Bar in a GestureDetector
              GestureDetector(
                onTap: () {
                  // Navigate to Detailed Stats
                  context.push('/detailed-stats');
                },
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: DashedCircularProgressBar.aspectRatio(
                    aspectRatio: 1,
                    valueNotifier: ValueNotifier(stats.totalProgress),
                    progress: stats.totalProgress,
                    maxProgress: 100,
                    corners: StrokeCap.butt,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundStrokeWidth: 15,
                    backgroundStrokeWidth: 15,
                    animation: true,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${stats.totalProgress.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Bible Completed',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Gap(8),
                          // Optional: Add a small hint text
                          Text(
                            'Tap for details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(40),

                // Stats Grid (Streak & Chapters)
              Row(
                children: [
                    // Streak Card
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orange,
                      label: "Current Streak",
                      value: "${stats.streak} Days",
                    ),
                  ),
                  const Gap(16),
                    // Total Read Card
                  Expanded(
                    child: _StatCard(
                      icon: Icons.auto_stories,
                      iconColor: Colors.blue,
                      label: "Chapters Read",
                      value: "${stats.totalChaptersRead}",
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
}

// Keep the _StatCard class at the bottom as it was.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const Gap(8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}