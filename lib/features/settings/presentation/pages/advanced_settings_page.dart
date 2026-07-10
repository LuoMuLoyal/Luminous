import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/accessibility/settings_controller.dart';
import 'package:luminous/core/config/developer_settings_controller.dart';
import 'package:luminous/core/config/feature_flags_controller.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/logger/app_logger.dart';
import 'package:luminous/core/theme/app_theme_controller.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/settings/presentation/providers/data_storage_settings_controller.dart';
import 'package:luminous/features/settings/presentation/providers/notification_settings_controller.dart';
import 'package:luminous/features/settings/presentation/providers/profile_sync_provider.dart';
import 'package:luminous/features/settings/presentation/routes.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/core/design/design.dart';

class AdvancedSettingsPage extends ConsumerWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final width = MediaQuery.sizeOf(context).width;

    return PageScaffold(
      title: l10n.mineSettingsAdvancedTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: width < Breakpoints.mobile ? 24 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      key: const Key('advanced-settings-row-clear-cache'),
                      title: Text(l10n.settingsAdvancedClearImageCache),
                      onPress: () async {
                        imageCache.clear();
                        imageCache.clearLiveImages();
                        await AppToast.show(
                          context,
                          l10n.settingsAdvancedCacheCleared,
                        );
                      },
                    ),
                    FTile(
                      key: const Key('advanced-settings-row-reset-defaults'),
                      title: Text(l10n.settingsAdvancedResetDefaults),
                      onPress: () async {
                        await ref
                            .read(appThemeControllerProvider.notifier)
                            .setMode(AppThemeModePreference.system);
                        await ref
                            .read(appThemeControllerProvider.notifier)
                            .setFamily(appDefaultThemeFamily);
                        try {
                          await ref
                              .read(settingsProfileSyncProvider.notifier)
                              .resetProfilePreferences();
                        } catch (e) {
                          ref
                              .read(talkerProvider)
                              .error(
                                'AdvancedSettingsPage: resetProfilePreferences failed: $e',
                              );
                          await ref
                              .read(appLocaleControllerProvider.notifier)
                              .setLocale(AppLocale.system);
                        }
                        await ref
                            .read(
                              notificationSettingsControllerProvider.notifier,
                            )
                            .reset();
                        await ref
                            .read(
                              accessibilitySettingsControllerProvider.notifier,
                            )
                            .reset();
                        await ref
                            .read(
                              dataStorageSettingsControllerProvider.notifier,
                            )
                            .reset();
                        if (kDebugMode) {
                          await ref
                              .read(
                                developerSettingsControllerProvider.notifier,
                              )
                              .reset();
                          await ref
                              .read(featureFlagsControllerProvider.notifier)
                              .reset();
                        }
                        if (!context.mounted) {
                          return;
                        }
                        await AppToast.show(
                          context,
                          l10n.settingsAdvancedDefaultsReset,
                        );
                      },
                    ),
                    FTile(
                      key: const Key('advanced-settings-row-licenses'),
                      title: Text(l10n.settingsAdvancedOpenSourceLicenses),
                      suffix: const Icon(FLucideIcons.chevronRight),
                      onPress: () => showLicensePage(
                        context: context,
                        applicationName: 'Luminous',
                      ),
                    ),
                  ],
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: Spacing.level5),
                  SettingsSectionLabel(
                    label: l10n.settingsDeveloperSectionTitle,
                  ),
                  const SizedBox(height: Spacing.level3),
                  _DeveloperOptionsGroup(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeveloperOptionsGroup extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final devAsync = ref.watch(developerSettingsControllerProvider);
    final dev = devAsync.asData?.value ?? const DeveloperSettingsState();
    final flagsAsync = ref.watch(featureFlagsControllerProvider);
    final flags = flagsAsync.asData?.value ?? const FeatureFlagsState();

    return FTileGroup(
      style: settingsSubpageTileGroupStyle(context.theme),
      children: [
        FTile(
          key: const Key('dev-settings-row-api-endpoint'),
          title: Text(l10n.settingsDevApiEndpoint),
          subtitle: Text(dev.resolvedBaseUrl),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => _showEndpointSheet(context, ref, dev),
        ),
        FTile(
          key: const Key('dev-settings-row-log-level'),
          title: Text(l10n.settingsDevLogLevel),
          subtitle: Text(_logLevelLabel(l10n, dev.logLevel)),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => _showLogLevelSheet(context, ref, dev.logLevel),
        ),
        FTile(
          key: const Key('dev-settings-row-feature-flags'),
          title: Text(l10n.settingsFeatureFlagsTitle),
          subtitle: Text(l10n.settingsFeatureFlagsSummary(flags.enabledCount)),
          suffix: const Icon(FLucideIcons.chevronRight),
          onPress: () => const SettingsFeatureFlagsRoute().push(context),
        ),
      ],
    );
  }

  String _logLevelLabel(AppLocalizations l10n, LogLevel level) {
    return switch (level) {
      LogLevel.verbose => l10n.settingsDevLogLevelVerbose,
      LogLevel.info => l10n.settingsDevLogLevelInfo,
      LogLevel.warning => l10n.settingsDevLogLevelWarning,
      LogLevel.error => l10n.settingsDevLogLevelError,
      LogLevel.none => l10n.settingsDevLogLevelNone,
    };
  }

  void _showEndpointSheet(
    BuildContext context,
    WidgetRef ref,
    DeveloperSettingsState dev,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showFSheet(
      context: context,
      side: FLayout.btt,
      builder: (context) => _EndpointSheet(
        current: dev.apiEndpoint,
        customUrl: dev.customApiUrl,
        l10n: l10n,
        onSelect: (endpoint) async {
          await ref
              .read(developerSettingsControllerProvider.notifier)
              .setApiEndpoint(endpoint);
          if (context.mounted) Navigator.of(context).pop();
          // Log out to clear stale session for the previous endpoint.
          await ref.read(authSessionProvider.notifier).logout();
          if (context.mounted) {
            await AppToast.show(context, l10n.settingsDevApiEndpointSwitched);
          }
        },
        onCustomUrlChanged: (url) {
          ref
              .read(developerSettingsControllerProvider.notifier)
              .setCustomApiUrl(url);
        },
      ),
    );
  }

  void _showLogLevelSheet(
    BuildContext context,
    WidgetRef ref,
    LogLevel current,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showFSheet(
      context: context,
      side: FLayout.btt,
      builder: (context) => _LogLevelSheet(
        current: current,
        l10n: l10n,
        onSelect: (level) async {
          await ref
              .read(developerSettingsControllerProvider.notifier)
              .setLogLevel(level);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet: API endpoint selection
// ---------------------------------------------------------------------------

class _EndpointSheet extends StatefulWidget {
  const _EndpointSheet({
    required this.current,
    required this.customUrl,
    required this.l10n,
    required this.onSelect,
    required this.onCustomUrlChanged,
  });

  final ApiEndpoint current;
  final String customUrl;
  final AppLocalizations l10n;
  final Future<void> Function(ApiEndpoint) onSelect;
  final void Function(String) onCustomUrlChanged;

  @override
  State<_EndpointSheet> createState() => _EndpointSheetState();
}

class _EndpointSheetState extends State<_EndpointSheet> {
  late ApiEndpoint _selected;
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
    _customController = TextEditingController(text: widget.customUrl);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.level3),
              child: Text(
                widget.l10n.settingsDevApiEndpoint,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                for (final endpoint in ApiEndpoint.values)
                  FTile(
                    title: Text(_endpointLabel(widget.l10n, endpoint)),
                    subtitle: Text(
                      endpoint == ApiEndpoint.custom
                          ? widget.l10n.settingsDevApiEndpointCustomHint
                          : endpoint.defaultUrl,
                    ),
                    suffix: endpoint == _selected
                        ? Icon(
                            FLucideIcons.check,
                            size: 18,
                            color: context.theme.colors.primary,
                          )
                        : null,
                    onPress: () {
                      setState(() => _selected = endpoint);
                      if (endpoint == ApiEndpoint.custom) {
                        widget.onCustomUrlChanged(_customController.text);
                      }
                    },
                  ),
              ],
            ),
            if (_selected == ApiEndpoint.custom) ...[
              const SizedBox(height: Spacing.level4),
              FTextField(
                control: FTextFieldControl.managed(
                  controller: _customController,
                ),
                label: Text(widget.l10n.settingsDevApiEndpointCustomUrl),
                hint: 'https://...',
              ),
            ],
            const SizedBox(height: Spacing.level4),
            SizedBox(
              width: double.infinity,
              child: FButton(
                onPress: () => widget.onSelect(_selected),
                child: Text(widget.l10n.settingsDevApiEndpointConfirm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _endpointLabel(AppLocalizations l10n, ApiEndpoint endpoint) {
    return switch (endpoint) {
      ApiEndpoint.local => l10n.settingsDevApiEndpointLocal,
      ApiEndpoint.staging => l10n.settingsDevApiEndpointStaging,
      ApiEndpoint.production => l10n.settingsDevApiEndpointProduction,
      ApiEndpoint.custom => l10n.settingsDevApiEndpointCustom,
    };
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet: Log level selection
// ---------------------------------------------------------------------------

class _LogLevelSheet extends StatelessWidget {
  const _LogLevelSheet({
    required this.current,
    required this.l10n,
    required this.onSelect,
  });

  final LogLevel current;
  final AppLocalizations l10n;
  final Future<void> Function(LogLevel) onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.level3),
              child: Text(
                l10n.settingsDevLogLevel,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                for (final level in LogLevel.values)
                  FTile(
                    title: Text(_levelLabel(l10n, level)),
                    suffix: level == current
                        ? Icon(
                            FLucideIcons.check,
                            size: 18,
                            color: context.theme.colors.primary,
                          )
                        : null,
                    onPress: () => onSelect(level),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _levelLabel(AppLocalizations l10n, LogLevel level) {
    return switch (level) {
      LogLevel.verbose => l10n.settingsDevLogLevelVerbose,
      LogLevel.info => l10n.settingsDevLogLevelInfo,
      LogLevel.warning => l10n.settingsDevLogLevelWarning,
      LogLevel.error => l10n.settingsDevLogLevelError,
      LogLevel.none => l10n.settingsDevLogLevelNone,
    };
  }
}
