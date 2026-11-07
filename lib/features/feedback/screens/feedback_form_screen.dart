import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:verso/core/design/components/verso_button.dart';
import 'package:verso/core/design/components/verso_snackbar.dart';
import 'package:verso/core/design/tokens/radii.dart';
import 'package:verso/core/providers/package_info_provider.dart';
import 'package:verso/features/feedback/models/feedback_type.dart';
import 'package:verso/features/feedback/providers/feedback_providers.dart';

/// Form screen allowing the user to type feedback and attach a screenshot.
class FeedbackFormScreen extends ConsumerStatefulWidget {
  const FeedbackFormScreen({
    required this.type,
    super.key,
  });

  final FeedbackType type;

  @override
  ConsumerState<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends ConsumerState<FeedbackFormScreen> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();

  Uint8List? _imageBytes;
  String? _imageName;
  int _imageSize = 0;
  bool _isPickingImage = false;

  static const int _maxChars = 1000;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isPickingImage = true);
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = picked.name;
          _imageSize = bytes.lengthInBytes;
        });
      }
    } catch (e) {
      if (mounted) {
        VersoSnackbar.error(
          context,
          message: 'Could not access image: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showImagePickerOptions() {
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(16),
              Text(
                'Attach Screenshot',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const Gap(16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
      _imageSize = 0;
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.length < 5) {
      VersoSnackbar.error(
        context,
        message: 'Please provide a little more detail (at least 5 characters).',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref.read(feedbackSubmissionProvider.notifier).submit(
          type: widget.type,
          message: text,
          imageBytes: _imageBytes,
          imageName: _imageName,
        );

    if (!mounted) return;

    if (success) {
      HapticFeedback.mediumImpact();
      VersoSnackbar.success(
        context,
        message: widget.type == FeedbackType.issue
            ? 'Thank you! Your issue report has been submitted.'
            : 'Thank you! Your idea has been shared with the team.',
      );
      Navigator.of(context).pop(); // Back to Hub
      Navigator.of(context).pop(); // Back to Settings
    } else {
      // Show fallback option
      _showFallbackDialog(text);
    }
  }

  void _showFallbackDialog(String text) {
    final scheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Submission Notice',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'We could not connect directly to the feedback database. Would you like to send this via your email app instead?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: scheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(feedbackSubmissionProvider.notifier).fallbackEmail(
                    type: widget.type,
                    message: text,
                  );
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final packageInfo = ref.watch(packageInfoProvider);
    final submissionState = ref.watch(feedbackSubmissionProvider);
    final isLoading = submissionState.isLoading;

    final bgColor = isDark ? const Color(0xFF0C0D0E) : scheme.surface;
    final cardBg = isDark
        ? const Color(0xFF16181A)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.35);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.type.shortTitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.type.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.type.accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.type.icon,
                      color: widget.type.accentColor,
                      size: 20,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        widget.type.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),

              // Section Header: Description
              Text(
                'DESCRIPTION',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Gap(8),

              // Textarea
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppRadii.borderRadiusMD,
                  border: Border.all(
                    color: scheme.outlineVariant
                        .withValues(alpha: isDark ? 0.25 : 0.6),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: 7,
                      maxLength: _maxChars,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        color: scheme.onSurface,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.type.inputPlaceholder,
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color:
                              scheme.onSurfaceVariant.withValues(alpha: 0.65),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${_textController.text.length} / $_maxChars',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Section Header: Attachment
              Text(
                'SCREENSHOT (OPTIONAL)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Gap(8),

              // Image Attachment View
              if (_imageBytes == null)
                Material(
                  color: cardBg,
                  borderRadius: AppRadii.borderRadiusMD,
                  child: InkWell(
                    borderRadius: AppRadii.borderRadiusMD,
                    onTap: _isPickingImage ? null : _showImagePickerOptions,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.borderRadiusMD,
                        border: Border.all(
                          color: scheme.outlineVariant
                              .withValues(alpha: isDark ? 0.2 : 0.5),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isPickingImage)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 32,
                              color: scheme.primary,
                            ),
                          const Gap(8),
                          Text(
                            'Add a screenshot or image',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          const Gap(3),
                          Text(
                            'Helps us understand and resolve the matter quickly',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                // Attached Image Preview Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppRadii.borderRadiusMD,
                    border: Border.all(
                      color: scheme.outlineVariant
                          .withValues(alpha: isDark ? 0.25 : 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _imageBytes!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _imageName ?? 'Screenshot',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            const Gap(3),
                            Text(
                              _formatFileSize(_imageSize),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: scheme.error,
                        tooltip: 'Remove',
                        onPressed: _removeImage,
                      ),
                    ],
                  ),
                ),

              const Gap(24),

              // Diagnostics notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Verso v${packageInfo.version} & device info will be sent with your feedback.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(32),

              // Submit Button
              VersoButton(
                label: widget.type.buttonLabel,
                expand: true,
                isLoading: isLoading,
                onPressed: _textController.text.trim().isEmpty ? null : _submit,
              ),

              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }
}
