import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/widgets/common/app_dialog.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final signedIn = session.canAccessProtectedData;

    return PageScaffoldShell(
      title: l10n.desktopSidebarSettings,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        _AccountHeader(
          session: session,
          signedIn: signedIn,
          onTap: () => pushAuthRequiredRoute(context, '/account'),
        ),
        const SizedBox(height: 24),
        _SettingsGroup(
          label: l10n.settingsAccountSecuritySectionTitle,
          children: [
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-account-security'),
              title: l10n.mineSettingsAccountTitle,
              onTap: () => pushAuthRequiredRoute(context, '/account'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SettingsGroup(
          label: l10n.settingsNotificationsSectionTitle,
          children: [
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-notifications'),
              title: l10n.mineSettingsNotificationsTitle,
              value: _notificationSummary(l10n, ref),
              onTap: () => context.push('/settings/notifications'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _PrivacySection(signedIn: signedIn),
        const SizedBox(height: 20),
        const _GeneralSection(),
        const SizedBox(height: 20),
        _AboutSection(signedIn: signedIn),
        const SizedBox(height: 28),
        _FooterAction(
          buttonKey: const Key('settings-footer-action'),
          label: signedIn ? l10n.authSignOut : l10n.authGoLogin,
          destructive: signedIn,
          onPress: session.isLoading
              ? null
              : () async {
                  if (!session.canAccessProtectedData) {
                    context.go(loginRouteForCurrentLocation(context));
                    return;
                  }
                  await ref.read(authSessionProvider.notifier).logout();
                  if (!context.mounted) {
                    return;
                  }
                  context.go('/login');
                },
        ),
      ],
    );
  }

  String _notificationSummary(AppLocalizations l10n, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings = settingsAsync.asData?.value;
    if (settings == null) return '';

    final enabledCount = [
      settings.medicationReminders,
      settings.waterReminders,
      settings.sleepReminders,
      settings.healthAlerts,
      settings.weeklySummary,
    ].where((v) => v).length;

    return l10n.settingsNotificationsSummary(enabledCount);
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.session,
    required this.signedIn,
    required this.onTap,
  });

  final AuthSessionState session;
  final bool signedIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final displayName =
        session.user?.nickname ??
        (signedIn ? l10n.mineAccountSignedIn : l10n.mineAccountSignedOut);
    final subtitle =
        session.user?.email ?? (signedIn ? '' : l10n.mineAccountSignedOutMeta);

    return FTile(
      title: Text(displayName),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      prefix: FAvatar.raw(size: 48, child: const Icon(FLucideIcons.userRound)),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: onTap,
    );
  }
}

class _PrivacySection extends ConsumerWidget {
  const _PrivacySection({required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = signedIn
        ? ref.watch(userSettingsControllerProvider)
        : null;
    final settings = settingsAsync?.asData?.value;

    return _SettingsGroup(
      label: l10n.settingsPrivacySectionTitle,
      children: [
        _SettingsSwitchTile(
          tileKey: const Key('settings-row-privacy-report'),
          title: l10n.minePrivacyReportTitle,
          subtitle: l10n.minePrivacyReportSubtitle,
          value: settings?.dataSharingConsent ?? false,
          onChanged: (value) async {
            if (!signedIn) {
              unawaited(pushAuthRequiredRoute(context, '/settings'));
              return;
            }
            final confirmed = await _showDataSharingConfirmation(
              context,
              value,
            );
            if (!context.mounted) {
              return;
            }
            if (confirmed) {
              unawaited(
                ref
                    .read(userSettingsControllerProvider.notifier)
                    .setDataSharingConsent(value),
              );
            }
          },
        ),
        _SettingsNavigationTile(
          tileKey: const Key('settings-row-ai'),
          title: l10n.settingsAiTitle,
          subtitle: l10n.settingsAiSubtitle,
          onTap: () {
            if (!signedIn) {
              pushAuthRequiredRoute(context, '/settings');
              return;
            }
            context.push('/settings/ai');
          },
        ),
      ],
    );
  }

  Future<bool> _showDataSharingConfirmation(
    BuildContext context,
    bool value,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AppDialog(
            maxWidth: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsDataSharingConfirmTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.settingsDataSharingConfirmDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      variant: FButtonVariant.ghost,
                      onPress: () => Navigator.of(context).pop(false),
                      child: Text(l10n.settingsDataSharingCancelAction),
                    ),
                    const SizedBox(width: 8),
                    FButton(
                      onPress: () => Navigator.of(context).pop(true),
                      child: Text(l10n.settingsDataSharingConfirmAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;
  }
}

class _GeneralSection extends ConsumerWidget {
  const _GeneralSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme =
        ref.watch(appThemeControllerProvider).value ??
        AppThemeModePreference.system;
    final currentLocale =
        ref.watch(appLocaleControllerProvider).asData?.value ??
        AppLocale.system;

    return _SettingsGroup(
      label: l10n.settingsGeneralSectionTitle,
      children: [
        _SettingsNavigationTile(
          tileKey: const Key('settings-row-theme'),
          title: l10n.mineSettingsThemeTitle,
          value: _themeModeLabel(l10n, currentTheme),
          onTap: () => context.push('/settings/theme'),
        ),
        _SettingsNavigationTile(
          tileKey: const Key('settings-row-language'),
          title: l10n.mineSettingsLanguageTitle,
          value: _languageLabel(l10n, currentLocale),
          onTap: () => context.push('/settings/language'),
        ),
        _SettingsNavigationTile(
          tileKey: const Key('settings-row-advanced'),
          title: l10n.mineSettingsAdvancedTitle,
          onTap: () => context.push('/settings/more'),
        ),
      ],
    );
  }

  String _themeModeLabel(
    AppLocalizations l10n,
    AppThemeModePreference preference,
  ) {
    return switch (preference) {
      AppThemeModePreference.system => l10n.mineThemeModeSystem,
      AppThemeModePreference.light => l10n.mineThemeModeLight,
      AppThemeModePreference.dark => l10n.mineThemeModeDark,
    };
  }

  String _languageLabel(AppLocalizations l10n, AppLocale locale) {
    return switch (locale) {
      AppLocale.system => l10n.settingsLanguageSystemLabel,
      AppLocale.en => l10n.settingsLanguageEnglishLabel,
      AppLocale.zhCn => l10n.settingsLanguageChineseLabel,
    };
  }
}

class _AboutSection extends ConsumerWidget {
  const _AboutSection({required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return _SettingsGroup(
      label: l10n.settingsAboutSectionTitle,
      children: [
        _SettingsNavigationTile(
          tileKey: const Key('settings-row-help'),
          title: l10n.mineSettingHelpTitle,
          onTap: () => context.push('/settings/help'),
        ),
        _SettingsNavigationTile(
          tileKey: const Key('settings-row-about'),
          title: l10n.mineSettingAboutTitle,
          onTap: () => context.push('/settings/about'),
        ),
        _SettingsNavigationTile(
          tileKey: const Key('settings-row-export'),
          title: l10n.mineSettingExportTitle,
          onTap: () {
            if (!signedIn) {
              pushAuthRequiredRoute(context, '/settings');
              return;
            }
            context.push('/settings/export');
          },
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FCard.raw(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < children.length; index += 1) ...[
                children[index],
                if (index < children.length - 1) const FDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsNavigationTile extends StatelessWidget {
  const _SettingsNavigationTile({
    required this.title,
    this.subtitle,
    this.value,
    this.tileKey,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final Key? tileKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTile(
      key: tileKey,
      title: Text(title),
      subtitle: subtitle == null || subtitle!.isEmpty ? null : Text(subtitle!),
      details: value == null || value!.isEmpty ? null : Text(value!),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.tileKey,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Key? tileKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FTile.raw(
      key: tileKey,
      onPress: () => onChanged(!value),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.foreground,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          IgnorePointer(child: FSwitch(value: value)),
        ],
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.label,
    required this.onPress,
    required this.destructive,
    this.buttonKey,
  });

  final String label;
  final VoidCallback? onPress;
  final bool destructive;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FButton(
        key: buttonKey,
        variant: destructive
            ? FButtonVariant.destructive
            : FButtonVariant.outline,
        onPress: onPress,
        child: Text(label),
      ),
    );
  }
}
