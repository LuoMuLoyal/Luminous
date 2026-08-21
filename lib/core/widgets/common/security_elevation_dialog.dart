import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/security_elevation.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Default time source used when no override is provided.
DateTime _defaultNow() => DateTime.now();

/// Shows a PIN verification dialog and returns `true` if the user
/// successfully verified their PIN (or already has a valid elevation
/// token), `false` if the user cancelled or verification failed.
///
/// If the Security PIN is not enabled, returns `false` immediately
/// — the caller should handle this case (e.g. show a toast).
Future<bool> showSecurityElevationDialog(
  BuildContext context,
  WidgetRef ref, {
  DateTime Function()? now,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final nowFn = now ?? _defaultNow;

  final elevationController = ref.read(
    securityElevationControllerProvider.notifier,
  );
  final elevationState = ref.read(securityElevationControllerProvider);
  if (_isElevationValid(elevationState, elevationController, nowFn)) {
    return true;
  }

  // Check if PIN is enabled. An unresolved settings read is unknown, not
  // equivalent to a disabled PIN; wait for it before deciding.
  UserSettings? settings;
  try {
    settings = await _resolvePinSettings(ref);
  } catch (_) {
    if (context.mounted) {
      await Toast.show(context, l10n.settingsSyncFailed);
    }
    return false;
  }
  if (!context.mounted) return false;
  if (settings == null || !settings.securityPin.enabled) {
    await _showNotEnabledToast(context, l10n);
    return false;
  }

  final result = await showAppDialog<bool>(
    context: context,
    maxWidth: 400,
    scrollable: false,
    barrierDismissible: true,
    builder: (dialogContext) =>
        _SecurityElevationDialogContent(l10n: l10n, ref: ref),
  );

  return result ?? false;
}

enum SecurityElevationResult { verified, cancelled, setupRequired }

/// Requests elevation for an export-like action and distinguishes a disabled
/// PIN from a cancelled/failed verification so the caller can route the user
/// to the PIN setup page instead of silently stopping at a toast.
Future<SecurityElevationResult> requestSecurityElevationOrSetup(
  BuildContext context,
  WidgetRef ref, {
  DateTime Function()? now,
}) async {
  final session = ref.read(authSessionProvider);
  if (!session.canAccessProtectedData) {
    return SecurityElevationResult.cancelled;
  }

  final elevationController = ref.read(
    securityElevationControllerProvider.notifier,
  );
  final elevationState = ref.read(securityElevationControllerProvider);
  final nowFn = now ?? _defaultNow;
  if (_isElevationValid(elevationState, elevationController, nowFn)) {
    return SecurityElevationResult.verified;
  }

  UserSettings? settings;
  try {
    settings = await _resolvePinSettings(ref);
  } catch (_) {
    return SecurityElevationResult.cancelled;
  }
  if (settings == null || !context.mounted) {
    return SecurityElevationResult.cancelled;
  }

  if (!settings.securityPin.enabled) {
    final setup = await showAppDialog<bool>(
      context: context,
      maxWidth: 420,
      scrollable: false,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsSecurityPinExportGuideTitle,
              style: TypographyToken.level6.body(dialogContext),
            ),
            const SizedBox(height: Spacing.level3),
            Text(
              l10n.settingsSecurityPinExportGuideMessage,
              style: TypographyToken.level4.body(dialogContext),
            ),
            const SizedBox(height: Spacing.level5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.commonCancel),
                ),
                const SizedBox(width: Spacing.level3),
                FButton(
                  onPress: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.settingsSecurityPinExportGuideAction),
                ),
              ],
            ),
          ],
        );
      },
    );
    return setup == true
        ? SecurityElevationResult.setupRequired
        : SecurityElevationResult.cancelled;
  }

  if (!context.mounted) return SecurityElevationResult.cancelled;
  final verified = await showSecurityElevationDialog(context, ref, now: nowFn);
  return verified
      ? SecurityElevationResult.verified
      : SecurityElevationResult.cancelled;
}

Future<void> _showNotEnabledToast(
  BuildContext context,
  AppLocalizations l10n,
) async {
  await Toast.show(context, l10n.securityElevationDialogNotEnabled);
}

/// Resolves the user settings needed for PIN checks, waiting for the async
/// provider when the cached value is not yet available.
///
/// Throws if the settings provider itself errors out (callers decide
/// whether to surface a toast or silently treat as cancelled).
Future<UserSettings?> _resolvePinSettings(WidgetRef ref) async {
  final settings = ref.read(userSettingsControllerProvider).asData?.value;
  if (settings != null) return settings;
  return await ref.read(userSettingsControllerProvider.future);
}

/// Checks whether the current elevation state has a valid (non-expired)
/// token. Clears the elevation controller if the state is verified but the
/// token has expired. Uses [nowFn] as the time source to stay consistent
/// with [SecurityElevationTokenHolder].
bool _isElevationValid(
  SecurityElevationState state,
  SecurityElevationController controller,
  DateTime Function() nowFn,
) {
  if (state is SecurityElevationVerified) {
    if (nowFn().isBefore(state.expiresAt) && controller.hasValidToken) {
      return true;
    }
    controller.clear();
  }
  return false;
}

class _SecurityElevationDialogContent extends HookConsumerWidget {
  const _SecurityElevationDialogContent({
    required this.l10n,
    required this.ref,
  });

  final AppLocalizations l10n;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef dialogRef) {
    final pin = useState('');
    final isVerifying = useState(false);
    final errorMessage = useState<String?>(null);
    final colors = context.theme.colors;

    Future<void> handleVerify() async {
      final value = pin.value;
      if (value.length != 6) {
        errorMessage.value = l10n.settingsSecurityPinInvalidPin;
        return;
      }

      isVerifying.value = true;
      errorMessage.value = null;

      final success = await ref
          .read(securityElevationControllerProvider.notifier)
          .verify(value);

      isVerifying.value = false;

      if (success) {
        if (context.mounted) Navigator.of(context).pop(true);
      } else {
        errorMessage.value = l10n.securityElevationDialogError;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.securityElevationDialogTitle,
          style: TypographyToken.level6.body(context),
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.securityElevationDialogSubtitle,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(height: Spacing.level4),
        FOtpField(
          control: FOtpFieldControl.managed(
            children: const [
              FOtpItem(),
              FOtpItem(),
              FOtpItem(),
              FOtpItem(),
              FOtpItem(),
              FOtpItem(),
            ],
            onChange: (value) => pin.value = value.text,
          ),
          label: Text(l10n.settingsSecurityPinEnterPin),
          autofocus: true,
          forceErrorText: errorMessage.value,
          onSubmit: isVerifying.value ? null : (_) => handleVerify(),
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: isVerifying.value
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(l10n.securityElevationDialogCancel),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              onPress: isVerifying.value ? null : handleVerify,
              child: isVerifying.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: Center(child: FCircularProgress()),
                    )
                  : Text(l10n.securityElevationDialogVerify),
            ),
          ],
        ),
      ],
    );
  }
}
