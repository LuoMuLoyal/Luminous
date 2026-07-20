import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/i18n/locale_controller.dart';
import 'package:luminous/core/theme/theme_controller.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/settings/presentation/providers/data_storage.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

const _kGroupSpacing = 20.0;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final signedIn = session.canAccessProtectedData;

    return PageScaffold(
      title: l10n.desktopSidebarSettings,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: settingsPageVerticalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AccountHeader(
                  session: session,
                  signedIn: signedIn,
                  onTap: () =>
                      pushAuthRequiredRoute(context, AppRoutes.account),
                ),
                const SizedBox(height: _kGroupSpacing),

                // -- 账号与安全 --
                SettingsSectionLabel(
                  label: l10n.settingsAccountSecuritySectionTitle,
                ),
                const SizedBox(height: Spacing.level3),
                FTileGroup(
                  physics: const NeverScrollableScrollPhysics(),
                  divider: FItemDivider.full,
                  children: [
                    _SettingsNavigationTile(
                      tileKey: const Key('settings-row-account-security'),
                      icon: FLucideIcons.shieldCheck,
                      title: l10n.mineSettingsAccountTitle,
                      onTap: () =>
                          pushAuthRequiredRoute(context, AppRoutes.account),
                    ),
                    _SettingsNavigationTile(
                      tileKey: const Key('settings-row-security-pin'),
                      icon: FLucideIcons.lockKeyhole,
                      title: l10n.settingsSecurityPinTitle,
                      subtitle: l10n.settingsSecurityPinSubtitle,
                      onTap: () {
                        if (!signedIn) {
                          pushAuthRequiredRoute(context, AppRoutes.settings);
                          return;
                        }
                        context.push(AppRoutes.settingsSecurityPin);
                      },
                    ),
                    _SettingsNavigationTile(
                      tileKey: const Key('settings-row-health-profile'),
                      icon: FLucideIcons.heartPulse,
                      title: l10n.settingsHealthProfileTitle,
                      subtitle: l10n.settingsHealthProfileSubtitle,
                      onTap: () {
                        if (!signedIn) {
                          pushAuthRequiredRoute(context, AppRoutes.settings);
                          return;
                        }
                        context.go(AppRoutes.mine);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: _kGroupSpacing),

                // -- 通用（含数据与存储）--
                const _GeneralSection(),
                const SizedBox(height: _kGroupSpacing),

                // -- 快速记录 --
                const _QuickEntrySection(),
                const SizedBox(height: _kGroupSpacing),

                // -- AI 与隐私 --
                _PrivacySection(signedIn: signedIn),
                const SizedBox(height: _kGroupSpacing),

                // -- 关于与帮助 --
                _AboutSection(signedIn: signedIn),
                const SizedBox(height: _kGroupSpacing),

                // -- 退出登录 --
                _SignOutTile(
                  signedIn: signedIn,
                  isLoading: session.isLoading,
                  onTap: () async {
                    if (!session.canAccessProtectedData) {
                      context.go(loginRouteForCurrentLocation(context));
                      return;
                    }
                    final confirmed = await showDangerConfirmationDialog(
                      context: context,
                      title: l10n.authSignOutConfirmTitle,
                      message: l10n.authSignOutConfirmMessage,
                      confirmLabel: l10n.authSignOutConfirmAction,
                    );
                    if (!confirmed || !context.mounted) return;
                    await ref.read(authSessionProvider.notifier).logout();
                    if (!context.mounted) return;
                    context.go(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account header
// ---------------------------------------------------------------------------

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

    return FCard.raw(
      child: FTile(
        title: Text(displayName),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        prefix: FAvatar.raw(
          size: 64,
          child: const Icon(FLucideIcons.userRound, size: 32),
        ),
        suffix: const Icon(FLucideIcons.chevronRight),
        onPress: onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Privacy section (AI + data sharing + data export)
// ---------------------------------------------------------------------------

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsPrivacySectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-ai'),
              icon: FLucideIcons.sparkles,
              title: l10n.settingsAiTitle,
              subtitle: l10n.settingsAiSubtitle,
              onTap: () {
                if (!signedIn) {
                  pushAuthRequiredRoute(context, AppRoutes.settings);
                  return;
                }
                context.push(AppRoutes.settingsAi);
              },
            ),
            FTile(
              key: const Key('settings-row-privacy-report'),
              title: Text(l10n.minePrivacyReportTitle),
              subtitle: Text(l10n.minePrivacyReportSubtitle),
              prefix: const Icon(FLucideIcons.share2, size: 20),
              suffix: FSwitch(
                value: settings?.dataSharingConsent ?? false,
                onChange: (value) async {
                  if (!signedIn) {
                    unawaited(
                      pushAuthRequiredRoute(context, AppRoutes.settings),
                    );
                    return;
                  }
                  final confirmed = await _showDataSharingConfirmation(
                    context,
                    value,
                  );
                  if (!context.mounted) return;
                  if (confirmed) {
                    unawaited(
                      ref
                          .read(userSettingsControllerProvider.notifier)
                          .setDataSharingConsent(value),
                    );
                  }
                },
              ),
              onPress: () async {
                final currentValue = settings?.dataSharingConsent ?? false;
                if (!signedIn) {
                  unawaited(pushAuthRequiredRoute(context, AppRoutes.settings));
                  return;
                }
                final confirmed = await _showDataSharingConfirmation(
                  context,
                  !currentValue,
                );
                if (!context.mounted) return;
                if (confirmed) {
                  unawaited(
                    ref
                        .read(userSettingsControllerProvider.notifier)
                        .setDataSharingConsent(!currentValue),
                  );
                }
              },
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-export'),
              icon: FLucideIcons.arrowDownToLine,
              title: l10n.mineSettingExportTitle,
              onTap: () {
                if (!signedIn) {
                  pushAuthRequiredRoute(context, AppRoutes.settings);
                  return;
                }
                context.push(AppRoutes.settingsExport);
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<bool> _showDataSharingConfirmation(
    BuildContext context,
    bool value,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return await showAppDialog<bool>(
          context: context,
          maxWidth: 440,
          scrollable: false,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsDataSharingConfirmTitle,
                style: TypographyToken.level6.body(context),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.settingsDataSharingConfirmDescription,
                style: TypographyToken.level4.body(context),
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
        ) ??
        false;
  }
}

// ---------------------------------------------------------------------------
// General section (theme + language + advanced)
// ---------------------------------------------------------------------------

class _GeneralSection extends ConsumerWidget {
  const _GeneralSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themePref =
        ref.watch(appThemeControllerProvider).value ??
        const AppThemePreference();
    final currentTheme = themePref.mode;
    final currentFamily = themePref.family;
    final currentLocale =
        ref.watch(appLocaleControllerProvider).asData?.value ??
        AppLocale.system;
    final dataStorageAsync = ref.watch(dataStorageSettingsControllerProvider);
    final dataStorage =
        dataStorageAsync.asData?.value ?? const DataStorageSettingsState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsGeneralSectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-theme'),
              icon: FLucideIcons.palette,
              title: l10n.mineSettingsThemeTitle,
              value: _themeSummaryLabel(l10n, currentTheme, currentFamily),
              onTap: () => context.push(AppRoutes.settingsTheme),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-language'),
              icon: FLucideIcons.globe,
              title: l10n.mineSettingsLanguageTitle,
              value: _languageLabel(l10n, currentLocale),
              onTap: () => context.push(AppRoutes.settingsLanguage),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-data-storage'),
              icon: FLucideIcons.database,
              title: l10n.settingsDataStorageTitle,
              subtitle: l10n.settingsDataStorageSubtitle,
              value: _retentionLabel(l10n, dataStorage.retentionPeriod),
              onTap: () => context.push(AppRoutes.settingsDataStorage),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-advanced'),
              icon: FLucideIcons.slidersHorizontal,
              title: l10n.mineSettingsAdvancedTitle,
              onTap: () => context.push(AppRoutes.settingsMore),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-accessibility'),
              icon: FLucideIcons.accessibility,
              title: l10n.settingsAccessibilityTitle,
              subtitle: l10n.settingsAccessibilitySubtitle,
              onTap: () => context.push(AppRoutes.settingsAccessibility),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-notifications'),
              icon: FLucideIcons.bell,
              title: l10n.mineSettingsNotificationsTitle,
              value: _notificationSummary(l10n, ref),
              onTap: () =>
                  context.push(AppRoutes.settingsNotifications),
            ),
          ],
        ),
      ],
    );
  }

  String _notificationSummary(AppLocalizations l10n, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings = settingsAsync.asData?.value;
    if (settings == null) return '—';

    final enabledCount = [
      settings.medicationReminders,
      settings.waterReminders,
      settings.sleepReminders,
      settings.healthAlerts,
      settings.weeklySummary,
    ].where((v) => v).length;

    return l10n.settingsNotificationsSummary(enabledCount);
  }

  String _retentionLabel(AppLocalizations l10n, DataRetentionPeriod period) {
    return switch (period) {
      DataRetentionPeriod.thirtyDays => l10n.settingsDataStorageRetention30Days,
      DataRetentionPeriod.ninetyDays => l10n.settingsDataStorageRetention90Days,
      DataRetentionPeriod.forever => l10n.settingsDataStorageRetentionForever,
    };
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

  String _themeFamilyLabel(AppLocalizations l10n, AppThemeFamily family) {
    return switch (family) {
      AppThemeFamily.blue => l10n.settingsThemeFamilyBlue,
      AppThemeFamily.green => l10n.settingsThemeFamilyGreen,
      AppThemeFamily.neutral => l10n.settingsThemeFamilyNeutral,
      AppThemeFamily.orange => l10n.settingsThemeFamilyOrange,
      AppThemeFamily.red => l10n.settingsThemeFamilyRed,
      AppThemeFamily.rose => l10n.settingsThemeFamilyRose,
      AppThemeFamily.slate => l10n.settingsThemeFamilySlate,
      AppThemeFamily.violet => l10n.settingsThemeFamilyViolet,
      AppThemeFamily.yellow => l10n.settingsThemeFamilyYellow,
      AppThemeFamily.zinc => l10n.settingsThemeFamilyZinc,
    };
  }

  String _themeSummaryLabel(
    AppLocalizations l10n,
    AppThemeModePreference mode,
    AppThemeFamily family,
  ) {
    return '${_themeModeLabel(l10n, mode)} · ${_themeFamilyLabel(l10n, family)}';
  }

  String _languageLabel(AppLocalizations l10n, AppLocale locale) {
    return switch (locale) {
      AppLocale.system => l10n.settingsLanguageSystemLabel,
      AppLocale.en => l10n.settingsLanguageEnglishLabel,
      AppLocale.zhCn => l10n.settingsLanguageChineseLabel,
    };
  }
}

// ---------------------------------------------------------------------------
// Quick entry section (dynamic sort + collapse)
// ---------------------------------------------------------------------------

class _QuickEntrySection extends ConsumerWidget {
  const _QuickEntrySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final controller = ref.read(quickEntryPreferencesProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsQuickEntrySection),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            FTile(
              key: const Key('settings-row-quick-entry-dynamic-sort'),
              title: Text(l10n.settingsQuickEntryDynamicSortTitle),
              subtitle: Text(l10n.settingsQuickEntryDynamicSortSubtitle),
              suffix: FSwitch(
                value: prefs.dynamicSortEnabled,
                onChange: (value) => controller.setDynamicSortEnabled(value),
              ),
              onPress: () =>
                  controller.setDynamicSortEnabled(!prefs.dynamicSortEnabled),
            ),
            FTile(
              key: const Key('settings-row-quick-entry-collapse'),
              title: Text(l10n.settingsQuickEntryCollapseTitle),
              subtitle: Text(l10n.settingsQuickEntryCollapseSubtitle),
              suffix: FSwitch(
                value: prefs.collapsed,
                onChange: (value) => controller.setCollapsed(value),
              ),
              onPress: () => controller.setCollapsed(!prefs.collapsed),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// About section (help + about)
// ---------------------------------------------------------------------------

class _AboutSection extends ConsumerWidget {
  const _AboutSection({required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsAboutSectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-help'),
              icon: FLucideIcons.circleHelp,
              title: l10n.mineSettingHelpTitle,
              onTap: () => context.push(AppRoutes.settingsHelp),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-about'),
              icon: FLucideIcons.info,
              title: l10n.mineSettingAboutTitle,
              onTap: () => context.push(AppRoutes.settingsAbout),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sign-out tile
// ---------------------------------------------------------------------------

class _SignOutTile extends StatelessWidget {
  const _SignOutTile({
    required this.signedIn,
    required this.isLoading,
    required this.onTap,
  });

  final bool signedIn;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FTileGroup(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FTile(
          key: const Key('settings-footer-action'),
          title: Center(
            child: Text(
              signedIn ? l10n.authSignOut : l10n.authGoLogin,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(
                    color: signedIn
                        ? colors.error
                        : context.theme.colors.primary,
                  ),
            ),
          ),
          enabled: !isLoading,
          onPress: isLoading ? null : onTap,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared tile widgets
// ---------------------------------------------------------------------------

class _SettingsNavigationTile extends StatelessWidget with FTileMixin {
  const _SettingsNavigationTile({
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.tileKey,
    required this.onTap,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final String? value;
  final Key? tileKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTile(
      key: tileKey,
      title: Text(title),
      subtitle: () {
        final s = subtitle;
        return s == null || s.isEmpty ? null : Text(s);
      }(),
      prefix: icon != null ? Icon(icon, size: 20) : null,
      details: () {
        final v = value;
        return v == null || v.isEmpty ? null : Text(v);
      }(),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: onTap,
    );
  }
}
