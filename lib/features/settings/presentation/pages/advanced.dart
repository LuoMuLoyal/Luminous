import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/accessibility/settings.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/config/developer_settings.dart';
import 'package:luminous/core/config/feature_flags.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/theme/family.dart';
import 'package:luminous/core/theme/preference.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/data/providers/data_storage.dart';
import 'package:luminous/features/settings/presentation/providers/notification.dart';
import 'package:luminous/features/settings/presentation/providers/profile_sync.dart';
import 'package:luminous/features/settings/presentation/routes.dart';
import 'package:luminous/features/settings/presentation/utils/page_padding.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/selection_icon.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AdvancedSettingsPage extends ConsumerWidget {
  const AdvancedSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return PageScaffold(
      title: l10n.mineSettingsAdvancedTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: settingsPageVerticalPadding(context),
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
                      suffix: const Icon(SemanticIcons.actionNext),
                      onPress: () async {
                        imageCache.clear();
                        imageCache.clearLiveImages();
                        await Toast.show(
                          context,
                          l10n.settingsAdvancedCacheCleared,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xl),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      key: const Key('advanced-settings-row-reset-defaults'),
                      title: Text(
                        l10n.settingsAdvancedResetDefaults,
                        style: context.theme.typography.body.md.copyWith(
                          color: SemanticColor.destructive.solid(context),
                        ),
                      ),
                      subtitle: Text(l10n.settingsAdvancedResetDefaultsHint),
                      suffix: Icon(
                        SemanticIcons.actionReset,
                        size: IconSizeTokens.sm,
                        color: SemanticColor.destructive.solid(context),
                      ),
                      onPress: () async {
                        final confirmed = await showDangerConfirmationDialog(
                          context: context,
                          title: l10n.settingsAdvancedRestoreConfirmTitle,
                          message: l10n.settingsAdvancedRestoreConfirmMessage,
                          confirmLabel:
                              l10n.settingsAdvancedRestoreConfirmAction,
                        );
                        if (!confirmed || !context.mounted) return;
                        await ref
                            .read(themeControllerProvider.notifier)
                            .setMode(AppThemeModePreference.system);
                        await ref
                            .read(themeControllerProvider.notifier)
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
                              .read(localeControllerProvider.notifier)
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
                        await Toast.show(
                          context,
                          l10n.settingsAdvancedDefaultsReset,
                        );
                      },
                    ),
                  ],
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: Spacing.xl),
                  SettingsSectionLabel(
                    label: l10n.settingsDeveloperSectionTitle,
                  ),
                  const SizedBox(height: Spacing.md),
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
          suffix: const Icon(SemanticIcons.actionNext),
          onPress: () => _showEndpointSheet(context, ref, dev),
        ),
        FTile(
          key: const Key('dev-settings-row-log-level'),
          title: Text(l10n.settingsDevLogLevel),
          subtitle: Text(_logLevelLabel(l10n, dev.logLevel)),
          suffix: const Icon(SemanticIcons.actionNext),
          onPress: () => _showLogLevelSheet(context, ref, dev.logLevel),
        ),
        FTile(
          key: const Key('dev-settings-row-feature-flags'),
          title: Text(l10n.settingsFeatureFlagsTitle),
          subtitle: Text(l10n.settingsFeatureFlagsSummary(flags.enabledCount)),
          suffix: const Icon(SemanticIcons.actionNext),
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
    unawaited(
      showFSheet(
        context: context,
        side: FLayout.btt,
        // 本 sheet 在「自定义」被选中时还要塞下 URL 输入框，超过 Forui 默认的
        // 9/16 上限就会 RenderFlex overflow（实测真机溢出 2.3px，确认按钮被裁掉）。
        // 与仓库内其他含滚动子节点的 sheet 一致：交出不限制的主轴比例，由 body
        // 自己滚动。
        mainAxisMaxRatio: null,
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
              await Toast.show(context, l10n.settingsDevApiEndpointSwitched);
            }
          },
          onCustomUrlChanged: (url) {
            unawaited(
              ref
                  .read(developerSettingsControllerProvider.notifier)
                  .setCustomApiUrl(url),
            );
          },
        ),
      ),
    );
  }

  void _showLogLevelSheet(
    BuildContext context,
    WidgetRef ref,
    LogLevel current,
  ) {
    final l10n = AppLocalizations.of(context)!;
    unawaited(
      showFSheet(
        context: context,
        side: FLayout.btt,
        mainAxisMaxRatio: null,
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
    // `showFSheet` 不画 sheet 自身的背景，body 必须自带不透明表面，否则内容
    // 直接叠在被压暗的页面上（真机上就是"sheet 背景透明"）。
    final body = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Text(
                widget.l10n.settingsDevApiEndpoint,
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                for (final endpoint in ApiEndpoint.values)
                  FTile(
                    title: Text(_endpointLabel(widget.l10n, endpoint)),
                    subtitle: Text(_urlLabel(endpoint)),
                    suffix: SettingsSelectionIcon(
                      selected: endpoint == _selected,
                    ),
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
              const SizedBox(height: Spacing.lg),
              FTextField(
                control: FTextFieldControl.managed(
                  controller: _customController,
                ),
                label: Text(widget.l10n.settingsDevApiEndpointCustomUrl),
                hint: 'https://...',
              ),
            ],
            const SizedBox(height: Spacing.lg),
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
    return SheetSurface(child: body);
  }

  String _endpointLabel(AppLocalizations l10n, ApiEndpoint endpoint) {
    return switch (endpoint) {
      ApiEndpoint.local => l10n.settingsDevApiEndpointLocal,
      ApiEndpoint.staging => l10n.settingsDevApiEndpointStaging,
      ApiEndpoint.production => l10n.settingsDevApiEndpointProduction,
      ApiEndpoint.custom => l10n.settingsDevApiEndpointCustom,
    };
  }

  /// 该预设在本机实际解析出的 URL。
  ///
  /// 不能直接用 `endpoint.defaultUrl`：`local` 在 Android 上解析为
  /// `10.0.2.2`（模拟器专用别名），而 defaultUrl 写的是 `127.0.0.1`。此前
  /// sheet 显示 127.0.0.1、页面行显示 10.0.2.2，同一件事两个值，真机上极难
  /// 判断到底打的是哪个地址。走 [DeveloperSettingsState.resolvedBaseUrl]
  /// 复用同一份解析逻辑。
  String _urlLabel(ApiEndpoint endpoint) {
    if (endpoint == ApiEndpoint.custom) {
      return widget.l10n.settingsDevApiEndpointCustomHint;
    }
    return DeveloperSettingsState(
      apiEndpoint: endpoint,
      customApiUrl: _customController.text,
    ).resolvedBaseUrl;
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
    final body = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Text(
                l10n.settingsDevLogLevel,
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                for (final level in LogLevel.values)
                  FTile(
                    title: Text(_levelLabel(l10n, level)),
                    suffix: SettingsSelectionIcon(selected: level == current),
                    onPress: () => onSelect(level),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    return SheetSurface(child: body);
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
