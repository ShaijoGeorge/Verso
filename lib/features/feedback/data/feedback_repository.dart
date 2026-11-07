import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:verso/features/feedback/models/feedback_type.dart';

class FeedbackRepository {
  FeedbackRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const String feedbackEmail = 'versobibletracker@gmail.com';

  /// Submits user feedback (issue report or idea) along with an optional screenshot.
  Future<void> submitFeedback({
    required FeedbackType type,
    required String message,
    required String appVersion,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final user = _supabase.auth.currentUser;
    String? uploadedImageUrl;

    // 1. Upload screenshot if provided
    if (imageBytes != null && imageBytes.isNotEmpty) {
      try {
        final ext = imageName?.split('.').lastOrNull?.toLowerCase() ?? 'jpg';
        final fileName =
            'feedback_${type.name}_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final storagePath = 'feedback/$fileName';

        final contentType = switch (ext) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          'heic' => 'image/heic',
          _ => 'image/jpeg',
        };

        await _supabase.storage.from('feedback_attachments').uploadBinary(
              storagePath,
              imageBytes,
              fileOptions: FileOptions(
                upsert: true,
                contentType: contentType,
              ),
            );

        uploadedImageUrl = _supabase.storage
            .from('feedback_attachments')
            .getPublicUrl(storagePath);
      } catch (e) {
        debugPrint(
          'Feedback screenshot upload warning (continuing submission): $e',
        );
      }
    }

    // 2. Insert into feedbacks table
    try {
      await _supabase.from('feedbacks').insert({
        'user_id': user?.id,
        'user_email': user?.email,
        'type': type.name,
        'message': message.trim(),
        'image_urls':
            uploadedImageUrl != null ? [uploadedImageUrl] : <String>[],
        'app_version': appVersion,
        'platform': defaultTargetPlatform.name,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to insert into Supabase feedbacks table: $e');
      rethrow;
    }
  }

  /// Fallback: opens the user's default email client with prefilled feedback.
  Future<bool> sendViaEmail({
    required FeedbackType type,
    required String message,
    required String appVersion,
  }) async {
    final subject = Uri.encodeComponent(
      '[Verso Feedback] ${type == FeedbackType.issue ? 'Report an Issue' : 'Feature Idea'} (v$appVersion)',
    );
    final body = Uri.encodeComponent(
      'Type: ${type.shortTitle}\n'
      'App Version: $appVersion\n'
      'Platform: ${defaultTargetPlatform.name}\n\n'
      'Details:\n$message\n',
    );
    final mailtoUri =
        Uri.parse('mailto:$feedbackEmail?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(mailtoUri)) {
        return await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch mail client: $e');
    }
    return false;
  }
}
