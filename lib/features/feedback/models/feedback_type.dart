import 'package:flutter/material.dart';

/// Type of feedback being submitted by the user.
enum FeedbackType {
  issue,
  idea;

  String get title => switch (this) {
        FeedbackType.issue => 'Report an issue',
        FeedbackType.idea => 'Share an idea',
      };

  String get shortTitle => switch (this) {
        FeedbackType.issue => 'Report an Issue',
        FeedbackType.idea => 'Share an Idea',
      };

  String get subtitle => switch (this) {
        FeedbackType.issue => 'Found a bug, glitch, or unexpected behavior?',
        FeedbackType.idea => 'Have a suggestion for a feature or improvement?',
      };

  String get inputPlaceholder => switch (this) {
        FeedbackType.issue =>
          'Describe the issue in detail. What happened? What did you expect to happen? Steps to reproduce...',
        FeedbackType.idea =>
          'Describe your idea. What feature or improvement would make Verso better for your Bible reading habit?',
      };

  String get buttonLabel => switch (this) {
        FeedbackType.issue => 'Submit Report',
        FeedbackType.idea => 'Submit Idea',
      };

  IconData get icon => switch (this) {
        FeedbackType.issue => Icons.bug_report_outlined,
        FeedbackType.idea => Icons.lightbulb_outline_rounded,
      };

  Color get accentColor => switch (this) {
        FeedbackType.issue => const Color(0xFFEF4444),
        FeedbackType.idea => const Color(0xFFF59E0B),
      };
}
