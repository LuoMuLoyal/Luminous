import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/scan/domain/services/ocr_service.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

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
  return showFSheet<String>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    // State
    final recognizedText = useState<String?>(null);
    final isRecognizing = useState(false);
    final imagePath = useState<String?>(null);
    final textController = useTextEditingController();
    final textFocus = useFocusNode();

    Future<void> pickAndRecognize(ImageSource source) async {
      final locale = Localizations.localeOf(context);
      final photo = await pickImage(source);
      if (photo == null) return;

      imagePath.value = photo.path;
      recognizedText.value = null;
      textController.clear();
      isRecognizing.value = true;

      try {
        final text = await recognizeText(photo, locale);
        recognizedText.value = text;
        textController.text = text;
      } catch (e) {
        ref
            .read(talkerProvider)
            .error('RecordOcrEntryDialog: recognizeText failed: $e');
        if (context.mounted) {
          await AppToast.show(context, l10n.recordOcrRecognitionFailed);
        }
      } finally {
        isRecognizing.value = false;
      }
    }

    Future<void> handleUseText() async {
      final text = textController.text.trim();
      if (text.isEmpty) return;
      if (context.mounted) {
        Navigator.of(context).pop(text);
      }
    }

    void handleRetake() {
      imagePath.value = null;
      recognizedText.value = null;
      textController.clear();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          children: [
            const SheetDragHandle(),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.level5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recordOcrEntryTitle,
                      style: typography.body.xl2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FButton.icon(
                    onPress: () => Navigator.of(context).pop(),
                    variant: FButtonVariant.ghost,
                    child: const Icon(FLucideIcons.x),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.level4),

            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.level5),
                child: Column(
                  children: [
                    // Image source picker (shown when no image yet)
                    if (imagePath.value == null) ...[
                      const SizedBox(height: Spacing.level3),
                      Row(
                        children: [
                          Expanded(
                            child: _OptionCard(
                              icon: FLucideIcons.camera,
                              label: l10n.recordOcrCameraAction,
                              onTap: () => pickAndRecognize(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: Spacing.level4),
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
                      const SizedBox(height: Spacing.level3),
                      // Image thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          RadiusTokens.level4,
                        ),
                        child: Image.file(
                          File(imagePath.value!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: Spacing.level3),
                      // Retake button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FButton(
                          variant: FButtonVariant.ghost,
                          onPress: isRecognizing.value ? null : handleRetake,
                          prefix: const Icon(FLucideIcons.refreshCw, size: 16),
                          child: Text(l10n.recordOcrRetakeAction),
                        ),
                      ),
                      const SizedBox(height: Spacing.level4),

                      // Recognizing indicator
                      if (isRecognizing.value) ...[
                        const SizedBox(height: Spacing.level5),
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: FCircularProgress(),
                        ),
                        const SizedBox(height: Spacing.level3),
                        Text(
                          l10n.recordOcrRecognizingHint,
                          style: typography.body.sm.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],

                      // Recognized text (editable)
                      if (recognizedText.value != null &&
                          !isRecognizing.value) ...[
                        if (recognizedText.value!.isEmpty) ...[
                          const SizedBox(height: Spacing.level3),
                          Row(
                            children: [
                              Icon(
                                FLucideIcons.fileSearch,
                                size: Spacing.level5,
                                color: colors.mutedForeground,
                              ),
                              const SizedBox(width: Spacing.level3),
                              Expanded(
                                child: Text(
                                  l10n.recordOcrEmptyResult,
                                  style: typography.body.sm.copyWith(
                                    color: colors.mutedForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          FTextField(
                            key: const Key('record-ocr-result-field'),
                            control: FTextFieldControl.managed(
                              controller: textController,
                            ),
                            focusNode: textFocus,
                            minLines: 3,
                            maxLines: 8,
                            label: Text(l10n.recordOcrEntryTitle),
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),

            // Use text button
            if (recognizedText.value != null && !isRecognizing.value) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.level5),
                child: SizedBox(
                  width: double.infinity,
                  child: FButton(
                    onPress: (textController.text.trim().isNotEmpty)
                        ? handleUseText
                        : null,
                    child: Text(l10n.recordVoiceUseText),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.level5),
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FButton.raw(
      onPress: onTap,
      variant: FButtonVariant.outline,
      style: .delta(
        decoration: .delta([
          .all(
            .shapeDelta(
              color: colors.background,
              shape: RoundedSuperellipseBorder(
                side: BorderSide(color: colors.border),
              ),
            ),
          ),
        ]),
        contentStyle: const .delta(
          padding: .value(EdgeInsets.symmetric(vertical: Spacing.level6)),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: colors.primary),
          const SizedBox(height: Spacing.level3),
          Text(
            label,
            style: typography.body.sm.copyWith(color: colors.foreground),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
