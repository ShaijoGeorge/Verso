import 'package:flutter/foundation.dart';

/// Represents an account stored on this device for quick switching.
@immutable
class SavedAccount {
  const SavedAccount({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.refreshToken,
    required this.lastActive,
    this.avatarUrl,
  });

  factory SavedAccount.fromJson(Map<String, dynamic> json) {
    return SavedAccount(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      refreshToken: json['refreshToken'] as String? ?? '',
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  final String userId;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String refreshToken;
  final DateTime lastActive;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'refreshToken': refreshToken,
      'lastActive': lastActive.toIso8601String(),
    };
  }

  SavedAccount copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? refreshToken,
    DateTime? lastActive,
  }) {
    return SavedAccount(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      refreshToken: refreshToken ?? this.refreshToken,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedAccount &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          email == other.email &&
          displayName == other.displayName &&
          avatarUrl == other.avatarUrl &&
          refreshToken == other.refreshToken &&
          lastActive == other.lastActive;

  @override
  int get hashCode =>
      userId.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      avatarUrl.hashCode ^
      refreshToken.hashCode ^
      lastActive.hashCode;
}
