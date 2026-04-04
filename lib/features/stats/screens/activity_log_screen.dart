import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../providers/activity_providers.dart';
import '../../../core/widgets/error_state_widget.dart';

class ActivityLogScreen extends ConsumerWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(activityLogProvider);

    return activityAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateWidget(error: e),
      data: (groups) {
        if (groups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_edu, size: 64, color: Colors.grey),
                Gap(16),
                Text("No activity yet. Start reading!"),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final isBulk = group.chapters.length > 5;
            final showDateHeader = index == 0 || !isSameDay(groups[index - 1].timestamp, group.timestamp);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDateHeader) _DateHeader(date: group.timestamp),
                
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timeline Line
                      Column(
                        children: [
                          Container(width: 2, height: 16, color: Colors.grey.withValues(alpha: 0.3)),
                          // SPECIAL ICON IF FINISHED
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: group.isFinish 
                                ? Colors.amber.shade100 
                                : (isBulk ? Colors.orange.withValues(alpha: 0.2) : Theme.of(context).colorScheme.primaryContainer),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              group.isFinish 
                                ? Icons.emoji_events // TROPHY ICON
                                : (isBulk ? Icons.done_all : Icons.auto_stories),
                              size: 16,
                              color: group.isFinish 
                                ? Colors.amber.shade800 
                                : (isBulk ? Colors.orange : Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 2,
                              color: index == groups.length - 1 ? Colors.transparent : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      
                      // Content Card
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                // Gold border if finished
                                color: group.isFinish 
                                    ? Colors.amber.withValues(alpha: 0.5) 
                                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                                width: group.isFinish ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row
                                Row(
                                  children: [
                                    Text(
                                      group.book.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const Spacer(),
                                    Text(
                                      DateFormat('h:mm a').format(group.timestamp),
                                      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                                    ),
                                  ],
                                ),
                                const Gap(8),
                                
                                // Tags Row
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    // Time Tag
                                    _Tag(text: group.timeOfDay, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                    
                                    // Bulk Tag
                                    if (isBulk) 
                                      _Tag(text: "Mass Update", color: Colors.orange.withValues(alpha: 0.1), textColor: Colors.orange),
                                    
                                    // FINISHED TAG
                                    if (group.isFinish)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.star, size: 12, color: Colors.amber.shade800),
                                            const Gap(4),
                                            Text(
                                              "Book Completed",
                                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const Gap(8),
                                Text(
                                  group.description,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// Simple helper widget for tags
class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;

  const _Tag({required this.text, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: textColor),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    String label;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      label = "Today";
    } else if (checkDate == yesterday) {
      label = "Yesterday";
    } else {
      label = DateFormat('MMMM d, y').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const Expanded(child: Divider(indent: 16)),
        ],
      ),
    );
  }
}