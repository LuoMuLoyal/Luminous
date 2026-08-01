import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/widgets/controls_sheet.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Opens the assistant settings side sheet using the latest user settings and
/// the current assistant capabilities.
void showAssistantSettingsSheet(
  BuildContext context,
  WidgetRef ref,
  AssistantCapabilities capabilities,
) {
  final l10n = AppLocalizations.of(context)!;
  final settings = ref.read(userSettingsControllerProvider).value;
  final contextPatch = capabilities.assistantContext;
  final fallbackContext = AssistantContextPatch(
    healthProfile: contextPatch.healthProfile,
    dailyRecords: contextPatch.dailyRecords,
    sleepRecords: contextPatch.sleepRecords,
    currentMedicines: contextPatch.currentMedicines,
  );
  final currentContext = settings?.assistantContext != null
      ? AssistantContextPatch(
          healthProfile: settings!.assistantContext.healthProfile,
          dailyRecords: settings.assistantContext.dailyRecords,
          sleepRecords: settings.assistantContext.sleepRecords,
          currentMedicines: settings.assistantContext.currentMedicines,
        )
      : fallbackContext;

  unawaited(
    showFSheet<void>(
      context: context,
      side: FLayout.rtl,
      builder: (sheetContext) => AssistantControlsSheet(
        title: l10n.assistantControlsDrawerTitle,
        settings: settings,
        fallbackContext: fallbackContext,
        capabilities: capabilities,
        onToggleEnabled: (value) => ref
            .read(userSettingsControllerProvider.notifier)
            .setAssistantEnabled(value),
        onToggleMemoryEnabled: (value) => ref
            .read(userSettingsControllerProvider.notifier)
            .setAssistantMemoryEnabled(value),
        onToggleContext:
            ({
              healthProfile,
              dailyRecords,
              sleepRecords,
              currentMedicines,
            }) => ref
                .read(userSettingsControllerProvider.notifier)
                .setAssistantContext(
                  AssistantContextPatch(
                    healthProfile:
                        healthProfile ?? currentContext.healthProfile,
                    dailyRecords: dailyRecords ?? currentContext.dailyRecords,
                    sleepRecords: sleepRecords ?? currentContext.sleepRecords,
                    currentMedicines:
                        currentMedicines ?? currentContext.currentMedicines,
                  ),
                ),
      ),
    ),
  );
}
