import 'package:flutter/material.dart';
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
    final oldPinController = useTextEditingController();
    final newPinController = useTextEditingController();
    final confirmPinController = useTextEditingController();
    final disablePinController = useTextEditingController();
    final isSubmitting = useState(false);

    final width = MediaQuery.sizeOf(context).width;

    return PageScaffold(
      title: l10n.settingsSecurityPinTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: width < Breakpoints.mobile
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
                                _lastChangedLabel(l10n, lastChangedAt),
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
                            hint: l10n.settingsSecurityPinInvalidPin,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            obscureText: true,
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
                                      isSubmitting,
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
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            obscureText: true,
                          ),
                          const SizedBox(height: Spacing.level4),
                          FTextField(
                            control: FTextFieldControl.managed(
                              controller: newPinController,
                            ),
                            label: Text(l10n.settingsSecurityPinEnterNewPin),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            obscureText: true,
                          ),
                          const SizedBox(height: Spacing.level4),
                          FTextField(
                            control: FTextFieldControl.managed(
                              controller: confirmPinController,
                            ),
                            label: Text(l10n.settingsSecurityPinConfirmNewPin),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            obscureText: true,
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
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            obscureText: true,
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

  String _lastChangedLabel(AppLocalizations l10n, Object? lastChangedAt) {
    if (lastChangedAt == null) {
      return l10n.settingsSecurityPinNeverChanged;
    }
    final raw = lastChangedAt.toString();
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return l10n.settingsSecurityPinNeverChanged;
    final dateStr =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
    ValueNotifier<bool> isSubmitting,
  ) async {
    if (!_isValidPin(pin)) {
      await AppToast.show(context, l10n.settingsSecurityPinInvalidPin);
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
  ) async {
    if (!_isValidPin(oldPin) || !_isValidPin(newPin)) {
      await AppToast.show(context, l10n.settingsSecurityPinInvalidPin);
      return;
    }
    if (newPin != confirmPin) {
      await AppToast.show(context, l10n.settingsSecurityPinPinMismatch);
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
  ) async {
    if (!_isValidPin(pin)) {
      await AppToast.show(context, l10n.settingsSecurityPinInvalidPin);
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
