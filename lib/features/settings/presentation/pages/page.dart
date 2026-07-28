import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/i18n/locale_controller.dart';
import 'package:luminous/core/theme/preference.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/data_storage.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/settings/presentation/utils/page_padding.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/l10n/app_localizations.dart';

const _kGroupSpacing = 20.0;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final signedIn = session.canAccessProtectedData;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    final sections = <Widget>[
      _AccountHeader(
        session: session,
        signedIn: signedIn,
        onTap: () => pushAuthRequiredRoute(context, Routes.account),
      ),
      const SizedBox(height: _kGroupSpacing),

      // -- 账号与安全 --
      SettingsSectionLabel(label: l10n.settingsAccountSecuritySectionTitle),
      const SizedBox(height: Spacing.level3),
      FTileGroup(
        physics: const NeverScrollableScrollPhysics(),
        divider: FItemDivider.full,
        children: [
          _SettingsNavigationTile(
            tileKey: const Key('settings-row-account-security'),
            icon: SemanticIcons.safetySafe,
            title: l10n.mineSettingsAccountTitle,
            onTap: () => pushAuthRequiredRoute(context, Routes.account),
          ),
          _SettingsNavigationTile(
            tileKey: const Key('settings-row-security-pin'),
            icon: SemanticIcons.statusBlocked,
            title: l10n.settingsSecurityPinTitle,
            subtitle: l10n.settingsSecurityPinSubtitle,
            onTap: () {
              if (!signedIn) {
                pushAuthRequiredRoute(context, Routes.settings);
                return;
              }
              context.push(Routes.settingsSecurityPin);
            },
          ),
          _SettingsNavigationTile(
            tileKey: const Key('settings-row-health-profile'),
            icon: SemanticIcons.profileCondition,
            title: l10n.settingsHealthProfileTitle,
            subtitle: l10n.settingsHealthProfileSubtitle,
            onTap: () {
              if (!signedIn) {
                pushAuthRequiredRoute(context, Routes.settings);
                return;
              }
              context.go(Routes.mine);
            },
          ),
        ],
      ),
      const SizedBox(height: _kGroupSpacing),
      const _GeneralSection(),
      const SizedBox(height: _kGroupSpacing),
      const _QuickEntrySection(),
      const SizedBox(height: _kGroupSpacing),
      _PrivacySection(signedIn: signedIn),
      const SizedBox(height: _kGroupSpacing),
      _AboutSection(signedIn: signedIn),
      const SizedBox(height: _kGroupSpacing),
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
          context.go(Routes.login);
        },
      ),
    ];

    return PageScaffold(
      title: l10n.desktopSidebarSettings,
      child: isDesktop
          ? _SettingsMasterDetail(
              accountHeader: _AccountHeader(
                session: session,
                signedIn: signedIn,
                onTap: () => pushAuthRequiredRoute(context, Routes.account),
              ),
              signOutTile: _SignOutTile(
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
                  context.go(Routes.login);
                },
              ),
              groups: [
                _SettingsGroup(
                  label: l10n.settingsAccountSecuritySectionTitle,
                  icon: SemanticIcons.safetySafe,
                  body: FTileGroup(
                    physics: const NeverScrollableScrollPhysics(),
                    divider: FItemDivider.full,
                    children: [
                      _SettingsNavigationTile(
                        tileKey: const Key('settings-row-account-security'),
                        icon: SemanticIcons.safetySafe,
                        title: l10n.mineSettingsAccountTitle,
                        onTap: () =>
                            pushAuthRequiredRoute(context, Routes.account),
                      ),
                      _SettingsNavigationTile(
                        tileKey: const Key('settings-row-security-pin'),
                        icon: SemanticIcons.statusBlocked,
                        title: l10n.settingsSecurityPinTitle,
                        subtitle: l10n.settingsSecurityPinSubtitle,
                        onTap: () {
                          if (!signedIn) {
                            pushAuthRequiredRoute(context, Routes.settings);
                            return;
                          }
                          context.push(Routes.settingsSecurityPin);
                        },
                      ),
                      _SettingsNavigationTile(
                        tileKey: const Key('settings-row-health-profile'),
                        icon: SemanticIcons.profileCondition,
                        title: l10n.settingsHealthProfileTitle,
                        subtitle: l10n.settingsHealthProfileSubtitle,
                        onTap: () {
                          if (!signedIn) {
                            pushAuthRequiredRoute(context, Routes.settings);
                            return;
                          }
                          context.go(Routes.mine);
                        },
                      ),
                    ],
                  ),
                ),
                _SettingsGroup(
                  label: l10n.settingsGeneralSectionTitle,
                  icon: SemanticIcons.actionSettings,
                  body: const _GeneralSection(),
                ),
                _SettingsGroup(
                  label: l10n.settingsQuickEntrySection,
                  icon: SemanticIcons.safetyAllergy,
                  body: const _QuickEntrySection(),
                ),
                _SettingsGroup(
                  label: l10n.settingsPrivacySectionTitle,
                  icon: SemanticIcons.statusBlocked,
                  body: _PrivacySection(signedIn: signedIn),
                ),
                _SettingsGroup(
                  label: l10n.settingsAboutSectionTitle,
                  icon: SemanticIcons.statusInfo,
                  body: _AboutSection(signedIn: signedIn),
                ),
              ],
            )
          : SingleChildScrollView(
              child: ResponsiveContentFrame(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: settingsPageVerticalPadding(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections,
                  ),
                ),
              ),
            ),
    );
  }
}

/// Data model for a settings group in the master-detail layout.
class _SettingsGroup {
  const _SettingsGroup({
    required this.label,
    required this.icon,
    required this.body,
  });

  final String label;
  final IconData icon;
  final Widget body;
}

/// Desktop master-detail layout for the settings page.
///
/// Left column (~280px): section navigation with icons + labels, highlighting
/// the currently selected group.
/// Right column (flex): the selected group's settings content.
/// Account header is always shown above the master-detail area.
/// Sign-out tile is always shown below.
class _SettingsMasterDetail extends StatefulWidget {
  const _SettingsMasterDetail({
    required this.accountHeader,
    required this.signOutTile,
    required this.groups,
  });

  final Widget accountHeader;
  final Widget signOutTile;
  final List<_SettingsGroup> groups;

  @override
  State<_SettingsMasterDetail> createState() => _SettingsMasterDetailState();
}

class _SettingsMasterDetailState extends State<_SettingsMasterDetail> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: settingsPageVerticalPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.accountHeader,
            const SizedBox(height: _kGroupSpacing),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left navigation column.
                  SizedBox(
                    width: 260,
                    child: FCard(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.level2),
                        child: Column(
                          children: [
                            for (var i = 0; i < widget.groups.length; i++) ...[
                              _MasterNavItem(
                                icon: widget.groups[i].icon,
                                label: widget.groups[i].label,
                                selected: i == _selectedIndex,
                                onTap: () => setState(() => _selectedIndex = i),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.level6),
                  // Right content column.
                  Expanded(
                    child: SingleChildScrollView(
                      child: widget.groups[_selectedIndex].body,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _kGroupSpacing),
            widget.signOutTile,
          ],
        ),
      ),
    );
  }
}

/// A single navigation item in the settings master column.
class _MasterNavItem extends StatelessWidget {
  const _MasterNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;

    return FTappable(
      onPress: onTap,
      child: AnimatedContainer(
        duration: DurationTokens.widgetQuick,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level3,
        ),
        decoration: BoxDecoration(
          color: selected
              ? SemanticColor.primary.muted(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(RadiusTokens.level3),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? colors.primary : colors.mutedForeground,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                label,
                style: TypographyToken.level4
                    .body(context)
                    .copyWith(
                      color: selected
                          ? colors.foreground
                          : colors.mutedForeground,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
              ),
            ),
            if (selected)
              Icon(
                SemanticIcons.actionNext,
                size: IconSizeTokens.level2,
                color: colors.primary,
              ),
          ],
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

    return FCard(
      child: FTile(
        title: Text(displayName),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        prefix: FAvatar.raw(
          size: 64,
          child: const Icon(
            SemanticIcons.profileUser,
            size: IconSizeTokens.level5,
          ),
        ),
        suffix: const Icon(SemanticIcons.actionNext),
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
              icon: SemanticIcons.aiEntry,
              title: l10n.settingsAiTitle,
              subtitle: l10n.settingsAiSubtitle,
              onTap: () {
                if (!signedIn) {
                  pushAuthRequiredRoute(context, Routes.settings);
                  return;
                }
                context.push(Routes.settingsAi);
              },
            ),
            FTile(
              key: const Key('settings-row-privacy-report'),
              title: Text(l10n.minePrivacyReportTitle),
              subtitle: Text(l10n.minePrivacyReportSubtitle),
              prefix: const Icon(
                SemanticIcons.actionShare,
                size: IconSizeTokens.level3,
              ),
              suffix: FSwitch(
                value: settings?.dataSharingConsent ?? false,
                onChange: (value) async {
                  if (!signedIn) {
                    unawaited(pushAuthRequiredRoute(context, Routes.settings));
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
                  unawaited(pushAuthRequiredRoute(context, Routes.settings));
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
              icon: SemanticIcons.actionExport,
              title: l10n.mineSettingExportTitle,
              onTap: () {
                if (!signedIn) {
                  pushAuthRequiredRoute(context, Routes.settings);
                  return;
                }
                context.push(Routes.settingsExport);
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
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.settingsDataSharingConfirmDescription,
                style: TypographyToken.level4.body(context),
              ),
              const SizedBox(height: Spacing.level5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    variant: FButtonVariant.ghost,
                    onPress: () => Navigator.of(context).pop(false),
                    child: Text(l10n.settingsDataSharingCancelAction),
                  ),
                  const SizedBox(width: Spacing.level2),
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
        ref.watch(themeControllerProvider).value ?? const ThemePreference();
    final currentTheme = themePref.mode;
    final currentFamily = themePref.family;
    final currentLocale =
        ref.watch(localeControllerProvider).asData?.value ?? AppLocale.system;
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
              icon: SemanticIcons.actionSettings,
              title: l10n.mineSettingsThemeTitle,
              value: _themeSummaryLabel(l10n, currentTheme, currentFamily),
              onTap: () => context.push(Routes.settingsTheme),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-language'),
              icon: SemanticIcons.actionExternalLink,
              title: l10n.mineSettingsLanguageTitle,
              value: _languageLabel(l10n, currentLocale),
              onTap: () => context.push(Routes.settingsLanguage),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-data-storage'),
              icon: SemanticIcons.actionSettings,
              title: l10n.settingsDataStorageTitle,
              subtitle: l10n.settingsDataStorageSubtitle,
              value: _retentionLabel(l10n, dataStorage.retentionPeriod),
              onTap: () => context.push(Routes.settingsDataStorage),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-advanced'),
              icon: SemanticIcons.actionSettings,
              title: l10n.mineSettingsAdvancedTitle,
              onTap: () => context.push(Routes.settingsMore),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-accessibility'),
              icon: SemanticIcons.actionSettings,
              title: l10n.settingsAccessibilityTitle,
              subtitle: l10n.settingsAccessibilitySubtitle,
              onTap: () => context.push(Routes.settingsAccessibility),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-notifications'),
              icon: SemanticIcons.notificationBell,
              title: l10n.mineSettingsNotificationsTitle,
              value: _notificationSummary(l10n, ref),
              onTap: () => context.push(Routes.settingsNotifications),
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
// Quick entry section
// ---------------------------------------------------------------------------

class _QuickEntrySection extends StatelessWidget {
  const _QuickEntrySection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsQuickEntrySection),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          physics: const NeverScrollableScrollPhysics(),
          divider: FItemDivider.full,
          children: [
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-quick-entry'),
              icon: SemanticIcons.tabRecord,
              title: l10n.settingsQuickEntrySection,
              subtitle: l10n.settingsQuickEntrySubtitle,
              onTap: () => context.push(Routes.recordQuickEntrySettings),
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
              icon: SemanticIcons.actionHelp,
              title: l10n.mineSettingHelpTitle,
              onTap: () => context.push(Routes.settingsHelp),
            ),
            _SettingsNavigationTile(
              tileKey: const Key('settings-row-about'),
              icon: SemanticIcons.statusInfo,
              title: l10n.mineSettingAboutTitle,
              onTap: () => context.push(Routes.settingsAbout),
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
      prefix: icon != null ? Icon(icon, size: IconSizeTokens.level3) : null,
      details: () {
        final v = value;
        return v == null || v.isEmpty ? null : Text(v);
      }(),
      suffix: const Icon(SemanticIcons.actionNext),
      onPress: onTap,
    );
  }
}
