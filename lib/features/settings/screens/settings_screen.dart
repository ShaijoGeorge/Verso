import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:verso/core/design/design.dart';
import 'package:verso/core/providers/package_info_provider.dart';
import 'package:verso/core/utils/app_error_handler.dart';
import 'package:verso/core/widgets/error_state_widget.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';
import 'package:verso/features/settings/screens/debug_cache_screen.dart';
import 'package:verso/features/settings/services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _formatTime(int hour, int minute) {
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Future<TimeOfDay?> _pickTimeDialog(int currentHour, int currentMinute) {
    return showGeneralDialog<TimeOfDay>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, _, __) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: TimePickerDialog(
            initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _pickReminderTime(int currentHour, int currentMinute) async {
    final picked = await _pickTimeDialog(currentHour, currentMinute);
    if (picked != null) {
      try {
        await ref.read(currentSettingsProvider.notifier).updateReminder(
              true,
              picked.hour,
              picked.minute,
            );
        await NotificationService().scheduleDailyReminder(
          picked.hour,
          picked.minute,
        );
        if (mounted) {
          VersoSnackbar.success(
            context,
            message:
                'Reminder set for ${_formatTime(picked.hour, picked.minute)}',
          );
        }
      } catch (e) {
        if (mounted) {
          VersoSnackbar.error(context, message: AppErrorHandler.getMessage(e));
        }
      }
    }
  }

  Future<void> _pickScheduleTime(
    UserSettings settings, {
    required bool isDay,
  }) async {
    final picked = await _pickTimeDialog(
      isDay ? settings.dayStartHour : settings.nightStartHour,
      isDay ? settings.dayStartMinute : settings.nightStartMinute,
    );
    if (picked != null) {
      await ref.read(currentSettingsProvider.notifier).setSchedule(
            enabled: settings.scheduleEnabled,
            dayStyle: settings.dayStyle,
            nightStyle: settings.nightStyle,
            dayStartHour: isDay ? picked.hour : settings.dayStartHour,
            dayStartMinute: isDay ? picked.minute : settings.dayStartMinute,
            nightStartHour: isDay ? settings.nightStartHour : picked.hour,
            nightStartMinute: isDay ? settings.nightStartMinute : picked.minute,
          );
    }
  }

  Future<AppearanceStyle?> _pickStyle(
    AppearanceStyle current,
    String title,
  ) async {
    return showModalBottomSheet<AppearanceStyle>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final bottomPadding = MediaQuery.paddingOf(ctx).bottom;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              for (final style in AppearanceStyle.values)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading:
                      Icon(_styleIcon(style), color: scheme.onSurfaceVariant),
                  title: Text(
                    _styleLabel(style),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  trailing: current == style
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: scheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(ctx, style),
                ),
              Gap(20 + bottomPadding),
            ],
          ),
        );
      },
    );
  }

  String _styleLabel(AppearanceStyle style) => switch (style) {
        AppearanceStyle.light => 'Light',
        AppearanceStyle.dark => 'Dark',
        AppearanceStyle.amoled => 'AMOLED (pure black)',
      };

  IconData _styleIcon(AppearanceStyle style) => switch (style) {
        AppearanceStyle.light => Icons.light_mode_outlined,
        AppearanceStyle.dark => Icons.dark_mode_outlined,
        AppearanceStyle.amoled => Icons.brightness_1_outlined,
      };

  String _canonLabel(CanonType canon) => switch (canon) {
        CanonType.catholic => 'Catholic (73 Books)',
        CanonType.protestant => 'Protestant (66 Books)',
        CanonType.orthodox => 'Eastern Orthodox (78 Books)',
      };

  String _canonSubtitle(CanonType canon) => switch (canon) {
        CanonType.catholic =>
          'Includes Deuterocanonicals (Tobit, Judith, Wisdom, etc.)',
        CanonType.protestant =>
          'Standard 66-book canon (39 Old Testament, 27 New)',
        CanonType.orthodox => 'Includes 1 & 2 Esdras, 3 Maccabees, Psalm 151',
      };

  int _canonBookCount(CanonType canon) => switch (canon) {
        CanonType.catholic => 73,
        CanonType.protestant => 66,
        CanonType.orthodox => 78,
      };

  int _canonChapterCount(CanonType canon) => switch (canon) {
        CanonType.catholic => 1334,
        CanonType.protestant => 1189,
        CanonType.orthodox => 1515,
      };

  Future<void> _pickCanon(UserSettings settings) async {
    final currentCanon = CanonType.values.firstWhere(
      (e) => e.name == settings.canonType,
      orElse: () => CanonType.catholic,
    );

    final picked = await showModalBottomSheet<CanonType>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bottomPadding = MediaQuery.paddingOf(ctx).bottom;
        final warningBg = isDark
            ? const Color(0xFF452B00).withValues(alpha: 0.6)
            : const Color(0xFFFFF7ED);
        final warningBorder = isDark
            ? const Color(0xFFB45309).withValues(alpha: 0.5)
            : const Color(0xFFFDBA74);
        final warningText =
            isDark ? const Color(0xFFFDE68A) : const Color(0xFF9A3412);
        final warningIcon =
            isDark ? const Color(0xFFFBBF24) : const Color(0xFFEA580C);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Select Bible Tradition',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              // Prominent warning banner right when clicking canon
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: warningBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: warningBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: warningIcon,
                        size: 22,
                      ),
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tradition Warning',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: warningText,
                              ),
                            ),
                            const Gap(3),
                            Text(
                              'Switching canons alters visible books and resets completion denominators. Your reading history is safely preserved and will never be deleted.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                height: 1.4,
                                color: warningText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(4),
              for (final canon in CanonType.values)
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: currentCanon == canon
                          ? scheme.primary.withValues(alpha: 0.12)
                          : scheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: currentCanon == canon
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _canonLabel(canon),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: currentCanon == canon
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    _canonSubtitle(canon),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  trailing: currentCanon == canon
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: scheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(ctx, canon),
                ),
              Gap(24 + bottomPadding),
            ],
          ),
        );
      },
    );

    if (picked != null && picked != currentCanon && mounted) {
      final confirm = await _showCanonConfirmationDialog(
        currentCanon: currentCanon,
        newCanon: picked,
      );
      if ((confirm ?? false) && mounted) {
        await _saveUserCanon(picked);
        if (mounted) {
          VersoSnackbar.success(
            context,
            message: 'Bible tradition updated to ${_canonLabel(picked)}',
          );
        }
      }
    }
  }

  Future<void> _saveUserCanon(CanonType selectedCanon) async {
    final canonString = selectedCanon.name;

    // 1. Save to Local SQLite (Drift)
    await ref.read(localDatabaseProvider).updateLocalCanon(canonString);

    // 2. Sync to Supabase
    await ref.read(settingsRepositoryProvider).syncCanonToCloud(canonString);

    // 3. Update UI State & Local Preferences
    await ref
        .read(currentSettingsProvider.notifier)
        .updateCanonType(selectedCanon);
    ref.invalidate(userSettingsProvider);
  }

  Future<bool?> _showCanonConfirmationDialog({
    required CanonType currentCanon,
    required CanonType newCanon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warningColor =
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFEA580C);

    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: scheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: warningColor,
                size: 24,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                'Change Tradition?',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Switch from ${_canonLabel(currentCanon)} to ${_canonLabel(newCanon)}?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const Gap(14),
            _buildCanonDialogBullet(
              icon: Icons.menu_book_rounded,
              text:
                  'Book count changes from ${_canonBookCount(currentCanon)} to ${_canonBookCount(newCanon)} books (${_canonChapterCount(newCanon)} chapters).',
              scheme: scheme,
            ),
            const Gap(10),
            _buildCanonDialogBullet(
              icon: Icons.percent_rounded,
              text:
                  'Overall completion percentages and charts will recalibrate to the new canon.',
              scheme: scheme,
            ),
            const Gap(10),
            _buildCanonDialogBullet(
              icon: Icons.verified_user_outlined,
              text:
                  'Existing reading progress is safely preserved in your database and never deleted.',
              scheme: scheme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              'Switch Canon',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanonDialogBullet({
    required IconData icon,
    required String text,
    required ColorScheme scheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: scheme.primary),
        const Gap(10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.35,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(currentSettingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        scrolledUnderElevation: 0,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateWidget(
          error: err,
          onRetry: () => ref.invalidate(currentSettingsProvider),
        ),
        data: (settings) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- COLOR THEME SECTION ---
                  _SettingsSectionCard(
                    title: 'Color Theme',
                    children: [
                      for (final profile in ThemeProfiles.all)
                        _ThemeProfileTile(
                          profile: profile,
                          isSelected: settings.themeProfileId == profile.id,
                          onTap: () => ref
                              .read(currentSettingsProvider.notifier)
                              .setThemeProfileId(profile.id),
                        ),
                    ],
                  ),
                  const Gap(24),

                  // --- APPEARANCE SECTION ---
                  _SettingsSectionCard(
                    title: 'Appearance',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Theme Mode',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            const Gap(12),
                            SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<AppThemeMode>(
                                showSelectedIcon: false,
                                segments: const [
                                  ButtonSegment(
                                    value: AppThemeMode.system,
                                    icon: Icon(
                                      Icons.brightness_auto_outlined,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'System',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ButtonSegment(
                                    value: AppThemeMode.light,
                                    icon: Icon(
                                      Icons.light_mode_outlined,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Light',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ButtonSegment(
                                    value: AppThemeMode.dark,
                                    icon: Icon(
                                      Icons.dark_mode_outlined,
                                      size: 18,
                                    ),
                                    label: Text(
                                      'Dark',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                selected: {settings.themeMode},
                                onSelectionChanged: (s) => ref
                                    .read(currentSettingsProvider.notifier)
                                    .setThemeMode(s.first),
                                style: ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  textStyle: WidgetStatePropertyAll(
                                    GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (settings.themeMode != AppThemeMode.light)
                        _SettingsSwitchTile(
                          title: 'Pure Black (AMOLED)',
                          subtitle: 'Applies when dark theme is active',
                          icon: Icons.brightness_1_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          value: settings.useAmoledForDark,
                          onChanged: (v) => ref
                              .read(currentSettingsProvider.notifier)
                              .setUseAmoledForDark(v),
                        ),
                    ],
                  ),
                  const Gap(24),

                  // --- TEXT SIZE SECTION ---
                  _SettingsSectionCard(
                    title: 'Text Size',
                    children: [
                      _FontSizeSettingsTile(
                        currentScale: settings.fontScaleFactor,
                        onChanged: (scale) => ref
                            .read(currentSettingsProvider.notifier)
                            .setFontScaleFactor(scale),
                      ),
                    ],
                  ),
                  const Gap(24),

                  // --- SCHEDULED THEME SECTION ---
                  _SettingsSectionCard(
                    title: 'Scheduled Theme',
                    children: [
                      _SettingsSwitchTile(
                        title: 'Schedule Theme',
                        subtitle: 'Auto-switch between day and night modes',
                        icon: Icons.schedule_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        value: settings.scheduleEnabled,
                        onChanged: (v) => ref
                            .read(currentSettingsProvider.notifier)
                            .setSchedule(
                              enabled: v,
                              dayStyle: settings.dayStyle,
                              nightStyle: settings.nightStyle,
                              dayStartHour: settings.dayStartHour,
                              dayStartMinute: settings.dayStartMinute,
                              nightStartHour: settings.nightStartHour,
                              nightStartMinute: settings.nightStartMinute,
                            ),
                      ),
                      if (settings.scheduleEnabled) ...[
                        _SettingsActionTile(
                          title: 'Day Mode',
                          icon: Icons.wb_sunny_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _styleLabel(settings.dayStyle),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const Gap(8),
                              _TimeChip(
                                label: _formatTime(
                                  settings.dayStartHour,
                                  settings.dayStartMinute,
                                ),
                                onTap: () =>
                                    _pickScheduleTime(settings, isDay: true),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final picked = await _pickStyle(
                              settings.dayStyle,
                              'Day mode',
                            );
                            if (picked != null) {
                              await ref
                                  .read(currentSettingsProvider.notifier)
                                  .setSchedule(
                                    enabled: settings.scheduleEnabled,
                                    dayStyle: picked,
                                    nightStyle: settings.nightStyle,
                                    dayStartHour: settings.dayStartHour,
                                    dayStartMinute: settings.dayStartMinute,
                                    nightStartHour: settings.nightStartHour,
                                    nightStartMinute: settings.nightStartMinute,
                                  );
                            }
                          },
                        ),
                        _SettingsActionTile(
                          title: 'Night Mode',
                          icon: Icons.nightlight_outlined,
                          iconColor: const Color(0xFF6366F1),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _styleLabel(settings.nightStyle),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const Gap(8),
                              _TimeChip(
                                label: _formatTime(
                                  settings.nightStartHour,
                                  settings.nightStartMinute,
                                ),
                                onTap: () =>
                                    _pickScheduleTime(settings, isDay: false),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final picked = await _pickStyle(
                              settings.nightStyle,
                              'Night mode',
                            );
                            if (picked != null) {
                              await ref
                                  .read(currentSettingsProvider.notifier)
                                  .setSchedule(
                                    enabled: settings.scheduleEnabled,
                                    dayStyle: settings.dayStyle,
                                    nightStyle: picked,
                                    dayStartHour: settings.dayStartHour,
                                    dayStartMinute: settings.dayStartMinute,
                                    nightStartHour: settings.nightStartHour,
                                    nightStartMinute: settings.nightStartMinute,
                                  );
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  const Gap(24),

                  // --- NOTIFICATIONS SECTION ---
                  _SettingsSectionCard(
                    title: 'Reminders',
                    children: [
                      _SettingsSwitchTile(
                        title: 'Daily Reminder',
                        subtitle: settings.isReminderEnabled
                            ? 'Scheduled for ${_formatTime(settings.reminderHour, settings.reminderMinute)}'
                            : 'Get a daily nudge to read',
                        icon: Icons.notifications_active_outlined,
                        iconColor: const Color(0xFF10B981),
                        value: settings.isReminderEnabled,
                        onChanged: (value) async {
                          try {
                            await ref
                                .read(currentSettingsProvider.notifier)
                                .updateReminder(
                                  value,
                                  settings.reminderHour,
                                  settings.reminderMinute,
                                );
                            if (value) {
                              await NotificationService().scheduleDailyReminder(
                                settings.reminderHour,
                                settings.reminderMinute,
                              );
                              if (mounted) {
                                VersoSnackbar.success(
                                  context,
                                  message: 'Daily reminder enabled',
                                );
                              }
                            } else {
                              await NotificationService().cancelReminders();
                            }
                          } catch (e) {
                            if (mounted) {
                              VersoSnackbar.error(
                                context,
                                message: AppErrorHandler.getMessage(e),
                              );
                            }
                          }
                        },
                      ),
                      if (settings.isReminderEnabled)
                        _SettingsActionTile(
                          title: 'Reminder Time',
                          icon: Icons.access_time,
                          iconColor: const Color(0xFF3B82F6),
                          trailing: _TimeChip(
                            label: _formatTime(
                              settings.reminderHour,
                              settings.reminderMinute,
                            ),
                            onTap: () => _pickReminderTime(
                              settings.reminderHour,
                              settings.reminderMinute,
                            ),
                          ),
                          onTap: () => _pickReminderTime(
                            settings.reminderHour,
                            settings.reminderMinute,
                          ),
                        ),
                    ],
                  ),
                  const Gap(24),

                  // --- BIBLE CANON SECTION ---
                  _SettingsSectionCard(
                    title: 'Bible Tradition',
                    children: [
                      _SettingsActionTile(
                        title: 'Bible Canon',
                        subtitle: _canonLabel(settings.canon),
                        icon: Icons.auto_stories_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                switch (settings.canon) {
                                  CanonType.catholic => 'Catholic',
                                  CanonType.protestant => 'Protestant',
                                  CanonType.orthodox => 'Orthodox',
                                },
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                            const Gap(6),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: scheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () => _pickCanon(settings),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF452B00)
                                        .withValues(alpha: 0.35)
                                    : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFFB45309)
                                      .withValues(alpha: 0.35)
                                  : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFFD97706),
                              ),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  'Tap above to change your tradition. Visible books (66, 73, or 78) and stats adjust dynamically, while your reading progress is always preserved.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    height: 1.35,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFFFDE68A)
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(32),

                  // --- ABOUT SECTION ---
                  Center(
                    child: GestureDetector(
                      onLongPress: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const DebugCacheScreen(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'Verso v${ref.watch(packageInfoProvider).version}',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: scheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            'Made by Shaijo George',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: scheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(48),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// -- Components --

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
        ),
        VersoCard(
          shadow: AppShadows.md,
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i < children.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                        color: scheme.outlineVariant
                            .withValues(alpha: isDark ? 0.3 : 0.5),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: scheme.onSurfaceVariant,
          ),
        ),
        secondary: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const Gap(2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeProfileTile extends StatelessWidget {
  const _ThemeProfileTile({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  final ThemeProfile profile;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final previewPalette = switch (context.palette.style) {
      AppearanceStyle.light => profile.light,
      AppearanceStyle.amoled => profile.amoled,
      _ => profile.dark,
    };

    return Material(
      color: isSelected
          ? scheme.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Swatches
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _Swatch(color: previewPalette.bg, size: 28),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _Swatch(color: previewPalette.primary, size: 22),
                    ),
                    Positioned(
                      top: 4,
                      right: 0,
                      child: _Swatch(color: previewPalette.accent, size: 14),
                    ),
                  ],
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      profile.tagline,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('checked'),
                        color: scheme.primary,
                        size: 22,
                      )
                    : const SizedBox(
                        key: ValueKey('unchecked'),
                        width: 22,
                        height: 22,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _FontSizeSettingsTile extends StatelessWidget {
  const _FontSizeSettingsTile({
    required this.currentScale,
    required this.onChanged,
  });

  final double currentScale;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activePreset = AppFontSize.fromScale(currentScale);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6)
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Icon(
                  Icons.format_size_rounded,
                  size: 20,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'In-App Font Size',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      '${activePreset.label} (${activePreset.percentage})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),

          // Live Preview Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest
                  .withValues(alpha: isDark ? 0.35 : 0.45),
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: scheme.outline.withValues(alpha: isDark ? 0.15 : 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'LIVE PREVIEW',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Psalm 119:105',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Text(
                  'Your word is a lamp to my feet and a light to my path.',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18 * currentScale,
                    height: 1.35,
                    color: scheme.onSurface,
                  ),
                ),
                const Gap(6),
                Text(
                  'Read daily to build your streak and stay consistent.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13 * currentScale,
                    height: 1.45,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),

          // Preset Selection Buttons
          Row(
            children: AppFontSize.values.map((preset) {
              final isSelected = (preset.scale - currentScale).abs() < 0.01;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => onChanged(preset.scale),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.primary
                            : scheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        border: Border.all(
                          color: isSelected
                              ? scheme.primary
                              : scheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            preset.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(2),
                          Text(
                            preset.percentage,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? scheme.onPrimary.withValues(alpha: 0.85)
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Gap(10),
          Text(
            'In-app font size applies across all books and screens, independent of phone settings.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
