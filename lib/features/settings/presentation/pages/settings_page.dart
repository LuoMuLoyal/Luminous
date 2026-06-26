import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/app_setting_row.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/support/data/providers/support_resources_providers.dart';
import 'package:luminous/features/settings/presentation/providers/data_export_controller.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final session = ref.watch(authSessionProvider);
    final currentTheme =
        ref.watch(appThemeControllerProvider).value ??
        AppThemeModePreference.system;
    final currentPalette =
        ref.watch(appThemePaletteControllerProvider).value ??
        AppThemePalettePreference.classic;
    final currentLocale =
        ref.watch(appLocaleControllerProvider).asData?.value ??
        AppLocale.system;
    final signedIn = session.canAccessProtectedData;

    return PageScaffoldShell(
      title: l10n.desktopSidebarSettings,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        AppSectionSurface(
          key: const Key('settings-group-account'),
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingRow(
                key: const Key('settings-row-account'),
                icon: Icons.verified_user_outlined,
                title: l10n.mineSettingsAccountTitle,
                value:
                    session.user?.email ??
                    session.user?.nickname ??
                    l10n.mineAccountSignedOut,
                onTap: () {
                  if (session.isLoading) {
                    return;
                  }
                  pushAuthRequiredRoute(context, '/account');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.md),
        AppSectionSurface(
          key: const Key('settings-group-preferences'),
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingRow(
                key: const Key('settings-row-theme'),
                icon: Icons.dark_mode_outlined,
                title: l10n.mineSettingsThemeTitle,
                value: _themeSettingsLabel(l10n, currentTheme, currentPalette),
                onTap: () => context.push('/settings/theme'),
                showDivider: true,
              ),
              AppSettingRow(
                key: const Key('settings-row-language'),
                icon: Icons.language_outlined,
                title: l10n.mineSettingsLanguageTitle,
                value: _languageLabel(l10n, currentLocale),
                onTap: () => context.push('/settings/language'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _PrivacySettingsSection(
          key: const Key('settings-group-privacy'),
          surface: surface,
          typography: typography,
          signedIn: signedIn,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _ReminderSettingsSection(
          key: const Key('settings-group-reminders'),
          surface: surface,
          typography: typography,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _AdvancedSettingsSection(
          key: const Key('settings-group-advanced'),
          surface: surface,
          typography: typography,
          signedIn: signedIn,
        ),
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

  String _themePaletteLabel(
    AppLocalizations l10n,
    AppThemePalettePreference preference,
  ) {
    return switch (preference) {
      AppThemePalettePreference.classic => l10n.settingsThemePaletteClassic,
      AppThemePalettePreference.bluePink => l10n.settingsThemePaletteBluePink,
      AppThemePalettePreference.yellowGreen =>
        l10n.settingsThemePaletteYellowGreen,
    };
  }

  String _themeSettingsLabel(
    AppLocalizations l10n,
    AppThemeModePreference mode,
    AppThemePalettePreference palette,
  ) {
    return '${_themeModeLabel(l10n, mode)} · ${_themePaletteLabel(l10n, palette)}';
  }
}

class _PrivacySettingsSection extends ConsumerWidget {
  const _PrivacySettingsSection({
    super.key,
    required this.surface,
    required this.typography,
    required this.signedIn,
  });

  final AppThemeSurface surface;
  final AppTypographyScale typography;
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
          AppSettingRow(
            key: const Key('settings-row-privacy-report'),
            icon: Icons.ios_share_outlined,
            title: l10n.minePrivacyReportTitle,
            subtitle: l10n.minePrivacyReportSubtitle,
            trailing: Text(
              (settings?.dataSharingConsent ?? false)
                  ? l10n.minePrivacyShareAfterGrant
                  : l10n.minePrivacyOnlyMe,
              style: typography.bodySm.copyWith(color: surface.body),
              textAlign: TextAlign.right,
            ),
            onTap: () {
              if (!signedIn) {
                pushAuthRequiredRoute(context, '/settings');
                return;
              }
              final value = !(settings?.dataSharingConsent ?? false);
              ref
                  .read(userSettingsControllerProvider.notifier)
                  .setDataSharingConsent(value);
            },
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('settings-row-privacy-ai'),
            icon: Icons.auto_awesome_outlined,
            title: l10n.minePrivacyAiTitle,
            subtitle: l10n.minePrivacyAiSubtitle,
            trailing: IgnorePointer(
              child: Switch(
                value: settings?.aiSummariesEnabled ?? false,
                onChanged: signedIn ? (_) {} : null,
              ),
            ),
            onTap: () {
              if (!signedIn) {
                pushAuthRequiredRoute(context, '/settings');
                return;
              }
              final value = !(settings?.aiSummariesEnabled ?? false);
              ref
                  .read(userSettingsControllerProvider.notifier)
                  .setAiSummariesEnabled(value);
            },
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('settings-row-privacy-ai-chat'),
            icon: Icons.chat_bubble_outline_rounded,
            title: l10n.assistantEntryTitle,
            subtitle: l10n.assistantEntrySubtitle,
            showChevron: true,
            onTap: () {
              if (!signedIn) {
                pushAuthRequiredRoute(context, '/assistant');
                return;
              }
              context.push('/assistant');
            },
          ),
        ],
      ),
    );
  }
}

class _ReminderSettingsSection extends ConsumerWidget {
  const _ReminderSettingsSection({
    super.key,
    required this.surface,
    required this.typography,
  });

  final AppThemeSurface surface;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(notificationSettingsControllerProvider);
    final settings =
        settingsAsync.asData?.value ?? const NotificationSettingsState();

    String statusLabel(bool enabled) =>
        enabled ? l10n.mineReminderEnabled : l10n.mineReminderDisabled;

    return AppSectionSurface(
      surface: surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          AppSettingRow(
            key: const Key('settings-row-notifications'),
            icon: Icons.notifications_none_rounded,
            title: l10n.mineSettingsNotificationsTitle,
            showChevron: true,
            onTap: () => context.push('/settings/notifications'),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('settings-row-reminder-medicine'),
            icon: Icons.medication_outlined,
            title: l10n.mineReminderMedicineTitle,
            trailing: Text(
              statusLabel(settings.medicationReminders),
              style: typography.bodySm.copyWith(color: surface.body),
            ),
            onTap: () => context.push('/settings/notifications'),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('settings-row-reminder-water'),
            icon: Icons.water_drop_outlined,
            title: l10n.mineReminderWaterTitle,
            trailing: Text(
              statusLabel(settings.waterReminders),
              style: typography.bodySm.copyWith(color: surface.body),
            ),
            onTap: () => context.push('/settings/notifications'),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('settings-row-reminder-sleep'),
            icon: Icons.nightlight_outlined,
            title: l10n.mineReminderSleepTitle,
            trailing: Text(
              _sleepReminderSummary(l10n, settings),
              style: typography.bodySm.copyWith(color: surface.body),
            ),
            onTap: () => context.push('/settings/notifications'),
          ),
        ],
      ),
    );
  }
}

class _AdvancedSettingsSection extends ConsumerWidget {
  const _AdvancedSettingsSection({
    super.key,
    required this.surface,
    required this.typography,
    required this.signedIn,
  });

  final AppThemeSurface surface;
  final AppTypographyScale typography;
  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final exportAsync = signedIn
        ? ref.watch(dataExportControllerProvider)
        : null;
    final exportRequestInFlight = ref.watch(dataExportRequestInFlightProvider);
    final export = exportAsync?.asData?.value;

    String exportValue() {
      return switch (dataExportUiStatusForRequest(export)) {
        DataExportUiStatus.idle => l10n.mineSettingExportValue,
        DataExportUiStatus.requested => l10n.mineExportStatusRequested,
        DataExportUiStatus.processing => l10n.mineExportStatusPending,
        DataExportUiStatus.completed => l10n.mineExportStatusCompleted,
        DataExportUiStatus.completedLinkMissing =>
          l10n.mineExportStatusLinkMissing,
        DataExportUiStatus.failed => l10n.mineExportStatusFailed,
        DataExportUiStatus.unavailable => l10n.mineExportStatusUnavailable,
      };
    }

    return AppSectionSurface(
      surface: surface,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          AppSettingRow(
            key: const Key('settings-row-export'),
            icon: Icons.download_outlined,
            title: l10n.mineSettingExportTitle,
            value: exportValue(),
            onTap: () async {
              if (!signedIn) {
                pushAuthRequiredRoute(context, '/settings');
                return;
              }
              if (exportRequestInFlight.inFlight) {
                return;
              }
              try {
                final request = await ref
                    .read(dataExportControllerProvider.notifier)
                    .requestExport();
                if (!context.mounted) {
                  return;
                }

                switch (dataExportUiStatusForRequest(request)) {
                  case DataExportUiStatus.completed:
                    await AppToast.show(
                      context,
                      l10n.mineExportStatusCompleted,
                    );
                    return;
                  case DataExportUiStatus.completedLinkMissing:
                    await AppToast.show(
                      context,
                      l10n.reportExportLinkMissingToast,
                    );
                    return;
                  case DataExportUiStatus.failed:
                  case DataExportUiStatus.unavailable:
                    await AppToast.show(
                      context,
                      request?.errorMessage?.isNotEmpty == true
                          ? request!.errorMessage!
                          : dataExportUiStatusForRequest(request) ==
                                DataExportUiStatus.unavailable
                          ? l10n.mineExportStatusUnavailable
                          : l10n.mineExportStatusFailed,
                    );
                    return;
                  case DataExportUiStatus.requested:
                    await AppToast.show(context, l10n.mineExportRequested);
                    return;
                  case DataExportUiStatus.processing:
                    await AppToast.show(context, l10n.mineExportStatusPending);
                    return;
                  case DataExportUiStatus.idle:
                    await AppToast.show(context, l10n.mineExportStatusFailed);
                    return;
                }
              } catch (error) {
                if (!context.mounted) {
                  return;
                }
                final message = LucentErrorMapper.fromObject(error).message;
                await AppToast.show(
                  context,
                  '${l10n.mineExportStatusFailed}: $message',
                );
              }
            },
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('settings-row-help'),
            icon: Icons.help_outline_rounded,
            title: l10n.mineSettingHelpTitle,
            value: l10n.mineSettingHelpValue,
            onTap: () => _showHelpDialog(context, ref),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('settings-row-about'),
            icon: Icons.info_outline_rounded,
            title: l10n.mineSettingAboutTitle,
            value: l10n.mineSettingAboutValue,
            onTap: () => _showAboutDialog(context, ref),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('settings-row-advanced'),
            icon: Icons.tune_rounded,
            title: l10n.mineSettingsAdvancedTitle,
            onTap: () => context.push('/settings/more'),
          ),
        ],
      ),
    );
  }

  Future<void> _showHelpDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final resources = await ref.read(supportResourcesProvider('help').future);
    if (!context.mounted) return;
    if (resources.isEmpty) {
      await AppToast.show(context, l10n.mineSettingHelpTitle);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.mineSettingHelpTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final r = resources[index];
                return ListTile(
                  title: Text(r.title),
                  subtitle: r.subtitle != null ? Text(r.subtitle!) : null,
                  enabled:
                      r.actionUrl != null &&
                      r.actionUrl!.isNotEmpty &&
                      r.actionType != null,
                  onTap:
                      r.actionUrl != null &&
                          r.actionUrl!.isNotEmpty &&
                          r.actionType != null
                      ? () async {
                          Navigator.pop(dialogContext);
                          if (r.actionType == SupportResourceActionType.url ||
                              r.actionType == SupportResourceActionType.phone) {
                            final uri = Uri.tryParse(r.actionUrl!);
                            if (uri != null) {
                              await const ExternalUrlLauncher().open(uri);
                            }
                          } else {
                            pushAuthRequiredRoute(context, r.actionUrl!);
                          }
                        }
                      : null,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAboutDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final info = await ref.read(appInfoProvider.future);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.mineSettingAboutTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info?.name ?? 'Luminous'),
              Text('${l10n.mineSettingAboutValue} ${info?.version ?? ''}'),
              if (info?.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacingTokens.sm),
                  child: Text(info!.description),
                ),
            ],
          ),
        );
      },
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
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
            border: Border.all(color: surface.hairline),
            boxShadow: AppShadowTokens.level1,
          ),
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
      ),
    );
  }
}

String _sleepReminderSummary(
  AppLocalizations l10n,
  NotificationSettingsState settings,
) {
  if (!settings.sleepReminderEnabled) return l10n.mineReminderSleepOff;
  final bedtime = _formatTimeOfDay(settings.sleepBedtime);
  final wakeTime = _formatTimeOfDay(settings.sleepWakeTime);
  return l10n.mineReminderSleepSummary(bedtime, wakeTime);
}

String _formatTimeOfDay(TimeOfDay? time) {
  if (time == null) return '--:--';
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
