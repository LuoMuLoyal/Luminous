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

/// Shows a PIN verification dialog and returns `true` if the user
/// successfully verified their PIN (or already has a valid elevation
/// token), `false` if the user cancelled or verification failed.
///
/// If the Security PIN is not enabled, returns `false` immediately
/// — the caller should handle this case (e.g. show a toast).
Future<bool> showSecurityElevationDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context)!;

  final elevationController = ref.read(
    securityElevationControllerProvider.notifier,
  );
  final elevationState = ref.read(securityElevationControllerProvider);
  if (elevationState is SecurityElevationVerified) {
    if (DateTime.now().isBefore(elevationState.expiresAt) &&
        elevationController.hasValidToken) {
      return true;
    }
    elevationController.clear();
  }

  // Check if PIN is enabled. An unresolved settings read is unknown, not
  // equivalent to a disabled PIN; wait for it before deciding.
  UserSettings? settings = ref
      .read(userSettingsControllerProvider)
      .asData
      ?.value;
  if (settings == null) {
    try {
      settings = await ref.read(userSettingsControllerProvider.future);
    } catch (_) {
      if (context.mounted) {
        await Toast.show(context, l10n.settingsSyncFailed);
      }
      return false;
    }
  }
  final resolvedSettings = settings;
  if (!context.mounted) return false;
  if (resolvedSettings == null || !resolvedSettings.securityPin.enabled) {
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
  WidgetRef ref,
) async {
  final session = ref.read(authSessionProvider);
  if (!session.canAccessProtectedData) {
    return SecurityElevationResult.cancelled;
  }

  final elevationController = ref.read(
    securityElevationControllerProvider.notifier,
  );
  final elevationState = ref.read(securityElevationControllerProvider);
  if (elevationState is SecurityElevationVerified &&
      DateTime.now().isBefore(elevationState.expiresAt) &&
      elevationController.hasValidToken) {
    return SecurityElevationResult.verified;
  }

  UserSettings? settings = ref
      .read(userSettingsControllerProvider)
      .asData
      ?.value;
  if (settings == null) {
    try {
      settings = await ref.read(userSettingsControllerProvider.future);
    } catch (_) {
      return SecurityElevationResult.cancelled;
    }
  }

  final resolvedSettings = settings;
  if (resolvedSettings == null || !context.mounted) {
    return SecurityElevationResult.cancelled;
  }

  if (!resolvedSettings.securityPin.enabled) {
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
  final verified = await showSecurityElevationDialog(context, ref);
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
