import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/i18n/speech_locale_resolver.dart';
import 'package:luminous/features/record/domain/services/voice_recording_service.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

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
          debugPrint('RecordVoiceEntryDialog.init: hasPermission failed: $e');
          hasPermission.value = false;
        }
      }
    }

    Future<void> toggleListening() async {
      if (!isInitialized.value) {
        await init();
        if (!isInitialized.value) {
          if (!context.mounted) return;
          if (hasPermission.value == false) {
            await AppToast.show(context, l10n.recordMicPermissionDenied);
          } else {
            await AppToast.show(context, l10n.recordMicPermissionDenied);
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
            await AppToast.show(context, l10n.recordMicPermissionDenied);
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
        : colors.mutedForeground.withValues(alpha: 0.55);

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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.level5,
              ),
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
            const SizedBox(height: AppSpacingTokens.level4),

            // Recognized text display
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.level5,
                ),
                padding: const EdgeInsets.all(AppSpacingTokens.level4),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
                  border: Border.all(color: colors.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    recognizedText.value.isEmpty
                        ? l10n.recordVoiceTapToStart
                        : recognizedText.value,
                    style: recognizedText.value.isEmpty
                        ? typography.body.md.copyWith(
                            color: colors.mutedForeground,
                          )
                        : typography.body.md,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level4),

            // Sound level indicator + mic button
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse animation ring (visible when listening)
                  if (isListening.value)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 72 + soundLevel.value * 40,
                      height: 72 + soundLevel.value * 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.12),
                      ),
                    ),

                  // Mic button
                  GestureDetector(
                    onTap: toggleListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening.value
                            ? primaryColor
                            : colors.secondary,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isListening.value
                                        ? primaryColor
                                        : colors.foreground)
                                    .withValues(alpha: 0.2),
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
            const SizedBox(height: AppSpacingTokens.level3),

            // Use text button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.level5,
              ),
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
            const SizedBox(height: AppSpacingTokens.level5),
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
