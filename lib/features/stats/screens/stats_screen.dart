import '../../../core/design/components/verso_circular_progress.dart';
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
              // ANIMATED CIRCULAR PROGRESS
              // We use TweenAnimationBuilder to drive the value from 0 to actual progress
              TweenAnimationBuilder<double>(
                // Forces the animation to restart when stats object changes (identity)
                key: ValueKey(stats),
                tween: Tween<double>(begin: 0.0, end: stats.totalProgress),
                duration: const Duration(milliseconds: 1500), // 1.5 seconds animation
                curve: Curves.easeOutCubic, // Smooth slowdown at the end
                builder: (context, animatedProgress, child) {
                  return GestureDetector(
                    onTap: () {
                  // Navigate to Detailed Stats
                      context.push('/detailed-stats');
                    },
                    child: VersoCircularProgress(
                      progress: animatedProgress,
                      maxProgress: 100,
                      size: 220,
                      strokeWidth: 15,
                      color: Theme.of(context).colorScheme.primary,
                      trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${animatedProgress.toStringAsFixed(1)}%',
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
                  );
                },
              ),
              const Gap(40),

              // ANIMATED STAT CARDS
              Row(
                children: [
                  // Streak Card (Counts up from 0)
                  Expanded(
                    child: TweenAnimationBuilder<int>(
                      // Forces restart
                      key: ValueKey("streak_${stats.streak}"),
                      tween: IntTween(begin: 0, end: stats.streak),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedStreak, _) {
                        return _StatCard(
                          icon: Icons.local_fire_department,
                          iconColor: Colors.orange,
                          label: "Current Streak",
                          value: "$animatedStreak Days",
                        );
                      },
                    ),
                  ),
                  const Gap(16),
                  
                  // Chapters Read Card (Counts up from 0)
                  Expanded(
                    child: TweenAnimationBuilder<int>(
                      // Forces restart
                      key: ValueKey("chapters_${stats.totalChaptersRead}"),
                      tween: IntTween(begin: 0, end: stats.totalChaptersRead),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedChapters, _) {
                        return _StatCard(
                          icon: Icons.auto_stories,
                          iconColor: Colors.blue,
                          label: "Chapters Read",
                          value: "$animatedChapters",
                        );
                      },
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