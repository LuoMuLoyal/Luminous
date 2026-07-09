import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'package:luminous/core/design/design.dart';

class AssistantControlsPanel extends StatelessWidget {
  const AssistantControlsPanel({
    super.key,
    required this.settings,
    required this.fallbackContext,
    required this.capabilities,
    required this.onToggleEnabled,
    required this.onToggleMemoryEnabled,
    required this.onToggleContext,
  });

  final UserSettingsDataDto? settings;
  final UpdateAssistantContextSettingsDto? fallbackContext;
  final AssistantCapabilities capabilities;
  final ValueChanged<bool> onToggleEnabled;
  final ValueChanged<bool> onToggleMemoryEnabled;
  final Future<void> Function({
    bool? healthProfile,
    bool? dailyRecords,
    bool? sleepRecords,
    bool? currentMedicines,
  })
  onToggleContext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FCard.raw(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.assistantStatusSectionTitle,
            style: TypographyToken.level5
                .body(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Spacing.level3),
          Text(
            l10n.assistantEntrySubtitle,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
          const SizedBox(height: Spacing.level4),
          FTileGroup(
            children: [
              _SwitchTile(
                tileKey: const Key('assistant-row-enabled'),
                title: l10n.assistantSettingsEnableTitle,
                subtitle: l10n.assistantSettingsEnableSubtitle,
                value:
                    settings?.assistantEnabled ?? capabilities.assistantEnabled,
                onChanged: (value) => onToggleEnabled(value),
              ),
              _SwitchTile(
                tileKey: const Key('assistant-row-memory-enabled'),
                title: l10n.assistantSettingsMemoryTitle,
                subtitle: l10n.assistantSettingsMemorySubtitle,
                value:
                    settings?.assistantMemoryEnabled ??
                    capabilities.assistantMemoryEnabled,
                onChanged: (value) => onToggleMemoryEnabled(value),
              ),
              _SwitchTile(
                tileKey: const Key('assistant-row-context-health-profile'),
                title: l10n.assistantContextHealthProfile,
                value:
                    settings?.assistantContext.healthProfile ??
                    capabilities.assistantContext.healthProfile,
                onChanged: (value) => onToggleContext(healthProfile: value),
              ),
              _SwitchTile(
                tileKey: const Key('assistant-row-context-daily-records'),
                title: l10n.assistantContextDailyRecords,
                value:
                    settings?.assistantContext.dailyRecords ??
                    capabilities.assistantContext.dailyRecords,
                onChanged: (value) => onToggleContext(dailyRecords: value),
              ),
              _SwitchTile(
                tileKey: const Key('assistant-row-context-sleep-records'),
                title: l10n.assistantContextSleepRecords,
                value:
                    settings?.assistantContext.sleepRecords ??
                    capabilities.assistantContext.sleepRecords,
                onChanged: (value) => onToggleContext(sleepRecords: value),
              ),
              _SwitchTile(
                tileKey: const Key('assistant-row-context-current-medicines'),
                title: l10n.assistantContextCurrentMedicines,
                value:
                    settings?.assistantContext.currentMedicines ??
                    capabilities.assistantContext.currentMedicines,
                onChanged: (value) => onToggleContext(currentMedicines: value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget with FTileMixin {
  const _SwitchTile({
    required this.tileKey,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Key tileKey;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FTile(
      key: tileKey,
      title: Text(title),
      subtitle: () {
        final s = subtitle;
        return s == null || s.isEmpty ? null : Text(s);
      }(),
      suffix: FSwitch(value: value, onChange: onChanged),
      onPress: () => onChanged(!value),
    );
  }
}
