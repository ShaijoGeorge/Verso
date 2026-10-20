import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/extensions.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/design/tokens/shadows.dart';
import 'package:verso/data/bible_book_names.dart';
import 'package:verso/data/bible_data.dart';
import 'package:verso/data/local/entities/user_settings.dart';
import 'package:verso/features/reading/providers/reading_providers.dart';
import 'package:verso/features/reading/screens/new_testament_screen.dart';
import 'package:verso/features/reading/screens/old_testament_screen.dart';
import 'package:verso/features/settings/providers/settings_providers.dart';

class BibleScreen extends ConsumerWidget {
  const BibleScreen({super.key});

  String _canonShortName(CanonType canon) => switch (canon) {
        CanonType.catholic => 'Catholic Canon',
        CanonType.protestant => 'Protestant Canon',
        CanonType.orthodox => 'Orthodox Canon',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isAmoled = context.palette.style == AppearanceStyle.amoled;

    final settings = switch (ref.watch(currentSettingsProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final bibleLanguage = settings?.bibleLanguage ?? 'en';
    final canon = settings?.canon ?? CanonType.catholic;
    final allBooks = ref.watch(activeCanonBooksProvider);

    // DefaultTabController automatically manages the state for the TabBar and TabBarView
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Quick Language Switcher Pill
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_canonShortName(canon).toUpperCase()} · ${allBooks.length} BOOKS',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.primary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                          fontSize: 10,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Scripture Index',
                        style: textTheme.headlineLarge?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Language Switcher Pill (EN / മലയാളം)
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    final nextLang = bibleLanguage == 'en' ? 'ml' : 'en';
                    await ref
                        .read(currentSettingsProvider.notifier)
                        .setBibleLanguage(nextLang);
                    if (context.mounted) {
                      VersoSnackbar.show(
                        context,
                        message: nextLang == 'ml'
                            ? 'Switched book names to മലയാളം (Malayalam)'
                            : 'Switched book names to English',
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: AppRadii.borderRadiusFull,
                      border: Border.all(
                        color: scheme.outline
                            .withValues(alpha: isLight ? 0.65 : 0.3),
                      ),
                      boxShadow: isLight ? AppShadows.sm : AppShadows.none,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 15,
                          color: scheme.primary,
                        ),
                        const Gap(6),
                        Text(
                          bibleLanguage == 'ml' ? 'മലയാളം' : 'EN',
                          style: textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // The Segmented Control
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isAmoled
                  ? scheme.surfaceContainerHighest
                  : scheme.surfaceContainerHighest
                      .withValues(alpha: isLight ? 0.65 : 0.45),
              borderRadius: AppRadii.borderRadiusLG,
              border: Border.all(
                color: scheme.outline.withValues(alpha: isLight ? 0.4 : 0.15),
              ),
            ),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent, // Removes standard underline
              splashFactory: NoSplash.splashFactory,
              indicator: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: isLight ? 0.5 : 0.25),
                ),
                boxShadow: isLight ? AppShadows.sm : null,
              ),
              labelColor: scheme.primary,
              labelStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
              unselectedLabelColor: scheme.onSurfaceVariant,
              unselectedLabelStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
              tabs: [
                Tab(
                  height: 38,
                  text: Testament.old.getLocalizedName(bibleLanguage),
                ),
                Tab(
                  height: 38,
                  text: Testament.newTestament.getLocalizedName(bibleLanguage),
                ),
              ],
            ),
          ),

          // The actual content (our existing grids)
          const Expanded(
            child: TabBarView(
              children: [
                OldTestamentScreen(),
                NewTestamentScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
