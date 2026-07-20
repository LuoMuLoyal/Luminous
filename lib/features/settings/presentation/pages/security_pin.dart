import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';

class SecurityPinSettingsPage extends HookConsumerWidget {
  const SecurityPinSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final settingsAsync = ref.watch(userSettingsControllerProvider);
    final settings = settingsAsync.asData?.value;
    final pinEnabled = settings?.securityPin.enabled ?? false;
    final lastChangedAt = settings?.securityPin.lastChangedAt;

    final enablePinController = useTextEditingController();
    final enablePinConfirmController = useTextEditingController();
    final oldPinController = useTextEditingController();
    final newPinController = useTextEditingController();
    final confirmPinController = useTextEditingController();
    final disablePinController = useTextEditingController();
    final isSubmitting = useState(false);
    final enablePinError = useState<String?>(null);
    final enablePinConfirmError = useState<String?>(null);
    final oldPinError = useState<String?>(null);
    final newPinError = useState<String?>(null);
    final confirmPinError = useState<String?>(null);
    final disablePinError = useState<String?>(null);

    // Clear inline errors when the user edits the corresponding field.
    useEffect(() {
      void clear() => enablePinError.value = null;
      void clearConfirm() => enablePinConfirmError.value = null;
      void clearOld() => oldPinError.value = null;
      void clearNew() => newPinError.value = null;
      void clearConfirmNew() => confirmPinError.value = null;
      void clearDisable() => disablePinError.value = null;
      enablePinController.addListener(clear);
      enablePinConfirmController.addListener(clearConfirm);
      oldPinController.addListener(clearOld);
      newPinController.addListener(clearNew);
      confirmPinController.addListener(clearConfirmNew);
      disablePinController.addListener(clearDisable);
      return () {
        enablePinController.removeListener(clear);
        enablePinConfirmController.removeListener(clearConfirm);
        oldPinController.removeListener(clearOld);
        newPinController.removeListener(clearNew);
        confirmPinController.removeListener(clearConfirmNew);
        disablePinController.removeListener(clearDisable);
      };
    }, []);

    return PageScaffold(
      title: l10n.settingsSecurityPinTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.sizeOf(context).width < Breakpoints.mobile
                  ? Spacing.level6
                  : Spacing.level7,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Status card --
                FCard.raw(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.level5),
                    child: Row(
                      children: [
                        Icon(
                          pinEnabled
                              ? FLucideIcons.shieldCheck
                              : FLucideIcons.shieldOff,
                          size: 28,
                          color: pinEnabled
                              ? colors.primary
                              : colors.mutedForeground,
                        ),
                        const SizedBox(width: Spacing.level4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pinEnabled
                                    ? l10n.settingsSecurityPinStatusEnabled
                                    : l10n.settingsSecurityPinStatusDisabled,
                                style: TypographyToken.level5
                                    .body(context)
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: Spacing.level1),
                              Text(
                                _lastChangedLabel(
                                  l10n,
                                  Localizations.localeOf(context),
                                  lastChangedAt,
                                ),
                                style: TypographyToken.level3
                                    .body(context)
                                    .copyWith(color: colors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.level3),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.level2,
                  ),
                  child: Text(
                    l10n.settingsSecurityPinDescription,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                  ),
                ),
                const SizedBox(height: Spacing.level5),

                if (!pinEnabled) ...[
                  // -- Enable PIN --
                  SettingsSectionLabel(
                    label: l10n.settingsSecurityPinEnableSection,
                  ),
                  const SizedBox(height: Spacing.level3),
                  FCard.raw(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.level5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FTextField(
                            control: FTextFieldControl.managed(
                              controller: enablePinController,
                            ),
                            label: Text(l10n.settingsSecurityPinEnterPin),
                            hint: l10n.settingsSecurityPinEnterPinHint,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 6,
                            obscureText: true,
                            error: enablePinError.value != null
                                ? Text(enablePinError.value!)
                                : null,
                          ),
                          const SizedBox(height: Spacing.level4),
                          FTextField(
                            control: FTextFieldControl.managed(
                              controller: enablePinConfirmController,
                            ),
                            label: Text(l10n.settingsSecurityPinConfirmPin),
                            hint: l10n.settingsSecurityPinConfirmPinHint,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 6,
                            obscureText: true,
                            error: enablePinConfirmError.value != null
                                ? Text(enablePinConfirmError.value!)
                                : null,
                          ),
                          const SizedBox(height: Spacing.level4),
                          SizedBox(
                            width: double.infinity,
                            child: FButton(
                              onPress: isSubmitting.value
                                  ? null
                                  : () => _enablePin(
                                      context,
                                      ref,
                                      l10n,
                                      enablePinController.text,
                                      enablePinConfirmController.text,
                                      isSubmitting,
                                      enablePinError,
                                      enablePinConfirmError,
                                    ),
                              child: isSubmitting.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: FCircularProgress(),
                                    )
                                  : Text(l10n.settingsSecurityPinEnableAction),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // -- Change PIN --
                  SettingsSectionLabel(
                    label: l10n.settingsSecurityPinChangeSection,
                  ),
                  const SizedBox(height: Spacing.level3),
                  FCard.raw(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.level5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FTextField(
                            control: FTextFieldControl.managed(
                              controller: oldPinController,
                            ),
                            label: Text(
                              l10n.settingsSecurityPinEnterCurrentPin,
                            ),
                            hint: l10n.settingsSecurityPinEnterPinHint,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 6,
                            obscureText: true,
                            error: oldPinError.value != null
                                ? Text(oldPinError.value!)
                                : null,
                          ),
                          const SizedBox(height: Spacing.level4),
                          FTextField(
                            control: FTextFieldControl.managed(
                              controller: newPinController,
                            ),
                            label: Text(l10n.settingsSecurityPinEnterNewPin),
                            hint: l10n.settingsSecurityPinEnterPinHint,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 6,
                            obscureText: true,
                            error: newPinError.value != null
                                ? Text(newPinError.value!)
                                : null,
                          ),
                          const SizedBox(height: Spacing.level4),
                          FTextField(
                            control: FTextFieldControl.managed(
                              controller: confirmPinController,
                            ),
                            label: Text(l10n.settingsSecurityPinConfirmNewPin),
                            hint: l10n.settingsSecurityPinConfirmPinHint,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 6,
                            obscureText: true,
                            error: confirmPinError.value != null
                                ? Text(confirmPinError.value!)
                                : null,
                          ),
                          const SizedBox(height: Spacing.level4),
                          SizedBox(
                            width: double.infinity,
                            child: FButton(
                              onPress: isSubmitting.value
                                  ? null
                                  : () => _changePin(
                                      context,
                                      ref,
                                      l10n,
                                      oldPinController.text,
                                      newPinController.text,
                                      confirmPinController.text,
                                      isSubmitting,
                                      oldPinError,
                                      newPinError,
                                      confirmPinError,
                                    ),
                              child: isSubmitting.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: FCircularProgress(),
                                    )
                                  : Text(l10n.settingsSecurityPinChangeAction),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.level5),

                  // -- Disable PIN --
                  SettingsSectionLabel(
                    label: l10n.settingsSecurityPinDisableSection,
                  ),
                  const SizedBox(height: Spacing.level3),
                  FCard.raw(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.level5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FTextField(
                            control: FTextFieldControl.managed(
                              controller: disablePinController,
                            ),
                            label: Text(
                              l10n.settingsSecurityPinEnterCurrentPin,
                            ),
                            hint: l10n.settingsSecurityPinEnterPinHint,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 6,
                            obscureText: true,
                            error: disablePinError.value != null
                                ? Text(disablePinError.value!)
                                : null,
                          ),
                          const SizedBox(height: Spacing.level4),
                          SizedBox(
                            width: double.infinity,
                            child: FButton(
                              variant: FButtonVariant.destructive,
                              onPress: isSubmitting.value
                                  ? null
                                  : () => _disablePin(
                                      context,
                                      ref,
                                      l10n,
                                      disablePinController.text,
                                      isSubmitting,
                                      disablePinError,
                                    ),
                              child: isSubmitting.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: FCircularProgress(),
                                    )
                                  : Text(l10n.settingsSecurityPinDisableAction),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _lastChangedLabel(
    AppLocalizations l10n,
    Locale locale,
    Object? lastChangedAt,
  ) {
    if (lastChangedAt == null) {
      return l10n.settingsSecurityPinNeverChanged;
    }
    final raw = lastChangedAt.toString();
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return l10n.settingsSecurityPinNeverChanged;
    final dateStr = formatDateTimeLabel(dt.toIso8601String(), locale);
    return l10n.settingsSecurityPinLastChangedAt(dateStr);
  }

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{6}$').hasMatch(pin);
  }

  Future<void> _enablePin(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String pin,
    String confirmPin,
    ValueNotifier<bool> isSubmitting,
    ValueNotifier<String?> pinError,
    ValueNotifier<String?> confirmError,
  ) async {
    if (!_isValidPin(pin)) {
      pinError.value = l10n.settingsSecurityPinInvalidPin;
      return;
    }
    if (pin != confirmPin) {
      confirmError.value = l10n.settingsSecurityPinPinMismatch;
      return;
    }
    isSubmitting.value = true;
    final result = await runGuarded(
      ref: ref,
      tag: 'SecurityPinSettings._enablePin',
      action: () => ref
          .read(userSettingsControllerProvider.notifier)
          .enableSecurityPin(pin),
    );
    if (!context.mounted) return;
    switch (result) {
      case Success():
        await AppToast.show(context, l10n.settingsSecurityPinEnableSuccess);
      case Failure(:final error):
        await AppToast.show(
          context,
          error.message.isNotEmpty ? error.message : l10n.settingsSyncFailed,
        );
    }
    isSubmitting.value = false;
  }

  Future<void> _changePin(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String oldPin,
    String newPin,
    String confirmPin,
    ValueNotifier<bool> isSubmitting,
    ValueNotifier<String?> oldPinError,
    ValueNotifier<String?> newPinError,
    ValueNotifier<String?> confirmPinError,
  ) async {
    if (!_isValidPin(oldPin)) {
      oldPinError.value = l10n.settingsSecurityPinInvalidPin;
      return;
    }
    if (!_isValidPin(newPin)) {
      newPinError.value = l10n.settingsSecurityPinInvalidPin;
      return;
    }
    if (newPin != confirmPin) {
      confirmPinError.value = l10n.settingsSecurityPinPinMismatch;
      return;
    }
    isSubmitting.value = true;
    final result = await runGuarded(
      ref: ref,
      tag: 'SecurityPinSettings._changePin',
      action: () => ref
          .read(userSettingsControllerProvider.notifier)
          .changeSecurityPin(oldPin, newPin),
    );
    if (!context.mounted) return;
    switch (result) {
      case Success():
        await AppToast.show(context, l10n.settingsSecurityPinChangeSuccess);
      case Failure(:final error):
        await AppToast.show(
          context,
          error.message.isNotEmpty ? error.message : l10n.settingsSyncFailed,
        );
    }
    isSubmitting.value = false;
  }

  Future<void> _disablePin(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String pin,
    ValueNotifier<bool> isSubmitting,
    ValueNotifier<String?> pinError,
  ) async {
    if (!_isValidPin(pin)) {
      pinError.value = l10n.settingsSecurityPinInvalidPin;
      return;
    }
    isSubmitting.value = true;
    final result = await runGuarded(
      ref: ref,
      tag: 'SecurityPinSettings._disablePin',
      action: () => ref
          .read(userSettingsControllerProvider.notifier)
          .disableSecurityPin(pin),
    );
    if (!context.mounted) return;
    switch (result) {
      case Success():
        await AppToast.show(context, l10n.settingsSecurityPinDisableSuccess);
      case Failure(:final error):
        await AppToast.show(
          context,
          error.message.isNotEmpty ? error.message : l10n.settingsSyncFailed,
        );
    }
    isSubmitting.value = false;
  }
}
