import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Returns the correct avatar asset path based on the user's gender.
///
/// Reads gender from Supabase user_metadata. Falls back to male if unknown.
/// Use this everywhere you need the avatar - sidebar, profile screen, etc.
///
/// ```dart
/// VersoAvatar(size: 56)
/// VersoAvatar(size: 120, borderWidth: 3)
/// VersoAvatar.fromGender('female', size: 56)
/// ```
class VersoAvatar extends StatelessWidget {
  /// Creates an avatar that reads gender from the current Supabase session.
  const VersoAvatar({
    required this.size,
    this.borderWidth = 2,
    this.borderColor,
    super.key,
  }) : _explicitGender = null;

  /// Creates an avatar for a specific gender string ('male' or 'female').
  /// Useful in the profile-setup screen where the user hasn't saved yet.
  const VersoAvatar.fromGender(
    String gender, {
    required this.size,
    this.borderWidth = 2,
    this.borderColor,
    super.key,
  }) : _explicitGender = gender;

  final double size;
  final double borderWidth;
  final Color? borderColor;
  final String? _explicitGender;

  /// Asset paths - single source of truth
  static const maleAsset = 'assets/avatars/verso_male_avatar.jpeg';
  static const femaleAsset = 'assets/avatars/verso_female_avatar.jpeg';

  /// Returns the asset path for a given gender string.
  static String assetForGender(String? gender) {
    return gender == 'female' ? femaleAsset : maleAsset;
  }

  @override
  Widget build(BuildContext context) {
    // Determine gender: explicit override > Supabase metadata > default
    final gender = _explicitGender ??
        (Supabase.instance.client.auth.currentUser?.userMetadata?['gender']
            as String?) ??
        'male';

    final scheme = Theme.of(context).colorScheme;
    final effectiveBorderColor = borderColor ?? scheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: effectiveBorderColor.withValues(alpha: 0.3),
          width: borderWidth,
        ),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: effectiveBorderColor.withValues(alpha: 0.15),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetForGender(gender),
          fit: BoxFit.cover,
          width: size,
          height: size,
          // Graceful fallback if images aren't bundled yet
          errorBuilder: (_, __, ___) => ColoredBox(
            color: scheme.primaryContainer,
            child: Icon(
              gender == 'female' ? Icons.person_2 : Icons.person,
              size: size * 0.5,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
