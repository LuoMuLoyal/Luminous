import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/scan/domain/services/ocr_service.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows a bottom sheet for photo-based text recognition and returns the
/// recognized text.
///
/// Returns `null` if the user cancels or no text was recognized.
Future<String?> showRecordOcrEntrySheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadiusTokens.xl),
      ),
    ),
    builder: (dialogContext) => _RecordOcrEntrySheet(),
  );
}

class _RecordOcrEntrySheet extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    // State
    final recognizedText = useState<String?>(null);
    final isRecognizing = useState(false);
    final imagePath = useState<String?>(null);

    Future<void> pickAndRecognize(ImageSource source) async {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: source, imageQuality: 90);
      if (photo == null) return;

      imagePath.value = photo.path;
      recognizedText.value = null;
      isRecognizing.value = true;

      try {
        const ocr = OcrService();
        final text = await ocr.recognizeText(photo);
        recognizedText.value = text;
      } catch (e) {
        if (context.mounted) {
          await AppToast.show(
            context,
            l10n.recordNlpInputRequiredToast, // fallback for now
          );
        }
      } finally {
        isRecognizing.value = false;
      }
    }

    Future<void> handleUseText() async {
      final text = recognizedText.value?.trim() ?? '';
      if (text.isEmpty) return;
      if (context.mounted) {
        Navigator.of(context).pop(text);
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: AppSpacingTokens.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: surface.mute,
                borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recordOcrEntryTitle,
                      style: typography.displaySm,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),

            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.lg,
                ),
                child: Column(
                  children: [
                    // Image source picker (shown when no image yet)
                    if (imagePath.value == null) ...[
                      const SizedBox(height: AppSpacingTokens.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _OptionCard(
                              icon: Icons.camera_alt_outlined,
                              label: l10n.recordOcrCameraAction,
                              onTap: () => pickAndRecognize(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: AppSpacingTokens.md),
                          Expanded(
                            child: _OptionCard(
                              icon: Icons.photo_library_outlined,
                              label: l10n.recordOcrGalleryAction,
                              onTap: () =>
                                  pickAndRecognize(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Image preview + result
                    if (imagePath.value != null) ...[
                      const SizedBox(height: AppSpacingTokens.sm),
                      // Image thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                        child: Image.file(
                          File(imagePath.value!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: AppSpacingTokens.md),

                      // Recognizing indicator
                      if (isRecognizing.value) ...[
                        const SizedBox(height: AppSpacingTokens.lg),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.sm),
                        Text(
                          l10n.recordOcrRecognizingHint,
                          style: typography.caption.copyWith(
                            color: surface.mute,
                          ),
                        ),
                      ],

                      // Recognized text
                      if (recognizedText.value != null &&
                          !isRecognizing.value) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacingTokens.md),
                          decoration: BoxDecoration(
                            color: surface.canvas,
                            borderRadius: BorderRadius.circular(
                              AppRadiusTokens.lg,
                            ),
                            border: Border.all(color: surface.hairline),
                          ),
                          child: Text(
                            recognizedText.value!.isEmpty
                                ? l10n.recordNlpEmptyCandidatesToast
                                : recognizedText.value!,
                            style: recognizedText.value!.isEmpty
                                ? typography.bodyMd.copyWith(
                                    color: surface.mute,
                                  )
                                : typography.bodyMd,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            // Use text button
            if (recognizedText.value != null && !isRecognizing.value) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.lg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        (recognizedText.value?.trim().isNotEmpty ?? false)
                        ? handleUseText
                        : null,
                    child: Text(l10n.recordVoiceUseText),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.lg),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xl),
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Column(
            children: [
              Icon(icon, size: 36, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                label,
                style: typography.bodySm,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
