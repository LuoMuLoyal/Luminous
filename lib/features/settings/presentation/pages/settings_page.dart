import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_section_surface.dart';
import 'package:luminous/core/widgets/settings/app_settings_navigation_row.dart';
import 'package:luminous/core/widgets/settings/app_settings_section.dart';
import 'package:luminous/core/widgets/settings/app_settings_switch_row.dart';
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
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
        const SizedBox(height: AppSpacingTokens.lg),
        AppSettingsSection(label: l10n.settingsAccountSecuritySectionTitle),
        AppSectionSurface(
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingsNavigationRow(
                key: const Key('settings-row-account-security'),
                title: l10n.mineSettingsAccountTitle,
                onTap: () => pushAuthRequiredRoute(context, '/account'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        AppSettingsSection(label: l10n.settingsNotificationsSectionTitle),
        AppSectionSurface(
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingsNavigationRow(
                key: const Key('settings-row-notifications'),
                title: l10n.mineSettingsNotificationsTitle,
                value: _notificationSummary(l10n, ref),
                onTap: () => context.push('/settings/notifications'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        AppSettingsSection(label: l10n.settingsPrivacySectionTitle),
        _PrivacySection(surface: surface, signedIn: signedIn),
        const SizedBox(height: AppSpacingTokens.lg),
        AppSettingsSection(label: l10n.settingsGeneralSectionTitle),
        _GeneralSection(surface: surface),
        const SizedBox(height: AppSpacingTokens.lg),
        AppSettingsSection(label: l10n.settingsAboutSectionTitle),
        _AboutSection(surface: surface, signedIn: signedIn),
        const SizedBox(height: AppSpacingTokens.xl),
        _FooterActionButton(
          key: const Key('settings-footer-action'),
          label: signedIn ? l10n.authSignOut : l10n.authGoLogin,
          destructive: signedIn,
          onTap: session.isLoading
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = _typography(context);

    final displayName =
        session.user?.nickname ??
        (signedIn ? l10n.mineAccountSignedIn : l10n.mineAccountSignedOut);
    final subtitle =
        session.user?.email ?? (signedIn ? '' : l10n.mineAccountSignedOutMeta);

    return Material(
      color: surface.canvas,
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: surface.canvasSoft2,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: surface.body,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: typography.bodyMdStrong),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        subtitle,
                        style: typography.bodySm.copyWith(color: surface.mute),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: surface.mute, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  AppTypographyScale _typography(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
  }
}

class _PrivacySection extends ConsumerWidget {
  const _PrivacySection({required this.surface, required this.signedIn});

  final AppThemeSurface surface;
  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = signedIn
        ? ref.watch(userSettingsControllerProvider)
        : null;
    final settings = settingsAsync?.asData?.value;

    return AppSectionSurface(
      surface: surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          AppSettingsSwitchRow(
            key: const Key('settings-row-privacy-report'),
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
            showDivider: true,
          ),
          AppSettingsNavigationRow(
            key: const Key('settings-row-ai'),
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
      ),
    );
  }

  Future<bool> _showDataSharingConfirmation(
    BuildContext context,
    bool value,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.settingsDataSharingConfirmTitle),
            content: Text(l10n.settingsDataSharingConfirmDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.settingsDataSharingCancelAction),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.settingsDataSharingConfirmAction),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _GeneralSection extends ConsumerWidget {
  const _GeneralSection({required this.surface});

  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme =
        ref.watch(appThemeControllerProvider).value ??
        AppThemeModePreference.system;
    final currentLocale =
        ref.watch(appLocaleControllerProvider).asData?.value ??
        AppLocale.system;

    return AppSectionSurface(
      surface: surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          AppSettingsNavigationRow(
            key: const Key('settings-row-theme'),
            title: l10n.mineSettingsThemeTitle,
            value: _themeModeLabel(l10n, currentTheme),
            onTap: () => context.push('/settings/theme'),
            showDivider: true,
          ),
          AppSettingsNavigationRow(
            key: const Key('settings-row-language'),
            title: l10n.mineSettingsLanguageTitle,
            value: _languageLabel(l10n, currentLocale),
            onTap: () => context.push('/settings/language'),
            showDivider: true,
          ),
          AppSettingsNavigationRow(
            key: const Key('settings-row-advanced'),
            title: l10n.mineSettingsAdvancedTitle,
            onTap: () => context.push('/settings/more'),
          ),
        ],
      ),
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
  const _AboutSection({required this.surface, required this.signedIn});

  final AppThemeSurface surface;
  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AppSectionSurface(
      surface: surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          AppSettingsNavigationRow(
            key: const Key('settings-row-help'),
            title: l10n.mineSettingHelpTitle,
            onTap: () => context.push('/settings/help'),
            showDivider: true,
          ),
          AppSettingsNavigationRow(
            key: const Key('settings-row-about'),
            title: l10n.mineSettingAboutTitle,
            onTap: () => context.push('/settings/about'),
            showDivider: true,
          ),
          AppSettingsNavigationRow(
            key: const Key('settings-row-export'),
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
      ),
    );
  }
}

class _FooterActionButton extends StatelessWidget {
  const _FooterActionButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.destructive,
  });

  final String label;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final foreground = onTap == null
        ? surface.body.withValues(alpha: 0.45)
        : destructive
        ? theme.colorScheme.error
        : surface.body;
    final typography = _typography(context);

    return Material(
      color: surface.canvas,
      borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.lg),
          child: Center(
            child: Text(
              label,
              style: typography.bodyMdStrong.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppTypographyScale _typography(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
  }
}
