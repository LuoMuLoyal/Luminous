import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/i18n/speech_locale_resolver.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/widgets/common/sheet_drag_handle.dart';
import 'package:luminous/features/record/domain/services/voice_recording.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows a bottom sheet for voice input and returns the recognized text.
///
/// Returns `null` if the user cancels or no text was recognized.
Future<String?> showRecordVoiceEntrySheet(BuildContext context) {
  return showFSheet<String>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
    builder: (dialogContext) => _RecordVoiceEntrySheet(),
  );
}

class _RecordVoiceEntrySheet extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    // Service lifecycle: create once, dispose on unmount.
    final service = useMemoized(() => VoiceRecordingService());
    useEffect(
      () =>
          () => service.dispose(),
      [service],
    );

    // State
    final isInitialized = useState(false);
    final isListening = useState(false);
    final recognizedText = useState('');
    final soundLevel = useState(0.0);
    final errorMessage = useState<String?>(null);
    final hasPermission = useState<bool?>(null);
    final locale = Localizations.localeOf(context);

    // Editable text controller for recognized text.
    final textController = useTextEditingController();

    // Sync textController when recognizedText changes from the speech
    // recognition stream (but not when the user is editing manually).
    useEffect(() {
      // Only update if the stream value differs from what's in the
      // controller (avoids cursor jumps during user editing).
      if (textController.text != recognizedText.value) {
        textController.text = recognizedText.value;
      }
      return null;
    }, [recognizedText.value]);

    // Stream subscriptions
    useEffect(() {
      void onText(String text) {
        recognizedText.value = text;
      }

      void onListening(bool listening) {
        isListening.value = listening;
      }

      void onSoundLevel(double level) {
        soundLevel.value = level;
      }

      void onError(String error) {
        errorMessage.value = error;
      }

      final textSub = service.recognizedTextStream.listen(onText);
      final listeningSub = service.listeningStatusStream.listen(onListening);
      final soundSub = service.soundLevelStream.listen(onSoundLevel);
      final errorSub = service.errorStream.listen(onError);

      return () {
        textSub.cancel();
        listeningSub.cancel();
        soundSub.cancel();
        errorSub.cancel();
      };
    }, [service]);

    // Initialize
    Future<void> init() async {
      final available = await service.initialize(
        localeId: speechLocaleIdForAppLocale(locale),
      );
      final resolvedLocaleId = await _resolveSpeechLocaleId(service, locale);
      final ok = available && resolvedLocaleId != null;
      isInitialized.value = ok;
      if (!ok) {
        try {
          final perm = await service.hasPermission;
          hasPermission.value = perm;
        } catch (e) {
          ref
              .read(talkerProvider)
              .error('RecordVoiceEntryDialog.init: hasPermission failed: $e');
          hasPermission.value = false;
        }
      }
    }

    Future<void> toggleListening() async {
      if (!isInitialized.value) {
        await init();
        if (!isInitialized.value) {
          if (!context.mounted) return;
          // Distinguish three failure scenarios:
          // 1. Mic permission denied → permission-specific message
          // 2. Speech recognition unavailable → device-capability message
          // 3. Locale not supported → locale message
          if (hasPermission.value == false) {
            errorMessage.value = l10n.recordMicPermissionDenied;
          } else {
            // init() sets hasPermission only when available is false.
            // If hasPermission is true/null but init still failed, it means
            // speech recognition itself is unavailable or locale mismatch.
            final localeId = await _resolveSpeechLocaleId(service, locale);
            if (localeId == null) {
              errorMessage.value = l10n.recordSpeechLocaleUnsupported;
            } else {
              errorMessage.value = l10n.recordSpeechUnavailable;
            }
          }
          return;
        }
      }

      if (isListening.value) {
        final text = await service.stopListening();
        recognizedText.value = text;
      } else {
        errorMessage.value = null;
        recognizedText.value = '';
        final localeId = await _resolveSpeechLocaleId(service, locale);
        if (localeId == null) {
          if (context.mounted) {
            errorMessage.value = l10n.recordSpeechLocaleUnsupported;
          }
          return;
        }
        await service.startListening(localeId: localeId);
      }
    }

    Future<void> handleUseText() async {
      final text = recognizedText.value.trim();
      if (text.isEmpty) return;
      await service.cancelListening();
      if (context.mounted) {
        Navigator.of(context).pop(text);
      }
    }

    // Initialize on first build
    useEffect(() {
      init();
      return null;
    }, []);

    final primaryColor = colors.primary;
    final micColor = isListening.value
        ? primaryColor
        : SemanticColor.neutral.fill(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 380,
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
                      l10n.recordVoiceEntryTitle,
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

            // Error message (shown inline when present)
            if (errorMessage.value != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.level5),
                child: Row(
                  children: [
                    Icon(
                      FLucideIcons.circleAlert,
                      color: colors.destructive,
                      size: 16,
                    ),
                    const SizedBox(width: Spacing.level2),
                    Expanded(
                      child: Text(
                        errorMessage.value!,
                        style: typography.body.sm.copyWith(
                          color: colors.destructive,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.level3),
            ],

            // Recognized text display (editable)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Spacing.level5),
                padding: const EdgeInsets.all(Spacing.level4),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(RadiusTokens.level4),
                  border: Border.all(color: colors.border),
                ),
                child: Material(
                  color: const Color(0x00000000),
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: recognizedText.value.isEmpty
                          ? l10n.recordVoiceTapToStart
                          : l10n.recordVoiceEditHint,
                      hintStyle: typography.body.md.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                    style: typography.body.md,
                    onChanged: (text) => recognizedText.value = text,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.level4),

            // Sound level indicator + mic button
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse animation ring (visible when listening)
                  if (isListening.value)
                    AnimatedContainer(
                      duration: DurationTokens.widgetStandard,
                      width: 72 + soundLevel.value * 40,
                      height: 72 + soundLevel.value * 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SemanticColor.primary.muted(context),
                      ),
                    ),

                  // Mic button
                  Semantics(
                    button: true,
                    label: isListening.value
                        ? l10n.recordVoiceStopListening
                        : l10n.recordVoiceTapToStart,
                    child: FTappable(
                      onPress: toggleListening,
                      child: AnimatedContainer(
                        duration: DurationTokens.widgetQuick,
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isListening.value
                              ? primaryColor
                              : colors.secondary,
                          boxShadow: [
                            BoxShadow(
                              color: (isListening.value
                                  ? SemanticColor.primary.borderStrong(context)
                                  : SemanticColor.neutral.borderStrong(
                                      context,
                                    )),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isListening.value
                              ? FLucideIcons.mic
                              : FLucideIcons.micOff,
                          color: isListening.value
                              ? colors.primaryForeground
                              : micColor,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  // Listening hint text
                  if (isListening.value)
                    Positioned(
                      bottom: 0,
                      child: Text(
                        l10n.recordVoiceListeningHint,
                        style: typography.body.xs.copyWith(color: primaryColor),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.level3),

            // Use text button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.level5),
              child: SizedBox(
                width: double.infinity,
                child: FButton(
                  onPress: recognizedText.value.trim().isNotEmpty
                      ? handleUseText
                      : null,
                  child: Text(l10n.recordVoiceUseText),
                ),
              ),
            ),
            const SizedBox(height: Spacing.level5),
          ],
        ),
      ),
    );
  }
}

Future<String?> _resolveSpeechLocaleId(
  VoiceRecordingService service,
  Locale locale,
) async {
  final locales = await service.locales();
  return resolveSpeechLocaleId(locale, locales.map((entry) => entry.localeId));
}
