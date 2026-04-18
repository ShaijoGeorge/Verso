import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:verso/core/design/design.dart';

class DebugCacheScreen extends StatefulWidget {
  const DebugCacheScreen({super.key});

  @override
  State<DebugCacheScreen> createState() => _DebugCacheScreenState();
}

class _DebugCacheScreenState extends State<DebugCacheScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> _allPrefs = {};
  bool _isLoading = true;
  String _searchQuery = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadCache();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadCache() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList()..sort();

    final prefsMap = <String, dynamic>{};
    for (final key in keys) {
      prefsMap[key] = prefs.get(key);
    }

    setState(() {
      _allPrefs = prefsMap;
      _isLoading = false;
    });
  }

  List<MapEntry<String, dynamic>> get _filteredEntries {
    if (_searchQuery.isEmpty) return _allPrefs.entries.toList();
    return _allPrefs.entries
        .where(
          (e) =>
              e.key.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.value
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  String _getTypeLabel(dynamic value) {
    if (value is String) return 'String';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is List) return 'List<String>';
    return 'unknown';
  }

  Color _getTypeColor(dynamic value, BuildContext context) {
    if (value is String) return context.appColors.chartTeal;
    if (value is int || value is double) return context.appColors.chartPurple;
    if (value is bool) return context.appColors.streak;
    if (value is List) return context.colors.primary;
    return context.colors.onSurfaceVariant;
  }

  IconData _getTypeIcon(dynamic value) {
    if (value is String) return Icons.text_fields_rounded;
    if (value is int || value is double) return Icons.tag_rounded;
    if (value is bool) return Icons.toggle_on_rounded;
    if (value is List) return Icons.list_rounded;
    return Icons.help_outline_rounded;
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusLG),
        icon: Icon(
          Icons.warning_amber_rounded,
          color: ctx.colors.error,
          size: 48,
        ),
        title: Text('Nuke the Cache?', style: AppTypography.titleLarge),
        content: Text(
          'This will permanently delete all offline reading progress, settings, and downloaded verses.\n\nThis action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: ctx.colors.onSurfaceVariant,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: Spacing.lg),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              shape:
                  RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusSM),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: Spacing.sm),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: ctx.colors.error,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              shape:
                  RoundedRectangleBorder(borderRadius: AppRadii.borderRadiusSM),
            ),
            child: const Text('NUKE IT 💥'),
          ),
        ],
      ),
    );

    if ((confirm ?? false) && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _loadCache();
      if (mounted) {
        VersoSnackbar.success(
          context,
          message: 'Cache obliterated. Fresh start! 🧹',
        );
      }
    }
  }

  void _copyValue(String key, String value) {
    Clipboard.setData(ClipboardData(text: '$key: $value'));
    VersoSnackbar.success(context, message: 'Copied "$key" to clipboard');
  }

  void _showDetailSheet(String key, dynamic value, Color typeColor) {
    final valueStr = value.toString();
    final typeLabel = _getTypeLabel(value);
    final typeIcon = _getTypeIcon(value);
    final isDark = context.isDark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.92,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: ctx.colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadii.xl),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  const SizedBox(height: Spacing.sm),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.colors.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: AppRadii.borderRadiusFull,
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.lg,
                      Spacing.md,
                      Spacing.lg,
                      Spacing.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: AppRadii.borderRadiusSM,
                          ),
                          child: Icon(typeIcon, size: 18, color: typeColor),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                key,
                                style: AppTypography.titleSmall.copyWith(
                                  color: ctx.colors.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$typeLabel · ${valueStr.length} chars',
                                style: AppTypography.labelSmall.copyWith(
                                  color: ctx.colors.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.copy_rounded,
                            color: ctx.colors.primary,
                            size: 20,
                          ),
                          onPressed: () {
                            _copyValue(key, valueStr);
                            Navigator.pop(ctx);
                          },
                          tooltip: 'Copy to clipboard',
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: ctx.colors.outline
                        .withValues(alpha: isDark ? 0.1 : 0.3),
                  ),
                  // Full scrollable value
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Spacing.md),
                        decoration: BoxDecoration(
                          color: isDark
                              ? context.colors.surfaceContainerHighest
                              : context.colors.surfaceContainerHighest,
                          borderRadius: AppRadii.borderRadiusMD,
                          border: Border.all(
                            color: ctx.colors.outline
                                .withValues(alpha: isDark ? 0.08 : 0.2),
                          ),
                        ),
                        child: SelectableText(
                          valueStr,
                          style: AppTypography.bodySmall.copyWith(
                            fontFamily: 'monospace',
                            color: ctx.colors.onSurface.withValues(alpha: 0.85),
                            height: 1.7,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries;
    final isDark = context.isDark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium SliverAppBar with gradient
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            backgroundColor: context.colors.surface,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 56,
                bottom: Spacing.md,
                right: Spacing.md,
              ),
              title: Text(
                '🛠️ Cache Inspector',
                style: AppTypography.titleSmall.copyWith(
                  color:
                      isDark ? AppColors.onSurfaceDark : AppColors.primaryLight,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.primaryContainerDark,
                            context.colors.surface,
                          ]
                        : [
                            AppColors.primaryContainerLight,
                            context.colors.surface,
                          ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative grid pattern
                    Positioned.fill(
                      child: CustomPaint(painter: _GridPainter(isDark: isDark)),
                    ),
                    // Stats overlay
                    Positioned(
                      left: Spacing.lg,
                      bottom: 56,
                      right: Spacing.lg,
                      child: Row(
                        children: [
                          _StatChip(
                            icon: Icons.storage_rounded,
                            label: '${_allPrefs.length}',
                            subtitle: 'entries',
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: Spacing.sm),
                          _StatChip(
                            icon: Icons.search_rounded,
                            label: '${entries.length}',
                            subtitle: 'visible',
                            color: context.appColors.chartTeal,
                          ),
                          const Spacer(),
                          // Pulsing live indicator
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) => Opacity(
                              opacity: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.sm,
                                  vertical: Spacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.success
                                      .withValues(alpha: 0.15),
                                  borderRadius: AppRadii.borderRadiusFull,
                                  border: Border.all(
                                    color: context.appColors.success
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: context.appColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'LIVE',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: context.appColors.success,
                                        fontSize: 9,
                                        letterSpacing: 1.2,
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
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _loadCache,
                tooltip: 'Reload Cache',
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_forever_rounded,
                  color: context.colors.error,
                ),
                onPressed: _allPrefs.isNotEmpty ? _clearCache : null,
                tooltip: 'Nuke Cache',
              ),
            ],
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.md,
                Spacing.lg,
                Spacing.sm,
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search keys or values…',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color:
                        context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color:
                        context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? context.colors.onSurface.withValues(alpha: 0.05)
                      : context.colors.onSurface.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.borderRadiusMD,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                ),
              ),
            ),
          ),

          // Body
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (entries.isEmpty && _searchQuery.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: context.colors.onSurfaceVariant
                          .withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'No matches for "$_searchQuery"',
                      style: AppTypography.titleSmall.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_allPrefs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: context.colors.onSurfaceVariant
                          .withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'Cache is empty',
                      style: AppTypography.titleMedium.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Nothing stored in SharedPreferences yet.',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.onSurfaceVariant
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.lg,
                Spacing.xxl,
              ),
              sliver: SliverList.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final key = entry.key;
                  final value = entry.value;
                  final valueStr = value.toString();
                  final typeColor = _getTypeColor(value, context);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: _CacheEntryCard(
                      entryKey: key,
                      value: valueStr,
                      typeLabel: _getTypeLabel(value),
                      typeColor: typeColor,
                      typeIcon: _getTypeIcon(value),
                      onTap: () => _showDetailSheet(key, value, typeColor),
                      onLongPress: () => _copyValue(key, valueStr),
                      index: index,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Stat Chip (used in the header)

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadii.borderRadiusSM,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(color: color),
          ),
          const SizedBox(width: 2),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: color.withValues(alpha: 0.7),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// Cache Entry Card

class _CacheEntryCard extends StatelessWidget {
  const _CacheEntryCard({
    required this.entryKey,
    required this.value,
    required this.typeLabel,
    required this.typeColor,
    required this.typeIcon,
    required this.onTap,
    required this.onLongPress,
    required this.index,
  });
  final String entryKey;
  final String value;
  final String typeLabel;
  final Color typeColor;
  final IconData typeIcon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? context.colors.onSurface.withValues(alpha: 0.04)
            : context.colors.surface,
        borderRadius: AppRadii.borderRadiusLG,
        border: Border.all(
          color: context.colors.outline.withValues(alpha: isDark ? 0.12 : 0.4),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.borderRadiusLG,
        child: InkWell(
          borderRadius: AppRadii.borderRadiusLG,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: Spacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: icon + key + type badge + copy
                Row(
                  children: [
                    // Type icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: AppRadii.borderRadiusSM,
                      ),
                      child: Icon(typeIcon, size: 16, color: typeColor),
                    ),
                    const SizedBox(width: Spacing.sm),
                    // Key name
                    Expanded(
                      child: Text(
                        entryKey,
                        style: AppTypography.titleSmall.copyWith(
                          color: context.colors.onSurface,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: AppRadii.borderRadiusFull,
                      ),
                      child: Text(
                        typeLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: typeColor,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    // Copy button
                    Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: context.colors.onSurfaceVariant
                          .withValues(alpha: 0.4),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                // Divider
                Container(
                  height: 1,
                  color: context.colors.outline
                      .withValues(alpha: isDark ? 0.08 : 0.25),
                ),
                const SizedBox(height: Spacing.sm),
                // Value in monospace
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: isDark
                        ? context.colors.surfaceContainerHighest
                        : context.colors.surfaceContainerHighest,
                    borderRadius: AppRadii.borderRadiusSM,
                  ),
                  child: Text(
                    value,
                    style: AppTypography.bodySmall.copyWith(
                      fontFamily: 'monospace',
                      color: context.colors.onSurface.withValues(alpha: 0.8),
                      height: 1.6,
                    ),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Decorative Grid Painter

class _GridPainter extends CustomPainter {
  _GridPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000))
          .withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    const spacing = 24.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
