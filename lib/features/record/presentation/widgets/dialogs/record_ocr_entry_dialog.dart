import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/scan/domain/services/ocr_service.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows a bottom sheet for photo-based text recognition and returns the
/// recognized text.
///
/// Returns `null` if the user cancels or no text was recognized.
typedef RecordOcrImagePicker = Future<XFile?> Function(ImageSource source);
typedef RecordOcrRecognizer =
    Future<String> Function(XFile image, Locale locale);

Future<String?> showRecordOcrEntrySheet(
  BuildContext context, {
  RecordOcrImagePicker? pickImage,
  RecordOcrRecognizer? recognizeText,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadiusTokens.level5),
      ),
    ),
    builder: (dialogContext) => _RecordOcrEntrySheet(
      pickImage:
          pickImage ??
          ((source) =>
              ImagePicker().pickImage(source: source, imageQuality: 90)),
      recognizeText:
          recognizeText ??
          ((image, locale) =>
              const OcrService().recognizeText(image, locale: locale)),
    ),
  );
}

class _RecordOcrEntrySheet extends HookConsumerWidget {
  const _RecordOcrEntrySheet({
    required this.pickImage,
    required this.recognizeText,
  });

  final RecordOcrImagePicker pickImage;
  final RecordOcrRecognizer recognizeText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = context.theme.colors;
    final textTheme = theme.textTheme;

    // State
    final recognizedText = useState<String?>(null);
    final isRecognizing = useState(false);
    final imagePath = useState<String?>(null);

    Future<void> pickAndRecognize(ImageSource source) async {
      final locale = Localizations.localeOf(context);
      final photo = await pickImage(source);
      if (photo == null) return;

      imagePath.value = photo.path;
      recognizedText.value = null;
      isRecognizing.value = true;

      try {
        final text = await recognizeText(photo, locale);
        recognizedText.value = text;
      } catch (e) {
        if (context.mounted) {
          await AppToast.show(context, l10n.recordOcrRecognitionFailed);
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
            const SizedBox(height: AppSpacingTokens.level3),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(AppRadiusTokens.levelFull),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level4),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.level5,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recordOcrEntryTitle,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FLucideIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level4),

            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.level5,
                ),
                child: Column(
                  children: [
                    // Image source picker (shown when no image yet)
                    if (imagePath.value == null) ...[
                      const SizedBox(height: AppSpacingTokens.level3),
                      Row(
                        children: [
                          Expanded(
                            child: _OptionCard(
                              icon: FLucideIcons.camera,
                              label: l10n.recordOcrCameraAction,
                              onTap: () => pickAndRecognize(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: AppSpacingTokens.level4),
                          Expanded(
                            child: _OptionCard(
                              icon: FLucideIcons.images,
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
                      const SizedBox(height: AppSpacingTokens.level3),
                      // Image thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppRadiusTokens.level4,
                        ),
                        child: Image.file(
                          File(imagePath.value!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: AppSpacingTokens.level4),

                      // Recognizing indicator
                      if (isRecognizing.value) ...[
                        const SizedBox(height: AppSpacingTokens.level5),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.level3),
                        Text(
                          l10n.recordOcrRecognizingHint,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],

                      // Recognized text
                      if (recognizedText.value != null &&
                          !isRecognizing.value) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            AppSpacingTokens.level4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(
                              AppRadiusTokens.level4,
                            ),
                            border: Border.all(color: colors.border),
                          ),
                          child: Text(
                            recognizedText.value!.isEmpty
                                ? l10n.recordNlpEmptyCandidatesToast
                                : recognizedText.value!,
                            style: recognizedText.value!.isEmpty
                                ? textTheme.bodyMedium?.copyWith(
                                    color: colors.mutedForeground,
                                  )
                                : textTheme.bodyMedium,
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
                  horizontal: AppSpacingTokens.level5,
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
              const SizedBox(height: AppSpacingTokens.level5),
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
    final colors = context.theme.colors;
    final textTheme = theme.textTheme;

    return FTappable(
      onPress: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level6),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacingTokens.level3),
            Text(
              label,
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
