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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reading Journal"),
        centerTitle: true,
      ),
      body: activityAsync.when(
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
            padding: const EdgeInsets.all(20),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final isBulk = group.chapters.length > 5; // Threshold for "Mark All"
              
              // Date Header Logic
              bool showDateHeader = true;
              if (index > 0) {
                final prev = groups[index - 1];
                if (isSameDay(prev.timestamp, group.timestamp)) {
                  showDateHeader = false;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDateHeader) _DateHeader(date: group.timestamp),
                  
                  // TIMELINE ITEM
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Timeline Line & Dot
                        Column(
                          children: [
                            Container(
                              width: 2,
                              height: 16,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isBulk 
                                  ? Colors.orange.withOpacity(0.2) 
                                  : Theme.of(context).colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isBulk ? Icons.done_all : Icons.auto_stories,
                                size: 16,
                                color: isBulk 
                                  ? Colors.orange 
                                  : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 2,
                                color: index == groups.length - 1 
                                    ? Colors.transparent 
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        
                        // 2. Content Card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        group.book.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        DateFormat('h:mm a').format(group.timestamp),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(4),
                                  Row(
                                    children: [
                                      // Creative Tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          group.timeOfDay,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      const Gap(8),
                                      if (isBulk)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            "Mass Update",
                                            style: TextStyle(fontSize: 10, color: Colors.orange),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Gap(8),
                                  Text(
                                    group.description, // "Read Chapters 1-5"
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
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
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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