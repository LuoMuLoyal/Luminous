import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

import 'package:luminous/core/design/design.dart';

class AiSettingsPage extends ConsumerWidget {
  const AiSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(userSettingsControllerProvider);
    final settings = settingsAsync.asData?.value;
    final signedIn = settings != null;
    final assistantEnabled = settings?.assistantEnabled ?? false;
    final contextDisabled = !assistantEnabled || settingsAsync.isLoading;

    return PageScaffold(
      title: l10n.settingsAiTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    FTile(
                      title: Text(l10n.settingsAiSummariesTitle),
                      subtitle: Text(l10n.settingsAiSummariesSubtitle),
                      suffix: FSwitch(
                        value: settings?.aiSummariesEnabled ?? false,
                        enabled: !settingsAsync.isLoading,
                        onChange: (value) {
                          if (!signedIn) {
                            pushAuthRequiredRoute(context, '/settings/ai');
                            return;
                          }
                          ref
                              .read(userSettingsControllerProvider.notifier)
                              .setAiSummariesEnabled(value);
                        },
                      ),
                      enabled: !settingsAsync.isLoading,
                      onPress: !settingsAsync.isLoading
                          ? () {
                              final next =
                                  !(settings?.aiSummariesEnabled ?? false);
                              if (!signedIn) {
                                pushAuthRequiredRoute(context, '/settings/ai');
                                return;
                              }
                              ref
                                  .read(userSettingsControllerProvider.notifier)
                                  .setAiSummariesEnabled(next);
                            }
                          : null,
                    ),
                    FTile(
                      title: Text(l10n.settingsAiAssistantTitle),
                      subtitle: Text(l10n.settingsAiAssistantSubtitle),
                      suffix: FSwitch(
                        value: settings?.assistantEnabled ?? false,
                        enabled: !settingsAsync.isLoading,
                        onChange: (value) {
                          if (!signedIn) {
                            pushAuthRequiredRoute(context, '/settings/ai');
                            return;
                          }
                          ref
                              .read(userSettingsControllerProvider.notifier)
                              .setAssistantEnabled(value);
                        },
                      ),
                      enabled: !settingsAsync.isLoading,
                      onPress: !settingsAsync.isLoading
                          ? () {
                              final next =
                                  !(settings?.assistantEnabled ?? false);
                              if (!signedIn) {
                                pushAuthRequiredRoute(context, '/settings/ai');
                                return;
                              }
                              ref
                                  .read(userSettingsControllerProvider.notifier)
                                  .setAssistantEnabled(next);
                            }
                          : null,
                    ),
                    FTile(
                      title: Text(l10n.settingsAiMemoryTitle),
                      subtitle: Text(l10n.settingsAiMemorySubtitle),
                      suffix: FSwitch(
                        value: settings?.assistantMemoryEnabled ?? false,
                        enabled: !settingsAsync.isLoading,
                        onChange: (value) {
                          if (!signedIn) {
                            pushAuthRequiredRoute(context, '/settings/ai');
                            return;
                          }
                          ref
                              .read(userSettingsControllerProvider.notifier)
                              .setAssistantMemoryEnabled(value);
                        },
                      ),
                      enabled: !settingsAsync.isLoading,
                      onPress: !settingsAsync.isLoading
                          ? () {
                              final next =
                                  !(settings?.assistantMemoryEnabled ?? false);
                              if (!signedIn) {
                                pushAuthRequiredRoute(context, '/settings/ai');
                                return;
                              }
                              ref
                                  .read(userSettingsControllerProvider.notifier)
                                  .setAssistantMemoryEnabled(next);
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level5),
                SettingsSectionLabel(label: l10n.settingsAiContextSectionTitle),
                const SizedBox(height: AppSpacingTokens.level3),
                if (!assistantEnabled)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacingTokens.level2,
                      right: AppSpacingTokens.level2,
                      bottom: AppSpacingTokens.level3,
                    ),
                    child: Text(
                      l10n.settingsAiContextDisabledHint,
                      style: AppTypographyToken.level3
                          .body(context)
                          .copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                    ),
                  ),
                FTileGroup(
                  style: settingsSubpageTileGroupStyle(context.theme),
                  children: [
                    _buildContextTile(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      signedIn: signedIn,
                      enabled: !contextDisabled,
                      isLoading: settingsAsync.isLoading,
                      title: l10n.settingsAiContextHealthProfile,
                      subtitle: l10n.settingsAiContextHealthProfileSubtitle,
                      value: settings?.assistantContext.healthProfile ?? false,
                      field: UpdateAssistantContextSettingsDto(
                        healthProfile:
                            !(settings?.assistantContext.healthProfile ??
                                false),
                      ),
                    ),
                    _buildContextTile(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      signedIn: signedIn,
                      enabled: !contextDisabled,
                      isLoading: settingsAsync.isLoading,
                      title: l10n.settingsAiContextDailyRecords,
                      subtitle: l10n.settingsAiContextDailyRecordsSubtitle,
                      value: settings?.assistantContext.dailyRecords ?? false,
                      field: UpdateAssistantContextSettingsDto(
                        dailyRecords:
                            !(settings?.assistantContext.dailyRecords ?? false),
                      ),
                    ),
                    _buildContextTile(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      signedIn: signedIn,
                      enabled: !contextDisabled,
                      isLoading: settingsAsync.isLoading,
                      title: l10n.settingsAiContextSleepRecords,
                      subtitle: l10n.settingsAiContextSleepRecordsSubtitle,
                      value: settings?.assistantContext.sleepRecords ?? false,
                      field: UpdateAssistantContextSettingsDto(
                        sleepRecords:
                            !(settings?.assistantContext.sleepRecords ?? false),
                      ),
                    ),
                    _buildContextTile(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      signedIn: signedIn,
                      enabled: !contextDisabled,
                      isLoading: settingsAsync.isLoading,
                      title: l10n.settingsAiContextCurrentMedicines,
                      subtitle: l10n.settingsAiContextCurrentMedicinesSubtitle,
                      value:
                          settings?.assistantContext.currentMedicines ?? false,
                      field: UpdateAssistantContextSettingsDto(
                        currentMedicines:
                            !(settings?.assistantContext.currentMedicines ??
                                false),
                      ),
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

  FTile _buildContextTile({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required bool signedIn,
    required bool enabled,
    required bool isLoading,
    required String title,
    required String subtitle,
    required bool value,
    required UpdateAssistantContextSettingsDto field,
  }) {
    return FTile(
      title: Text(title),
      subtitle: Text(subtitle),
      enabled: enabled,
      onPress: enabled
          ? () {
              if (!signedIn) {
                pushAuthRequiredRoute(context, '/settings/ai');
                return;
              }
              ref
                  .read(userSettingsControllerProvider.notifier)
                  .setAssistantContext(field);
            }
          : null,
      suffix: FSwitch(
        value: value,
        enabled: enabled,
        onChange: enabled
            ? (newValue) {
                if (!signedIn) {
                  pushAuthRequiredRoute(context, '/settings/ai');
                  return;
                }
                ref
                    .read(userSettingsControllerProvider.notifier)
                    .setAssistantContext(field);
              }
            : null,
      ),
    );
  }
}
