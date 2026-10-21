import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Holds the result of a GitHub Release update check.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.latestVersion,
    required this.isUpdateAvailable,
    required this.releaseTitle,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.htmlUrl,
    this.latestBuildNumber,
    this.publishedAt,
  });

  final String currentVersion;
  final String currentBuildNumber;
  final String latestVersion;
  final String? latestBuildNumber;
  final bool isUpdateAvailable;
  final String releaseTitle;
  final String releaseNotes;
  final String downloadUrl;
  final String htmlUrl;
  final DateTime? publishedAt;
}

class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _owner = 'ShaijoGeorge';
  static const String _repo = 'Verso';
  static const String _kLastPromptTimeKey = 'verso_update_last_prompt_time';
  static const String _kDismissedVersionKey = 'verso_update_dismissed_version';
  static const String fallbackDownloadUrl =
      'https://versobibletracker.netlify.app/#download';

  /// Queries GitHub Releases for the latest version and compares it with the local app version.
  Future<AppUpdateInfo?> checkForUpdate({
    required String currentVersion,
    required String currentBuildNumber,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.github.com/repos/$_owner/$_repo/releases/latest',
      );

      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Verso-App',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint(
          'Update check received status ${response.statusCode}: ${response.body}',
        );
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawTag = (data['tag_name'] as String?)?.trim() ?? '';
      if (rawTag.isEmpty) return null;

      final releaseTitle = (data['name'] as String?)?.trim() ?? rawTag;
      final releaseNotes = (data['body'] as String?)?.trim() ?? '';
      final htmlUrl = (data['html_url'] as String?) ??
          'https://github.com/$_owner/$_repo/releases';

      // Parse published date
      DateTime? publishedAt;
      final publishedStr = data['published_at'] as String?;
      if (publishedStr != null) {
        publishedAt = DateTime.tryParse(publishedStr);
      }

      // Look for a direct APK asset if available
      var downloadUrl = fallbackDownloadUrl;
      final assets = data['assets'] as List<dynamic>?;
      if (assets != null && assets.isNotEmpty) {
        for (final asset in assets) {
          final assetMap = asset as Map<String, dynamic>;
          final name = (assetMap['name'] as String?)?.toLowerCase() ?? '';
          if (name.endsWith('.apk')) {
            final browserDownload = assetMap['browser_download_url'] as String?;
            if (browserDownload != null && browserDownload.isNotEmpty) {
              downloadUrl = browserDownload;
              break;
            }
          }
        }
      }

      // Extract remote semver & build number
      final cleanTag = rawTag.replaceFirst(RegExp('^[vV]'), '');
      final tagParts = cleanTag.split('+');
      final remoteSemver = tagParts.first;
      final remoteBuild = tagParts.length > 1 ? tagParts[1] : null;

      final isAvailable = isNewerVersion(
        currentVersion: currentVersion,
        currentBuild: currentBuildNumber,
        remoteTag: rawTag,
      );

      return AppUpdateInfo(
        currentVersion: currentVersion,
        currentBuildNumber: currentBuildNumber,
        latestVersion: remoteSemver,
        latestBuildNumber: remoteBuild,
        isUpdateAvailable: isAvailable,
        releaseTitle: releaseTitle,
        releaseNotes: releaseNotes,
        downloadUrl: downloadUrl,
        htmlUrl: htmlUrl,
        publishedAt: publishedAt,
      );
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  /// Compares local and remote version semantics accurately.
  static bool isNewerVersion({
    required String currentVersion,
    required String currentBuild,
    required String remoteTag,
  }) {
    final cleanRemote = remoteTag.trim().replaceFirst(RegExp('^[vV]'), '');
    final remoteParts = cleanRemote.split('+');
    final remoteSemver = remoteParts.first;
    final remoteBuildNum =
        remoteParts.length > 1 ? int.tryParse(remoteParts[1]) ?? 0 : 0;

    final currentSemver = currentVersion.trim().split('+').first;
    final currentBuildNum = int.tryParse(currentBuild.trim()) ?? 0;

    final remoteSegments =
        remoteSemver.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentSegments =
        currentSemver.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (remoteSegments.length < 3) {
      remoteSegments.add(0);
    }
    while (currentSegments.length < 3) {
      currentSegments.add(0);
    }

    for (var i = 0; i < 3; i++) {
      if (remoteSegments[i] > currentSegments[i]) return true;
      if (remoteSegments[i] < currentSegments[i]) return false;
    }

    // Semver segments are identical: check build number if remote provides it
    if (remoteBuildNum > 0 && currentBuildNum > 0) {
      return remoteBuildNum > currentBuildNum;
    }

    return false;
  }

  /// Determines if an automatic popup should be shown to the user.
  /// Prevents spamming users who already dismissed or were notified recently.
  Future<bool> shouldPromptUser(AppUpdateInfo info) async {
    if (!info.isUpdateAvailable) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastPromptMs = prefs.getInt(_kLastPromptTimeKey) ?? 0;
    final dismissedVersion = prefs.getString(_kDismissedVersionKey);

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedHours = (now - lastPromptMs) / (1000 * 60 * 60);

    // If dismissed this exact version less than 24h ago, do not nag
    if (dismissedVersion == info.latestVersion && elapsedHours < 24) {
      return false;
    }

    // Minimum cooldown between automatic prompts is 12 hours
    if (elapsedHours < 12) {
      return false;
    }

    return true;
  }

  /// Records that the user dismissed or was shown the update prompt.
  Future<void> recordPromptDismissed(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _kLastPromptTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setString(_kDismissedVersionKey, version);
  }

  /// Launches the update download link or landing page.
  static Future<bool> launchDownload(String url) async {
    final uri = Uri.parse(url);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        return await launchUrl(uri);
      } catch (e) {
        debugPrint('Could not launch update URL: $e');
        return false;
      }
    }
  }
}
