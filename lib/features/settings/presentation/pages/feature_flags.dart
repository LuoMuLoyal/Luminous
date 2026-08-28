import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/ai/runtime_config.dart';
import 'package:luminous/core/config/feature_flags.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/utils/page_padding.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/selection_icon.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
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
            padding: EdgeInsets.symmetric(
              vertical: settingsPageVerticalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: Spacing.level2,
                    right: Spacing.level2,
                    bottom: Spacing.level4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        SemanticIcons.recordSymptom,
                        size: IconSizeTokens.level2,
                        color: context.theme.colors.primary,
                      ),
                      const SizedBox(width: Spacing.level2),
                      Expanded(
                        child: Text(
                          l10n.settingsFeatureFlagsWarning,
                          style: TypographyToken.level3
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
                const SizedBox(height: Spacing.level3),
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
                      suffix: const Icon(SemanticIcons.actionNext),
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
                const SizedBox(height: Spacing.level5),
                SettingsSectionLabel(
                  label: l10n.settingsFeatureFlagsAssistantSection,
                ),
                const SizedBox(height: Spacing.level3),
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
                const SizedBox(height: Spacing.level5),
                SettingsSectionLabel(
                  label: l10n.settingsFeatureFlagsMedicineSection,
                ),
                const SizedBox(height: Spacing.level3),
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
                const SizedBox(height: Spacing.level5),
                SettingsSectionLabel(
                  label: l10n.settingsFeatureFlagsReportSection,
                ),
                const SizedBox(height: Spacing.level3),
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
    unawaited(
      showFSheet(
        context: context,
        side: FLayout.btt,
        builder: (context) =>
            _ProviderSheet(current: current, onSelect: onSelect, l10n: l10n),
      ),
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
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.level3),
              child: Text(
                l10n.settingsFeatureFlagsAiProvider,
                style: TypographyToken.level5
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
                    suffix: SettingsSelectionIcon(selected: kind == current),
                    onPress: () {
                      Navigator.of(context).pop();
                      unawaited(onSelect(kind));
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
