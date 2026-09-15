import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/pill_chip.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/constants/fast_entry_choices.dart';
import 'package:luminous/features/record/domain/constants/symptom_catalog.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/water_custom_amount_dialog.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Long-press dialog for a quick-entry tile (Forui [FDialog]).
///
/// Per the quick-entry UX spec, long press is a shortcut to the type-specific
/// "more/settings" surface:
/// - water: water default amount + badge display settings;
/// - other grid types: the type's current rule description.
///
/// Meal is handled separately (manual no-photo entry dialog).
class QuickEntryTypeSettingsDialog extends ConsumerWidget {
  const QuickEntryTypeSettingsDialog({
    super.key,
    required this.action,
    required this.l10n,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final label = recordCopy(l10n, action.titleKey);
    final typography = context.theme.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: typography.body.lg),
        const SizedBox(height: Spacing.lg),
        if (action.type == RecordEntryType.water)
          _WaterSettings(
            prefs: prefs,
            controller: ref.read(quickEntryPreferencesProvider.notifier),
            l10n: l10n,
          )
        else if (action.type == RecordEntryType.symptom)
          _SymptomSettings(
            prefs: prefs,
            controller: ref.read(quickEntryPreferencesProvider.notifier),
            l10n: l10n,
          )
        else if (action.type == RecordEntryType.mood)
          _MoodSettings(
            prefs: prefs,
            controller: ref.read(quickEntryPreferencesProvider.notifier),
            l10n: l10n,
          )
        else if (action.type == RecordEntryType.medication)
          _MedicationSettings(
            prefs: prefs,
            controller: ref.read(quickEntryPreferencesProvider.notifier),
            l10n: l10n,
          )
        else
          Text(_ruleText(l10n, action.type), style: typography.body.sm),
        const SizedBox(height: Spacing.xl),
        Align(
          alignment: Alignment.centerRight,
          child: FButton(
            variant: FButtonVariant.ghost,
            onPress: () => Navigator.of(context).pop(),
            child: Text(l10n.commonConfirm),
          ),
        ),
      ],
    );
  }

  /// Rule copy per type. Every branch is explicit on purpose: a wildcard here
  /// silently rendered the meal copy for note / vitals / activity / heart rate /
  /// weight long-press dialogs.
  String _ruleText(AppLocalizations l10n, RecordEntryType type) {
    return switch (type) {
      RecordEntryType.meal => l10n.recordQuickSettingsMealRule,
      RecordEntryType.medication => l10n.recordQuickSettingsMedicationRule,
      RecordEntryType.symptom => l10n.recordQuickSettingsSymptomRule,
      RecordEntryType.mood => l10n.recordQuickSettingsMoodRule,
      RecordEntryType.sleep => l10n.recordQuickSettingsSleepRule,
      // water / vitals / activity / heartRate / weight / note have no dedicated
      // rule copy (water renders its own settings surface above).
      RecordEntryType.water ||
      RecordEntryType.vitals ||
      RecordEntryType.activity ||
      RecordEntryType.heartRate ||
      RecordEntryType.weight ||
      RecordEntryType.note => l10n.recordQuickSettingsGeneralRule,
    };
  }
}

class _MedicationSettings extends StatelessWidget {
  const _MedicationSettings({
    required this.prefs,
    required this.controller,
    required this.l10n,
  });

  final QuickEntryPreferences prefs;
  final QuickEntryPreferencesController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTile(
          title: Text(l10n.recordQuickSettingsMedicationAutoRecord),
          subtitle: Text(l10n.recordQuickSettingsMedicationAutoRecordHint),
          suffix: FSwitch(
            value: prefs.medicationAutoRecordSingle,
            onChange: controller.setMedicationAutoRecordSingle,
          ),
          onPress: () => controller.setMedicationAutoRecordSingle(
            !prefs.medicationAutoRecordSingle,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        FTile(
          title: Text(l10n.recordQuickSettingsMedicationAlreadyRecordedHint),
          subtitle: Text(
            l10n.recordQuickSettingsMedicationAlreadyRecordedHintDesc,
          ),
          suffix: FSwitch(
            value: prefs.medicationShowAlreadyRecordedHint,
            onChange: controller.setMedicationShowAlreadyRecordedHint,
          ),
          onPress: () => controller.setMedicationShowAlreadyRecordedHint(
            !prefs.medicationShowAlreadyRecordedHint,
          ),
        ),
      ],
    );
  }
}

class _MoodSettings extends StatelessWidget {
  const _MoodSettings({
    required this.prefs,
    required this.controller,
    required this.l10n,
  });

  final QuickEntryPreferences prefs;
  final QuickEntryPreferencesController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FSelect<QuickEntryMoodBadgeMode>.rich(
          key: const Key('quick-type-mood-badge'),
          label: Text(l10n.recordQuickSettingsMoodBadge),
          format: (value) => _moodBadgeLabel(l10n, value),
          control: FSelectControl.lifted(
            value: prefs.moodBadgeMode,
            onChange: (value) {
              if (value != null) {
                unawaited(controller.setMoodBadgeMode(value));
              }
            },
          ),
          children: [
            for (final mode in QuickEntryMoodBadgeMode.values)
              FSelectItem.item(
                title: Text(_moodBadgeLabel(l10n, mode)),
                value: mode,
              ),
          ],
        ),
      ],
    );
  }

  String _moodBadgeLabel(AppLocalizations l10n, QuickEntryMoodBadgeMode mode) {
    return switch (mode) {
      QuickEntryMoodBadgeMode.latest => l10n.recordQuickSettingsMoodBadgeLatest,
      QuickEntryMoodBadgeMode.hidden => l10n.recordQuickSettingsMoodBadgeHidden,
    };
  }
}

class _SymptomSettings extends StatelessWidget {
  const _SymptomSettings({
    required this.prefs,
    required this.controller,
    required this.l10n,
  });

  final QuickEntryPreferences prefs;
  final QuickEntryPreferencesController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final severityOptions = _symptomSeverityOptions(l10n);
    final allChoices = recordFastEntryChoicesFor(DailyRecordKind.symptom, l10n);
    final enabledSet = prefs.symptomEnabledChoices.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FSelect<String>.rich(
          key: const Key('quick-type-symptom-severity'),
          label: Text(l10n.recordQuickSettingsSymptomDefaultSeverity),
          format: (value) => symptomSeverityLabel(l10n, value),
          control: FSelectControl.lifted(
            value: prefs.symptomDefaultSeverity,
            onChange: (value) {
              if (value != null) {
                unawaited(controller.setSymptomDefaultSeverity(value));
              }
            },
          ),
          children: [
            for (final option in severityOptions)
              FSelectItem.item(
                title: Text(symptomSeverityLabel(l10n, option)),
                value: option,
              ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        Text(
          l10n.recordQuickSettingsSymptomChoices,
          style: context.theme.typography.body.sm,
        ),
        const SizedBox(height: Spacing.sm),
        Material(
          type: MaterialType.transparency,
          child: Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              for (final choice in allChoices)
                PillChip(
                  label: choice.label,
                  selected:
                      enabledSet.isEmpty ||
                      enabledSet.contains(recordFastChoiceCode(choice)),
                  onPress: () {
                    final code = recordFastChoiceCode(choice);
                    if (code == null) return;
                    unawaited(
                      controller.setSymptomEnabledChoices(
                        toggleSymptomChoice(
                          currentChoices: prefs.symptomEnabledChoices,
                          choiceCode: code,
                          selected: !enabledSet.contains(code),
                          l10n: l10n,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _symptomSeverityOptions(AppLocalizations l10n) => [
    for (final severity in SymptomSeverity.ordered) severity.wireValue,
  ];
}

class _WaterSettings extends StatelessWidget {
  const _WaterSettings({
    required this.prefs,
    required this.controller,
    required this.l10n,
  });

  final QuickEntryPreferences prefs;
  final QuickEntryPreferencesController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FSelect<QuickEntryWaterDefault>.rich(
          key: const Key('quick-type-water-default'),
          label: Text(l10n.recordQuickSettingsWaterDefault),
          format: (value) => waterDefaultOptionLabel(
            l10n,
            value,
            customMl: prefs.waterCustomMl,
          ),
          control: FSelectControl.lifted(
            value: prefs.waterDefault,
            onChange: (value) {
              if (value != null) {
                unawaited(
                  handleWaterDefaultSelect(
                    context,
                    value: value,
                    prefs: prefs,
                    controller: controller,
                  ),
                );
              }
            },
          ),
          children: [
            for (final option in QuickEntryWaterDefault.values)
              FSelectItem.item(
                title: Text(
                  waterDefaultOptionLabel(
                    l10n,
                    option,
                    customMl: prefs.waterCustomMl,
                  ),
                ),
                value: option,
              ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        FSelect<QuickEntryWaterBadgeMode>.rich(
          key: const Key('quick-type-water-badge'),
          label: Text(l10n.recordQuickSettingsWaterBadge),
          format: (value) => waterBadgeLabel(l10n, value),
          control: FSelectControl.lifted(
            value: prefs.waterBadgeMode,
            onChange: (value) {
              if (value != null) {
                unawaited(controller.setWaterBadgeMode(value));
              }
            },
          ),
          children: [
            for (final mode in QuickEntryWaterBadgeMode.values)
              FSelectItem.item(
                title: Text(waterBadgeLabel(l10n, mode)),
                value: mode,
              ),
          ],
        ),
      ],
    );
  }
}
