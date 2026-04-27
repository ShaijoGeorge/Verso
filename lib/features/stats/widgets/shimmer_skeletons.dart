import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';
import 'package:verso/core/design/tokens/colors.dart';

/// Shimmer skeleton for the Overview tab
class OverviewShimmer extends StatelessWidget {
  const OverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: _ShimmerWrap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // OT/NT rings placeholder
            const _ShimmerBox(height: 180, borderRadius: 20),
            const Gap(28),

            // 4 summary cards
            const Row(
              children: [
                Expanded(child: _ShimmerBox(height: 120, borderRadius: 16)),
                Gap(12),
                Expanded(child: _ShimmerBox(height: 120, borderRadius: 16)),
              ],
            ),
            const Gap(12),
            const Row(
              children: [
                Expanded(child: _ShimmerBox(height: 120, borderRadius: 16)),
                Gap(12),
                Expanded(child: _ShimmerBox(height: 120, borderRadius: 16)),
              ],
            ),
            const Gap(28),

            // Section header
            const _ShimmerBox(width: 140, height: 16, borderRadius: 4),
            const Gap(4),
            const _ShimmerBox(width: 220, height: 12, borderRadius: 4),
            const Gap(16),

            // Book grid placeholder (3 rows of boxes)
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: List.generate(
                    10,
                    (_) => const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _ShimmerBox(borderRadius: 4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the Weekly tab
class WeeklyShimmer extends StatelessWidget {
  const WeeklyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: _ShimmerWrap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ShimmerBox(width: 100, height: 16, borderRadius: 4),
            const Gap(4),
            const _ShimmerBox(width: 200, height: 14, borderRadius: 4),
            const Gap(24),
            const _ShimmerBox(height: 280, borderRadius: 12),
            const Gap(24),
            // Daily breakdown rows
            ...List.generate(
              7,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: _ShimmerBox(height: 12, borderRadius: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the Monthly tab
class MonthlyShimmer extends StatelessWidget {
  const MonthlyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: _ShimmerWrap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ShimmerBox(width: 100, height: 16, borderRadius: 4),
            const Gap(4),
            const _ShimmerBox(width: 200, height: 14, borderRadius: 4),
            const Gap(24),
            // Calendar grid placeholder
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: List.generate(
                    7,
                    (_) => const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _ShimmerBox(borderRadius: 4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Gap(24),
            // Legend
            const _ShimmerBox(width: 200, height: 16, borderRadius: 4),
            const Gap(24),
            // Top days
            ...List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: _ShimmerBox(height: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the Yearly tab
class YearlyShimmer extends StatelessWidget {
  const YearlyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: _ShimmerWrap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: 120, height: 16, borderRadius: 4),
            Gap(4),
            _ShimmerBox(width: 200, height: 14, borderRadius: 4),
            Gap(24),
            _ShimmerBox(height: 280, borderRadius: 12),
            Gap(32),
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 110, borderRadius: 16)),
                Gap(12),
                Expanded(child: _ShimmerBox(height: 110, borderRadius: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for the Activity Log (Journal) tab
class ActivityLogShimmer extends StatelessWidget {
  const ActivityLogShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      child: _ShimmerWrap(
        child: Column(
          children: [
            // Pill for Date Header
            const Center(
              child: _ShimmerBox(width: 120, height: 28, borderRadius: 14),
            ),
            const Gap(24),
            // Timeline Cards
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline axis
                    Column(
                      children: [
                        const _ShimmerBox(width: 2, height: 16),
                        const Gap(2),
                        const _ShimmerBox(
                          width: 28,
                          height: 28,
                          borderRadius: 14,
                        ),
                        const Gap(2),
                        _ShimmerBox(width: 2, height: index == 3 ? 0 : 60),
                      ],
                    ),
                    const Gap(16),
                    // Card
                    const Expanded(
                      child: _ShimmerBox(height: 100, borderRadius: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Internal helpers
// ─────────────────────────────────────────────

/// Wraps children in Shimmer effect using theme-aware colors
class _ShimmerWrap extends StatelessWidget {
  const _ShimmerWrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isAmoled = !isLight && bg == AppColors.backgroundAmoled;

    return Shimmer.fromColors(
      baseColor: isLight
          ? Colors.grey.shade200
          : (isAmoled ? const Color(0xFF1A1A1A) : Colors.grey.shade800),
      highlightColor: isLight
          ? Colors.grey.shade100
          : (isAmoled ? const Color(0xFF2E2E2E) : Colors.grey.shade600),
      child: child,
    );
  }
}

/// A single shimmer placeholder box
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    this.width,
    this.height,
    this.borderRadius = 8,
  });
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // Shimmer paints over this
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
