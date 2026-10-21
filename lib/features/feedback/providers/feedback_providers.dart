import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso/core/providers/package_info_provider.dart';
import 'package:verso/features/feedback/data/feedback_repository.dart';
import 'package:verso/features/feedback/models/feedback_type.dart';

final Provider<FeedbackRepository> feedbackRepositoryProvider =
    Provider<FeedbackRepository>((ref) {
  return FeedbackRepository();
});

final NotifierProvider<FeedbackSubmissionNotifier, AsyncValue<void>>
    feedbackSubmissionProvider =
    NotifierProvider<FeedbackSubmissionNotifier, AsyncValue<void>>(
  FeedbackSubmissionNotifier.new,
);

class FeedbackSubmissionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  Future<bool> submit({
    required FeedbackType type,
    required String message,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    state = const AsyncValue<void>.loading();
    final repo = ref.read(feedbackRepositoryProvider);
    final version = ref.read(packageInfoProvider).version;

    try {
      await repo.submitFeedback(
        type: type,
        message: message,
        appVersion: version,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      state = const AsyncValue<void>.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue<void>.error(e, st);
      return false;
    }
  }

  Future<bool> fallbackEmail({
    required FeedbackType type,
    required String message,
  }) async {
    final repo = ref.read(feedbackRepositoryProvider);
    final version = ref.read(packageInfoProvider).version;
    return repo.sendViaEmail(
      type: type,
      message: message,
      appVersion: version,
    );
  }
}
