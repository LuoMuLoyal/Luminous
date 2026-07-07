import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/ai/ai_runtime_config.dart';
import 'package:luminous/core/config/feature_flags_controller.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_shared_widgets.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class FeatureFlagsSettingsPage extends ConsumerWidget {
  const FeatureFlagsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final flagsAsync = ref.watch(featureFlagsControllerProvider);
    final flags = flagsAsync.asData?.value ?? const FeatureFlagsState();
    final controller = ref.read(featureFlagsControllerProvider.notifier);

    return PageScaffold(
      title: l10n.settingsFeatureFlagsTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacingTokens.level2,
                    right: AppSpacingTokens.level2,
                    bottom: AppSpacingTokens.level4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FLucideIcons.flaskConical,
                        size: 16,
                        color: context.theme.colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.settingsFeatureFlagsWarning,
                          style: AppTypographyToken.level3
                              .body(context)
                              .copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                SettingsSectionLabel(label: l10n.settingsFeatureFlagsAiSection),
                const SizedBox(height: AppSpacingTokens.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      title: Text(l10n.settingsFeatureFlagsAiRuntime),
                      subtitle: Text(
                        l10n.settingsFeatureFlagsAiRuntimeSubtitle,
                      ),
                      suffix: FSwitch(
                        value: flags.onDeviceAiRuntime,
                        onChange: (v) => controller.setOnDeviceAiRuntime(v),
                      ),
                      onPress: () => controller.setOnDeviceAiRuntime(
                        !flags.onDeviceAiRuntime,
                      ),
                    ),
                    FTile(
                      title: Text(l10n.settingsFeatureFlagsAiProvider),
                      subtitle: Text(flags.aiRuntimeProvider.name),
                      suffix: const Icon(FLucideIcons.chevronRight),
                      onPress: () => _showProviderSheet(
                        context,
                        flags.aiRuntimeProvider,
                        controller.setAiRuntimeProvider,
                      ),
                    ),
                    FTile(
                      title: Text(l10n.settingsFeatureFlagsGenUi),
                      subtitle: Text(l10n.settingsFeatureFlagsGenUiSubtitle),
                      suffix: FSwitch(
                        value: flags.genUiEnabled,
                        onChange: (v) => controller.setGenUiEnabled(v),
                      ),
                      onPress: () =>
                          controller.setGenUiEnabled(!flags.genUiEnabled),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level5),
                SettingsSectionLabel(
                  label: l10n.settingsFeatureFlagsAssistantSection,
                ),
                const SizedBox(height: AppSpacingTokens.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      title: Text(l10n.settingsFeatureFlagsStreamMode),
                      subtitle: Text(
                        l10n.settingsFeatureFlagsStreamModeSubtitle,
                      ),
                      suffix: FSwitch(
                        value: flags.assistantStreamMode,
                        onChange: (v) => controller.setAssistantStreamMode(v),
                      ),
                      onPress: () => controller.setAssistantStreamMode(
                        !flags.assistantStreamMode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level5),
                SettingsSectionLabel(
                  label: l10n.settingsFeatureFlagsMedicineSection,
                ),
                const SizedBox(height: AppSpacingTokens.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      title: Text(l10n.settingsFeatureFlagsBarcodeScan),
                      subtitle: Text(
                        l10n.settingsFeatureFlagsBarcodeScanSubtitle,
                      ),
                      suffix: FSwitch(
                        value: flags.medicineBarcodeScan,
                        onChange: (v) => controller.setMedicineBarcodeScan(v),
                      ),
                      onPress: () => controller.setMedicineBarcodeScan(
                        !flags.medicineBarcodeScan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level5),
                SettingsSectionLabel(
                  label: l10n.settingsFeatureFlagsReportSection,
                ),
                const SizedBox(height: AppSpacingTokens.level3),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      title: Text(l10n.settingsFeatureFlagsPdfExport),
                      subtitle: Text(
                        l10n.settingsFeatureFlagsPdfExportSubtitle,
                      ),
                      suffix: FSwitch(
                        value: flags.reportExportPdf,
                        onChange: (v) => controller.setReportExportPdf(v),
                      ),
                      onPress: () =>
                          controller.setReportExportPdf(!flags.reportExportPdf),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProviderSheet(
    BuildContext context,
    AiRuntimeProviderKind current,
    Future<void> Function(AiRuntimeProviderKind) onSelect,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showFSheet(
      context: context,
      side: FLayout.btt,
      builder: (context) =>
          _ProviderSheet(current: current, onSelect: onSelect, l10n: l10n),
    );
  }
}

class _ProviderSheet extends ConsumerWidget {
  const _ProviderSheet({
    required this.current,
    required this.onSelect,
    required this.l10n,
  });

  final AiRuntimeProviderKind current;
  final Future<void> Function(AiRuntimeProviderKind) onSelect;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacingTokens.level3),
              child: Text(
                l10n.settingsFeatureFlagsAiProvider,
                style: AppTypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            FTileGroup(
              style: settingsSubpageTileGroupStyle(context.theme),
              children: [
                for (final kind in AiRuntimeProviderKind.values)
                  FTile(
                    title: Text(kind.name),
                    suffix: kind == current
                        ? Icon(
                            FLucideIcons.check,
                            size: 18,
                            color: context.theme.colors.primary,
                          )
                        : null,
                    onPress: () {
                      Navigator.of(context).pop();
                      onSelect(kind);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
