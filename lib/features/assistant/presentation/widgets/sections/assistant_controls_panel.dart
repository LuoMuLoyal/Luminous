import 'package:flutter/material.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/widgets/app_setting_row.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/assistant/domain/entities/assistant_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AssistantControlsPanel extends StatelessWidget {
  const AssistantControlsPanel({
    super.key,
    required this.surface,
    required this.typography,
    required this.settings,
    required this.fallbackContext,
    required this.capabilities,
    required this.onToggleEnabled,
    required this.onToggleMemoryEnabled,
    required this.onToggleContext,
  });

  final AppThemeSurface surface;
  final AppTypographyScale typography;
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

    return AppSectionSurface(
      surface: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.assistantStatusSectionTitle,
            style: typography.bodyMdStrong,
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n.assistantEntrySubtitle,
            style: typography.bodySm.copyWith(color: surface.body),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AppSettingRow(
            key: const Key('assistant-row-enabled'),
            title: l10n.assistantSettingsEnableTitle,
            subtitle: l10n.assistantSettingsEnableSubtitle,
            icon: Icons.auto_awesome_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantEnabled ?? capabilities.assistantEnabled,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleEnabled(
              !(settings?.assistantEnabled ?? capabilities.assistantEnabled),
            ),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('assistant-row-memory-enabled'),
            title: l10n.assistantSettingsMemoryTitle,
            subtitle: l10n.assistantSettingsMemorySubtitle,
            icon: Icons.psychology_alt_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantMemoryEnabled ??
                    capabilities.assistantMemoryEnabled,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleMemoryEnabled(
              !(settings?.assistantMemoryEnabled ??
                  capabilities.assistantMemoryEnabled),
            ),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('assistant-row-context-health-profile'),
            title: l10n.assistantContextHealthProfile,
            icon: Icons.badge_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantContext.healthProfile ??
                    capabilities.assistantContext.healthProfile,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              healthProfile:
                  !(settings?.assistantContext.healthProfile ??
                      capabilities.assistantContext.healthProfile),
            ),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('assistant-row-context-daily-records'),
            title: l10n.assistantContextDailyRecords,
            icon: Icons.event_note_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantContext.dailyRecords ??
                    capabilities.assistantContext.dailyRecords,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              dailyRecords:
                  !(settings?.assistantContext.dailyRecords ??
                      capabilities.assistantContext.dailyRecords),
            ),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('assistant-row-context-sleep-records'),
            title: l10n.assistantContextSleepRecords,
            icon: Icons.bedtime_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantContext.sleepRecords ??
                    capabilities.assistantContext.sleepRecords,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              sleepRecords:
                  !(settings?.assistantContext.sleepRecords ??
                      capabilities.assistantContext.sleepRecords),
            ),
            showDivider: true,
          ),
          AppSettingRow(
            key: const Key('assistant-row-context-current-medicines'),
            title: l10n.assistantContextCurrentMedicines,
            icon: Icons.medication_outlined,
            trailing: IgnorePointer(
              child: Switch(
                value:
                    settings?.assistantContext.currentMedicines ??
                    capabilities.assistantContext.currentMedicines,
                onChanged: (_) {},
              ),
            ),
            onTap: () => onToggleContext(
              currentMedicines:
                  !(settings?.assistantContext.currentMedicines ??
                      capabilities.assistantContext.currentMedicines),
            ),
          ),
        ],
      ),
    );
  }
}
